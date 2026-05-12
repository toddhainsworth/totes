#!/usr/bin/env bash
set -e

for cmd in git nvim; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "error: $cmd is required but not installed."; exit 1; }
done

REPO_URL="https://github.com/toddhainsworth/totes.git"
INSTALL_DIR="$HOME/.local/share/totes"
BIN_DIR="$INSTALL_DIR/bin"
PATH_LINE='export PATH="$HOME/.local/share/totes/bin:$PATH"'

if [ -d "$INSTALL_DIR/.git" ]; then
  echo "totes is already installed at $INSTALL_DIR"
  exit 0
fi

echo "Installing totes to $INSTALL_DIR..."
git clone --filter=blob:none "$REPO_URL" "$INSTALL_DIR"
chmod +x "$BIN_DIR/totes"

# Add to PATH in the user's shell rc file
add_to_path() {
  local rc="$1"
  [ -f "$rc" ] || return 1
  grep -qF "totes/bin" "$rc" && return 0
  echo "$PATH_LINE" >> "$rc"
  echo "Added totes to PATH in $rc"
}

for rc in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile"; do
  add_to_path "$rc" && break
done

echo ""
echo "totes installed. Restart your shell (or source your rc file), then run: totes"
