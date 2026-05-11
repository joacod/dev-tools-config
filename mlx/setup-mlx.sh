#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")"

echo "Setting up mlx-lm..."

if [ ! -d "venv" ]; then
  echo "Creating Python virtual environment..."
  python3 -m venv venv
else
  echo "Using existing Python virtual environment..."
fi

echo "Activating venv..."
source venv/bin/activate

echo "Upgrading pip..."
python -m pip install --upgrade pip

echo "Installing or upgrading mlx-lm..."
python -m pip install --upgrade mlx-lm

echo
echo "Verifying mlx_lm.server is available..."
command -v mlx_lm.server
mlx_lm.server --help >/dev/null

echo
echo "Setup complete. mlx-lm is installed and ready."
echo
echo "Next:"
echo "  ./run-mlx-server.sh"