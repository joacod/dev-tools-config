# llama.cpp

Run local GGUF models from the terminal with [llama.cpp](https://github.com/ggml-org/llama.cpp).

## Install

Install `llama.cpp` with Homebrew.

```sh
brew install llama.cpp
```

## Verify The Binaries

Check that the main binaries are available.

```sh
llama-cli --help
llama-server --help
```

## Run A Model From Hugging Face

The simplest way to get started is to let `llama.cpp` download a compatible GGUF model from Hugging Face.

```sh
llama-cli -hf ggml-org/gemma-3-1b-it-GGUF
```

Run a one-off prompt:

```sh
llama-cli -hf ggml-org/gemma-3-1b-it-GGUF -p "Explain recursion in simple terms."
```

`llama.cpp` expects models in `GGUF` format. The `-hf <user>/<model>[:quant]` flag downloads a compatible model directly.

## Run A Local GGUF File

If you already have a local model file:

```sh
llama-cli -m /path/to/model.gguf
```

For chat-style use, force conversation mode if needed:

```sh
llama-cli -m /path/to/model.gguf -cnv
```

Many chat models enable conversation mode automatically when the model includes a built-in chat template.

## Run As A Local API Server

Start the local server with a Hugging Face model:

```sh
llama-server -hf ggml-org/gemma-3-1b-it-GGUF --port 8080
```

Or use a local file:

```sh
llama-server -m /path/to/model.gguf --port 8080
```

Then use:

- Browser UI: `http://127.0.0.1:8080`
- API endpoint: `http://127.0.0.1:8080/v1/chat/completions`

`llama-server` is an OpenAI-compatible local HTTP server.

## Apple Silicon Note

`llama.cpp` supports Metal on Apple Silicon, which makes it a strong fit for modern Macs.

## Official References

- [llama.cpp](https://github.com/ggml-org/llama.cpp)
- [Install docs](https://github.com/ggml-org/llama.cpp/blob/master/docs/install.md)
- [Build docs](https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md)
