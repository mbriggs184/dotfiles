#!/usr/bin/env bash
set -euo pipefail

# Export VS Code (stable) extensions into your dotfiles repo.
# Usage:
#   ./scripts/vscode_extensions_export.sh

repository_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
extensions_directory="${repository_directory}/vscode"
extensions_file="${extensions_directory}/extensions.txt"

command_exists() { command -v "$1" >/dev/null 2>&1; }

if ! command_exists code; then
  echo "Error: VS Code CLI 'code' is not in PATH."
  echo "Open VS Code and run: Shell Command: Install 'code' command in PATH"
  exit 1
fi

mkdir -p "$extensions_directory"
code --list-extensions | sort > "$extensions_file"
echo "Wrote ${extensions_file}"
