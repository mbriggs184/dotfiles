#!/usr/bin/env zsh
# Collect current configs into the repo (safe to run multiple times).

set -e
set -u
set -o pipefail

# Compute repository root (script lives in repo/scripts)
script_directory="${0:A:h}"
repository_directory="${script_directory:h}"

copy_file_if_exists() {
  local source_path="$1"
  local target_path="$2"

  if [[ -f "$source_path" ]]; then
    mkdir -p "$(dirname "$target_path")"
    cp "$source_path" "$target_path"
    echo "Copied file: $source_path -> $target_path"
  else
    echo "Skipped (file not found): $source_path"
  fi
}

copy_directory_contents_if_exists() {
  local source_directory="$1"
  local target_directory="$2"

  if [[ -d "$source_directory" ]]; then
    mkdir -p "$target_directory"
    cp -R "$source_directory/." "$target_directory/"
    echo "Copied directory contents: $source_directory -> $target_directory"
  else
    echo "Skipped (directory not found): $source_directory"
  fi
}

# Karabiner
copy_file_if_exists "$HOME/.config/karabiner/karabiner.json" \
  "$repository_directory/karabiner/karabiner.json"

typeset -a karabiner_json_files
karabiner_json_files=("$HOME/.config/karabiner/assets/complex_modifications/"*.json(N))
if (( ${#karabiner_json_files} )); then
  mkdir -p "$repository_directory/karabiner/assets/complex_modifications"
  for json_file in "${karabiner_json_files[@]}"; do
    cp "$json_file" "$repository_directory/karabiner/assets/complex_modifications/"
    echo "Copied file: $json_file"
  done
else
  echo "No complex modification JSON files found."
fi

# VS Code (Stable)
copy_file_if_exists "$HOME/Library/Application Support/Code/User/settings.json" \
  "$repository_directory/vscode/User/settings.json"

copy_file_if_exists "$HOME/Library/Application Support/Code/User/keybindings.json" \
  "$repository_directory/vscode/User/keybindings.json"

copy_directory_contents_if_exists "$HOME/Library/Application Support/Code/User/snippets" \
  "$repository_directory/vscode/User/snippets"

echo "Collection complete."
