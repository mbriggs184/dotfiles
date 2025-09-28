#!/usr/bin/env bash
set -euo pipefail

# This script symlinks your tracked config files into the expected OS locations.
# It backs up existing non-symlink files with a timestamp suffix, then links.

# Resolve repository directory even if invoked via symlink
REPOSITORY_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURRENT_TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

create_symbolic_link() {
  local source_relative_path="$1"
  local target_absolute_path="$2"

  local source_absolute_path="${REPOSITORY_DIRECTORY}/${source_relative_path}"

  if [[ ! -e "$source_absolute_path" ]]; then
    echo "Source does not exist: ${source_absolute_path}" >&2
    return 1
  fi

  mkdir -p "$(dirname "$target_absolute_path")"

  if [[ -L "$target_absolute_path" ]]; then
    # Target is an existing symlink.
    local current_link_target
    current_link_target="$(readlink "$target_absolute_path")" || true
    if [[ "$current_link_target" != "$source_absolute_path" ]]; then
      rm -f "$target_absolute_path"
      ln -s "$source_absolute_path" "$target_absolute_path"
      echo "Updated symlink: $target_absolute_path -> $source_absolute_path"
    else
      echo "Symlink already correct: $target_absolute_path"
    fi
  elif [[ -e "$target_absolute_path" ]]; then
    # Target is a regular file or directory. Back it up, then link.
    local backup_path="${target_absolute_path}.${CURRENT_TIMESTAMP}.bak"
    mv "$target_absolute_path" "$backup_path"
    ln -s "$source_absolute_path" "$target_absolute_path"
    echo "Backed up and linked: $target_absolute_path (backup at $backup_path)"
  else
    ln -s "$source_absolute_path" "$target_absolute_path"
    echo "Linked: $target_absolute_path -> $source_absolute_path"
  fi
}

declare -A path_mappings=(
  # Karabiner
  ["karabiner/karabiner.json"]="$HOME/.config/karabiner/karabiner.json"
  ["karabiner/assets/complex_modifications"]="$HOME/.config/karabiner/assets/complex_modifications"

  # VS Code
  ["vscode/User/keybindings.json"]="$HOME/Library/Application Support/Code/User/keybindings.json"
  ["vscode/User/settings.json"]="$HOME/Library/Application Support/Code/User/settings.json"
  ["vscode/User/snippets"]="$HOME/Library/Application Support/Code/User/snippets"
)

for source_relative_path in "${!path_mappings[@]}"; do
  create_symbolic_link "$source_relative_path" "${path_mappings[$source_relative_path]}"
done

echo "Bootstrap complete."
