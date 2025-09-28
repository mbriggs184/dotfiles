# Dotfiles (macOS) — Karabiner + VS Code

Version-controlled configuration for my Mac. All configs live in this repo and are **symlinked** into the locations apps expect.

- Safe, idempotent **bootstrap** that backs up existing files before linking
- One-command **collect** to pull current configs back into the repo
- Simple scripts to **export/install VS Code extensions**
- No system-wide Git config is tracked (so this repo is safe to use on work machines with a different Git identity)

---

## What’s included

- **Karabiner-Elements**
  - `~/.config/karabiner/karabiner.json`
  - `~/.config/karabiner/assets/complex_modifications/`
- **VS Code (Stable)**
  - `~/Library/Application Support/Code/User/settings.json`
  - `~/Library/Application Support/Code/User/keybindings.json`
  - `~/Library/Application Support/Code/User/snippets/`
  - `vscode/extensions.txt` (list of extensions)

Repo layout:
```
dotfiles/
  karabiner/
    karabiner.json
    assets/complex_modifications/
  vscode/
    User/
      settings.json
      keybindings.json
      snippets/
    extensions.txt
  scripts/
    bootstrap.sh
    collect_current_configs.sh
    vscode_extensions_export.sh
    vscode_extensions_install.sh
  README.md
```

---

## Prerequisites

- macOS with Git (`xcode-select --install` if needed)
- **VS Code CLI** in PATH (for extensions scripts):  
  VS Code → `Cmd+Shift+P` → “**Shell Command: Install 'code' command in PATH**”

---

## Quick start (current machine)

1. **Clone** the repo:
   ```bash
   git clone git@github.com:<your-username>/dotfiles.git "$HOME/dotfiles"
   cd "$HOME/dotfiles"
   ```

2. **Collect** your current configs into the repo (safe to run anytime):
   ```bash
   bash scripts/collect_current_configs.sh
   ```

3. **Commit** and push:
   ```bash
   git add .
   git commit -m "Import current configs"
   git push
   ```

4. **Create symlinks** (backs up any real files first):
   ```bash
   bash scripts/bootstrap.sh
   ```

5. **Export VS Code extensions** (optional, recommended):
   ```bash
   ./scripts/vscode_extensions_export.sh
   git add vscode/extensions.txt
   git commit -m "Track VS Code extensions"
   git push
   ```

Verification:
```bash
# Should point into your repo
ls -l ~/.config/karabiner/karabiner.json
ls -l "$HOME/Library/Application Support/Code/User/settings.json"
```

---

## New machine setup

```bash
# 1) Install Git/Xcode CLT, then:
git clone git@github.com:<your-username>/dotfiles.git "$HOME/dotfiles"
cd "$HOME/dotfiles"

# 2) Create symlinks
bash scripts/bootstrap.sh

# 3) Put the VS Code CLI in PATH (inside VS Code: Cmd+Shift+P → Install 'code' command in PATH)

# 4) Install VS Code extensions (if extensions.txt exists)
./scripts/vscode_extensions_install.sh
```

Open Karabiner-Elements once so it reloads the profile.

---

## Scripts

### `scripts/bootstrap.sh` (bash)
Creates symlinks from repo → system locations.

Behavior:
- If the **target** is an existing **symlink** pointing elsewhere, it is updated.
- If the target is a **real file/dir**, it is backed up to `<target>.YYYYMMDD-HHMMSS.bak`, then replaced with a symlink.
- If the **source** is missing, it is skipped.

Run:
```bash
bash scripts/bootstrap.sh
```

### `scripts/collect_current_configs.zsh` (zsh)
Copies current config files from the system into the repo (safe to run repeatedly).

Run:
```bash
zsh scripts/collect_current_configs.zsh
```

### VS Code extensions
- **Export** current extensions to `vscode/extensions.txt`:
  ```bash
  ./scripts/vscode_extensions_export.sh
  ```
- **Install** extensions from `vscode/extensions.txt`:
  ```bash
  ./scripts/vscode_extensions_install.sh
  ```

---

## Adding another file to manage

1. Put the file under version control inside the repo (e.g. `tmux/tmux.conf`).  
2. Add a mapping in **both** places:
   - **bootstrap**: add a line like  
     `link_path "tmux/tmux.conf" "$HOME/.tmux.conf"`
   - **collect**: add a line like  
     `copy_file_if_exists "$HOME/.tmux.conf" "$repository_directory/tmux/tmux.conf"`
3. Run `collect` (to import) or drop the file manually, then run `bootstrap` to link.

Keep mappings minimal and explicit.

---

## Notes and tips

- **No Git config tracked**  
  This repo purposely avoids managing `~/.gitconfig` or related files, so it works cleanly on work machines that use a different Git identity.

- **VS Code keybindings**  
  If you do not have `keybindings.json` yet, create it in `vscode/User/keybindings.json`. The bootstrap will link it; VS Code will read it next launch.

- **Karabiner complex modifications**  
  The entire directory is symlinked for simplicity. Add/remove JSONs in the repo and relaunch Karabiner (or press “Import More Rules” to refresh).

- **Idempotency**  
  You can rerun `collect` and `bootstrap` anytime. Backups are timestamped; clean old backups when you are satisfied.

- **Running from anywhere**  
  Scripts compute the repo root from their own location, so you can invoke them from any working directory.

---

## Troubleshooting

- **Permission denied when running scripts**  
  ```bash
  chmod +x scripts/*.sh scripts/*.zsh
  ```

- **VS Code `code: command not found`**  
  Open VS Code → `Cmd+Shift+P` → “Shell Command: Install 'code' command in PATH”.

- **Symlink not created / wrong target**  
  Re-run:
  ```bash
  bash scripts/bootstrap.sh
  ```
  Then verify with `ls -l` that the path points into `~/dotfiles/...`.

- **Karabiner not updating**  
  Open Karabiner-Elements Preferences once. Confirm the profile shows your rules.

---

## License

Personal configuration. No warranty. Use at your own risk.
