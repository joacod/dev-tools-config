#!/bin/bash

# Lists cached llama.cpp models, prompts for a selection,
# and starts llama-server in offline mode.

set -euo pipefail

port=8080
ctx_size=""

# Parse optional launcher flags before we query the local llama.cpp cache.
while [ "$#" -gt 0 ]; do
  case "$1" in
    --port)
      if [ "$#" -lt 2 ]; then
        echo "Missing value for --port" >&2
        exit 1
      fi
      port="$2"
      shift 2
      ;;
    --ctx-size)
      if [ "$#" -lt 2 ]; then
        echo "Missing value for --ctx-size" >&2
        exit 1
      fi
      ctx_size="$2"
      shift 2
      ;;
    -h|--help)
      cat <<'EOF'
Usage: run-llama-server.sh [--port PORT] [--ctx-size TOKENS]

Lists cached llama.cpp models, prompts for a selection, and starts llama-server in offline mode.
EOF
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

if ! command -v llama-server >/dev/null 2>&1; then
  echo "llama-server is not installed or not on PATH" >&2
  exit 1
fi

if ! cache_output="$(llama-server --cache-list 2>&1)"; then
  echo "Failed to read the llama.cpp model cache." >&2
  printf '%s\n' "$cache_output" >&2
  exit 1
fi

models=()
# Parse numbered cache entries and keep only the raw repo:quant values.
while IFS= read -r line; do
  if [[ "$line" =~ ^[[:space:]]*[0-9]+\.[[:space:]]+(.+)$ ]]; then
    model="${BASH_REMATCH[1]}"
    if [ -n "$model" ]; then
      models+=("$model")
    fi
  fi
done <<EOF
$cache_output
EOF

if [ "${#models[@]}" -eq 0 ]; then
  echo "No cached models found." >&2
  echo "Run 'llama-server --cache-list' to confirm, or download a model first." >&2
  exit 1
fi

echo "Cached llama.cpp models:"
for i in "${!models[@]}"; do
  printf '  %d. %s\n' "$((i + 1))" "${models[$i]}"
done

echo
printf 'Select a model to run [1-%d]: ' "${#models[@]}"
read -r selection

case "$selection" in
  ''|*[!0-9]*)
    echo "Invalid selection: $selection" >&2
    exit 1
    ;;
esac

if [ "$selection" -lt 1 ] || [ "$selection" -gt "${#models[@]}" ]; then
  echo "Selection out of range: $selection" >&2
  exit 1
fi

model="${models[$((selection - 1))]}"

# Build the server command as an array so quoting stays correct.
command=(llama-server -hf "$model" --offline --port "$port")
if [ -n "$ctx_size" ]; then
  command+=(--ctx-size "$ctx_size")
fi

echo
printf 'Starting: '
printf '%q ' "${command[@]}"
echo

# Replace this script with llama-server so Ctrl+C stops the server directly.
exec "${command[@]}"
