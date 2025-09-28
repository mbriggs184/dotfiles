#!/usr/bin/env bash
set -euo pipefail

# Symlink tracked config files/directories from this repository into their expected locations.
# Existing non-symlink targets are backed up with a timestamp, then replaced with a symlink.

# Resolve repository directory even if invoked via a symlink
REPOSITORY_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURRENT_TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

link_path() {
  local source_relative_path="$1"
  local target_absolute_path="$2"

  local source_absolute_path="${REPOSITORY_DIRECTORY}/${source_relative_path}"

  # Skip missing sources to keep the script idempotent and friendly
  if [[ ! -e "$source_absolute_path" ]]; then
    echo "Skip: source not found -> ${source_absolute_path}"
    return 0
  fi

  mkdir -p "$(dirname "$target_absolute_path")"

  # If the target is already a symlink, update it only if it points elsewhere
  if [[ -L "$target_absolute_path" ]]; then
    local current_link_target
    current_link_target="$(readlink "$target_absolute_path")" || current_link_target=""
    if [[ "$current_link_target" == "$source_absolute_path" ]]; then
      echo "Symlink already correct: $target_absolute_path"
      return 0
    fi
    rm -f "$target_absolute_path"
  fi

  # If a real file/dir exists, back it up before linking
  if [[ -e "$target_absolute_path" ]]; then
    local backup_path="${target_absolute_path}.${CURRENT_TIMESTAMP}.bak"
    mv "$target_absolute_path" "$backup_path"
    echo "Backed up existing path to ${backup_path}"
  fi

  ln -s "$source_absolute_path" "$target_absolute_path"
  echo "Linked: $target_absolute_path -> $source_absolute_path"
}

# Mappings: one line per file or directory you want to manage.
# (Directories are linked as directories, which works well for Karabiner assets and VS Code snippets.)

# Karabiner
link_path "karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json"
link_path "karabiner/assets/complex_modifications" "$HOME/.config/karabiner/assets/complex_modifications"

# VS Code (Stable)
link_path "vscode/User/keybindings.json" "$HOME/Library/Application Support/Code/User/keybindings.json"
link_path "vscode/User/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
link_path "vscode/User/snippets" "$HOME/Library/Application Support/Code/User/snippets"

echo "Bootstrap complete."
