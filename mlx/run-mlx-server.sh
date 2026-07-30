#!/bin/bash

set -euo pipefail

invocation_dir="$PWD"
cd "$(dirname "$0")"

m4_48gb=false
m2_16gb=false
model=""
server_args=()
server_arg_count=0

HF_CACHE_DIR="${HF_HUB_CACHE:-${HF_HOME:-$HOME/.cache/huggingface}/hub}"

starter_models=(
  "mlx-community/Qwen3-1.7B-4bit|Small public smoke test"
)

usage() {
  cat <<'EOF'
Usage: run-mlx-server.sh [OPTIONS] [-- SERVER_OPTIONS]

Starts mlx_lm.server on port 8080.

Options:
  --model <repo_or_path>   Use a Hugging Face repo or local model path
  --m2-16gb                Apply M2 16 GB single-agent defaults
  --m4-48gb                Apply M4 Max 48 GB single-agent defaults
  --                       Pass all remaining options to mlx_lm.server
  -h, --help               Show this help message

Examples:
  ./run-mlx-server.sh
  ./run-mlx-server.sh --m4-48gb
  ./run-mlx-server.sh --model mlx-community/Qwen3-1.7B-4bit
  ./run-mlx-server.sh --m2-16gb --model mlx-community/Qwen3-4B-Instruct-2507-4bit
  ./run-mlx-server.sh --model mlx-community/Qwen3.6-35B-A3B-4bit-DWQ
  ./run-mlx-server.sh --model ./models/my-local-mlx-model
  ./run-mlx-server.sh --m4-48gb --model mlx-community/Qwen3.6-35B-A3B-4bit-DWQ
  ./run-mlx-server.sh --m4-48gb --model mlx-community/Qwen3.6-35B-A3B-4bit-DWQ -- --log-level DEBUG
EOF
  exit 0
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --m2-16gb)
      m2_16gb=true
      shift
      ;;
    --m4-48gb)
      m4_48gb=true
      shift
      ;;
    --model)
      if [ -z "${2:-}" ]; then
        echo "Error: --model requires a value." >&2
        exit 1
      fi
      model="$2"
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    --)
      shift
      server_args=("$@")
      server_arg_count="$#"
      break
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

if [ "$m2_16gb" = true ] && [ "$m4_48gb" = true ]; then
  echo "Error: choose only one hardware profile." >&2
  exit 1
fi

if [ ! -f "venv/bin/activate" ]; then
  echo "MLX is not installed yet. Run ./setup-mlx.sh first."
  exit 1
fi

source venv/bin/activate

find_cached_mlx_models() {
  local cache_dir="$1"

  if [ ! -d "$cache_dir" ]; then
    return 0
  fi

  find "$cache_dir" -maxdepth 1 -type d -name 'models--mlx-community--*' 2>/dev/null |
    while IFS= read -r dir; do
      local folder
      local repo

      folder="$(basename "$dir")"
      repo="${folder#models--}"
      repo="${repo/--//}"

      if [ -n "$repo" ]; then
        printf '%s\n' "$repo"
      fi
    done |
    sort -u
}

choose_model_from_menu() {
  local options=()
  local labels=()
  local cached_models=()

  while IFS= read -r cached_model; do
    cached_models+=("$cached_model")
  done < <(find_cached_mlx_models "$HF_CACHE_DIR")

  if [ "${#cached_models[@]}" -gt 0 ]; then
    echo "Cached MLX Hugging Face models:"
    echo

    for cached_model in "${cached_models[@]}"; do
      options+=("$cached_model")
      labels+=("cached")
    done
  else
    echo "No cached mlx-community models found in:"
    echo "  $HF_CACHE_DIR"
    echo
    echo "Starter models:"
    echo

    for starter in "${starter_models[@]}"; do
      options+=("${starter%%|*}")
      labels+=("${starter#*|}")
    done
  fi

  options+=("custom")
  labels+=("Type a Hugging Face repo or local path")

  for i in "${!options[@]}"; do
    if [ "${options[$i]}" = "custom" ]; then
      printf '  %d. Custom                                     %s\n' "$((i + 1))" "${labels[$i]}"
    else
      printf '  %d. %-44s %s\n' "$((i + 1))" "${options[$i]}" "${labels[$i]}"
    fi
  done

  echo
  printf 'Choose [1-%d]: ' "${#options[@]}"
  read -r selection

  case "$selection" in
    ''|*[!0-9]*)
      echo "Invalid selection: $selection" >&2
      exit 1
      ;;
  esac

  if [ "$selection" -lt 1 ] || [ "$selection" -gt "${#options[@]}" ]; then
    echo "Selection out of range: $selection" >&2
    exit 1
  fi

  model="${options[$((selection - 1))]}"

  if [ "$model" = "custom" ]; then
    printf 'Enter Hugging Face repo or local path: '
    read -r model

    if [ -z "$model" ]; then
      echo "No model specified." >&2
      exit 1
    fi
  fi
}

if [ -z "$model" ]; then
  choose_model_from_menu
fi

if [[ "$model" == ./* ]]; then
  model="$invocation_dir/${model#./}"
elif [[ "$model" == ../* ]]; then
  model="$invocation_dir/$model"
fi

command=(mlx_lm.server --model "$model" --host 127.0.0.1 --port 8080)

if [ "$m2_16gb" = true ]; then
  memory_bytes="$(sysctl -n hw.memsize 2>/dev/null || true)"
  chip="$(sysctl -n machdep.cpu.brand_string 2>/dev/null || true)"
  if [ "$memory_bytes" != "17179869184" ] || [ "$chip" != "Apple M2" ]; then
    echo "Warning: --m2-16gb was tuned for a base M2 with 16 GB unified memory." >&2
  fi

  command+=(
    --max-tokens 8192
    --prompt-cache-size 2
    --prompt-cache-bytes 3000000000
    --decode-concurrency 1
    --prompt-concurrency 1
    --prefill-step-size 1024
  )
fi

if [ "$m4_48gb" = true ]; then
  memory_bytes="$(sysctl -n hw.memsize 2>/dev/null || true)"
  chip="$(sysctl -n machdep.cpu.brand_string 2>/dev/null || true)"
  if [ "$memory_bytes" != "51539607552" ] || [[ "$chip" != *"M4 Max"* ]]; then
    echo "Warning: --m4-48gb was tuned for an M4 Max with 48 GB unified memory." >&2
  fi

  command+=(
    --max-tokens 8192
    --prompt-cache-size 4
    --prompt-cache-bytes 4000000000
    --decode-concurrency 1
    --prompt-concurrency 1
    --prefill-step-size 4096
  )
fi

if [ "$server_arg_count" -gt 0 ]; then
  command+=("${server_args[@]}")
fi

echo
printf 'Starting: '
printf '%q ' "${command[@]}"
echo

exec "${command[@]}"
