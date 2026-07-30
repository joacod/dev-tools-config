#!/usr/bin/env python3

import argparse
import http.client
import json
import os
import statistics
import time
import uuid
from datetime import datetime, timezone
from importlib.metadata import version
from urllib.parse import urlparse

os.environ.setdefault("TRANSFORMERS_VERBOSITY", "error")

from transformers import AutoTokenizer


def emit(event):
    print(json.dumps(event, sort_keys=True), flush=True)


def make_prompt(tokenizer, target, chat_template_kwargs, unique=True):
    run_id = uuid.uuid4().hex if unique else "cache-reuse"
    prefix = f"Cold benchmark {run_id}. Context follows.\n"
    suffix = "\nRepeat the word apple separated by spaces until stopped."
    unit = " The project contains deterministic benchmark context."

    def token_count(repetitions):
        messages = [{"role": "user", "content": prefix + unit * repetitions + suffix}]
        rendered = tokenizer.apply_chat_template(
            messages,
            tokenize=False,
            add_generation_prompt=True,
            **chat_template_kwargs,
        )
        return len(tokenizer.encode(rendered, add_special_tokens=False))

    minimum = token_count(0)
    if target < minimum:
        raise ValueError(
            f"Target {target} is below the chat template minimum of {minimum} tokens"
        )

    low, high = 0, target
    while low < high:
        mid = (low + high + 1) // 2
        if token_count(mid) <= target:
            low = mid
        else:
            high = mid - 1
    return prefix + unit * low + suffix


class ServerClient:
    def __init__(self, base_url, timeout):
        parsed = urlparse(base_url)
        if parsed.scheme not in {"http", "https"} or not parsed.hostname:
            raise ValueError("--url must be an http or https URL")
        self.connection_class = (
            http.client.HTTPSConnection
            if parsed.scheme == "https"
            else http.client.HTTPConnection
        )
        self.host = parsed.hostname
        self.port = parsed.port
        self.base_path = parsed.path.rstrip("/")
        self.timeout = timeout

    def connection(self):
        return self.connection_class(self.host, self.port, timeout=self.timeout)

    def health(self):
        connection = self.connection()
        connection.request("GET", f"{self.base_path}/health")
        response = connection.getresponse()
        body = response.read().decode()
        connection.close()
        if response.status != 200:
            raise RuntimeError(f"Health check returned HTTP {response.status}: {body}")

    def request(self, prompt, max_tokens, chat_template_kwargs):
        body = json.dumps(
            {
                "messages": [{"role": "user", "content": prompt}],
                "temperature": 0.0,
                "max_tokens": max_tokens,
                "stream": True,
                "stream_options": {"include_usage": True},
                "chat_template_kwargs": chat_template_kwargs,
            }
        )
        connection = self.connection()
        start = time.perf_counter()
        connection.request(
            "POST",
            f"{self.base_path}/v1/chat/completions",
            body=body,
            headers={"Content-Type": "application/json"},
        )
        response = connection.getresponse()
        if response.status != 200:
            error = response.read().decode()
            connection.close()
            raise RuntimeError(f"HTTP {response.status}: {error}")

        first_token = None
        usage = None
        for raw_line in response:
            line = raw_line.decode().strip()
            if not line.startswith("data: ") or line == "data: [DONE]":
                continue
            event = json.loads(line[6:])
            if event.get("usage"):
                usage = event["usage"]
            choices = event.get("choices", [])
            if choices:
                delta = choices[0].get("delta", {})
                if first_token is None and (
                    delta.get("content") or delta.get("reasoning")
                ):
                    first_token = time.perf_counter()

        end = time.perf_counter()
        connection.close()
        if first_token is None or usage is None:
            raise RuntimeError("Streaming response omitted token timing or usage")

        completion_tokens = usage["completion_tokens"]
        decode_seconds = end - first_token
        return {
            "prompt_tokens": usage["prompt_tokens"],
            "completion_tokens": completion_tokens,
            "cached_tokens": usage.get("prompt_tokens_details", {}).get(
                "cached_tokens", 0
            ),
            "ttft_seconds": first_token - start,
            "total_seconds": end - start,
            "decode_tokens_per_second": (
                (completion_tokens - 1) / decode_seconds
                if completion_tokens > 1
                else 0
            ),
        }


