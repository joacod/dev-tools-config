#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")"

echo "Creating Python virtual environment if needed..."
python3 -m venv venv

echo "Activating venv and upgrading pip..."
source venv/bin/activate
python -m pip install --upgrade pip

echo "Installing or upgrading mlx-lm..."
python -m pip install --upgrade mlx-lm

echo
echo "Verifying mlx_lm.server is available..."
command -v mlx_lm.server
mlx_lm.server --help >/dev/null

echo
echo "Setup complete. mlx-lm is installed and ready."
