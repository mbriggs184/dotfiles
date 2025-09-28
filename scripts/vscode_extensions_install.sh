#!/usr/bin/env bash
set -euo pipefail

# Install VS Code (stable) extensions from your dotfiles repo list.
# Usage:
#   ./scripts/vscode_extensions_install.sh

repository_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
extensions_file="${repository_directory}/vscode/extensions.txt"

command_exists() { command -v "$1" >/dev/null 2>&1; }

if ! command_exists code; then
  echo "Error: VS Code CLI 'code' is not in PATH."
  echo "Open VS Code and run: Shell Command: Install 'code' command in PATH"
  exit 1
fi

if [[ ! -f "$extensions_file" ]]; then
  echo "Error: Extensions list not found: ${extensions_file}"
  echo "Run ./scripts/vscode_extensions_export.sh first."
  exit 1
fi

if [[ ! -s "$extensions_file" ]]; then
  echo "No extensions listed in ${extensions_file}. Nothing to install."
  exit 0
fi

# Install one extension ID per line.
xargs -n 1 code --install-extension < "$extensions_file"
echo "Installed extensions from ${extensions_file}"