def median_summary(results):
    return {
        "prompt_tokens": int(statistics.median(r["prompt_tokens"] for r in results)),
        "completion_tokens": int(
            statistics.median(r["completion_tokens"] for r in results)
        ),
        "ttft_seconds": statistics.median(r["ttft_seconds"] for r in results),
        "total_seconds": statistics.median(r["total_seconds"] for r in results),
        "decode_tokens_per_second": statistics.median(
            r["decode_tokens_per_second"] for r in results
        ),
    }


def main():
    parser = argparse.ArgumentParser(
        description="Benchmark a running mlx_lm.server through its HTTP API."
    )
    parser.add_argument("--model", required=True, help="Tokenizer repo or local path")
    parser.add_argument("--url", default="http://127.0.0.1:8080")
    parser.add_argument("--targets", type=int, nargs="+", default=[2048, 8192, 16384, 32768])
    parser.add_argument("--trials", type=int, default=3)
    parser.add_argument("--max-tokens", type=int, default=128)
    parser.add_argument("--cache-target", type=int)
    parser.add_argument("--cache-only", action="store_true")
    parser.add_argument("--label", default="default")
    parser.add_argument("--timeout", type=int, default=300)
    parser.add_argument(
        "--chat-template-kwargs",
        default='{"enable_thinking": false}',
        help="JSON passed to both local and server chat templates",
    )
    args = parser.parse_args()

    if args.trials < 1 or args.max_tokens < 2:
        parser.error("--trials must be positive and --max-tokens must be at least 2")
    if args.cache_only and not args.cache_target:
        parser.error("--cache-only requires --cache-target")

    try:
        chat_template_kwargs = json.loads(args.chat_template_kwargs)
    except json.JSONDecodeError as error:
        parser.error(f"invalid --chat-template-kwargs JSON: {error}")
    if not isinstance(chat_template_kwargs, dict):
        parser.error("--chat-template-kwargs must contain a JSON object")

    client = ServerClient(args.url, args.timeout)
    client.health()
    tokenizer = AutoTokenizer.from_pretrained(args.model, local_files_only=True)

    emit(
        {
            "type": "metadata",
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "label": args.label,
            "url": args.url,
            "model": args.model,
            "targets": args.targets,
            "trials": args.trials,
            "max_tokens": args.max_tokens,
            "cache_target": args.cache_target,
            "cache_only": args.cache_only,
            "chat_template_kwargs": chat_template_kwargs,
            "mlx_lm_version": version("mlx-lm"),
            "mlx_version": version("mlx"),
            "mlx_metal_version": version("mlx-metal"),
        }
    )

    warmup_prompt = make_prompt(tokenizer, 512, chat_template_kwargs)
    emit(
        {
            "type": "warmup",
            "label": args.label,
            **client.request(warmup_prompt, args.max_tokens, chat_template_kwargs),
        }
    )

    if not args.cache_only:
        for target in args.targets:
            results = []
            for trial in range(1, args.trials + 1):
                prompt = make_prompt(tokenizer, target, chat_template_kwargs)
                result = client.request(prompt, args.max_tokens, chat_template_kwargs)
                results.append(result)
                emit(
                    {
                        "type": "trial",
                        "label": args.label,
                        "target_tokens": target,
                        "trial": trial,
                        **result,
                    }
                )
            emit(
                {
                    "type": "summary",
                    "label": args.label,
                    "target_tokens": target,
                    **median_summary(results),
                }
            )

    if args.cache_target:
        prompt = make_prompt(
            tokenizer, args.cache_target, chat_template_kwargs, unique=False
        )
        for trial in range(1, args.trials + 1):
            emit(
                {
                    "type": "cache_trial",
                    "label": args.label,
                    "target_tokens": args.cache_target,
                    "trial": trial,
                    **client.request(prompt, args.max_tokens, chat_template_kwargs),
                }
            )


if __name__ == "__main__":
    main()
