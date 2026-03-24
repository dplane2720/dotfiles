#!/usr/bin/env zsh
# macOS Terminal Environment Bootstrap
# Installs: Homebrew, oh-my-zsh, starship, Hack Nerd Font, Claude Code
# Symlinks dotfiles and imports Terminal profile

set -e

DOTFILES="$( cd "$( dirname "$0" )" && pwd )"

echo "\n==> macOS dotfiles bootstrap starting...\n"

# ── Helpers ──────────────────────────────────────────────────────────────────

backup_and_link() {
  local src="$1"
  local dst="$2"
  local dst_dir
  dst_dir="$(dirname "$dst")"

  mkdir -p "$dst_dir"

  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo "  [backup] $dst → ${dst}.backup"
    mv "$dst" "${dst}.backup"
  fi

  ln -sf "$src" "$dst"
  echo "  [linked] $dst → $src"
}

# ── Xcode Command Line Tools ─────────────────────────────────────────────────

if ! xcode-select -p &>/dev/null; then
  echo "==> Installing Xcode Command Line Tools..."
  xcode-select --install
  echo "    Re-run this script after the install completes."
  exit 1
fi

# ── Homebrew ─────────────────────────────────────────────────────────────────

if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add Homebrew to PATH for the rest of this script (Apple Silicon)
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
echo "==> Homebrew ready."

# ── oh-my-zsh ────────────────────────────────────────────────────────────────

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "==> Installing oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
echo "==> oh-my-zsh ready."

# ── Starship ─────────────────────────────────────────────────────────────────

if ! command -v starship &>/dev/null; then
  echo "==> Installing starship..."
  brew install starship
fi
echo "==> Starship ready."

# ── Hack Nerd Font ───────────────────────────────────────────────────────────

if ! fc-list 2>/dev/null | grep -qi "Hack Nerd Font" && \
   ! ls ~/Library/Fonts/HackNerdFont* &>/dev/null; then
  echo "==> Installing Hack Nerd Font..."
  brew install --cask font-hack-nerd-font
fi
echo "==> Hack Nerd Font ready."

# ── Node.js + Claude Code ─────────────────────────────────────────────────────

if ! command -v node &>/dev/null; then
  echo "==> Installing Node.js..."
  brew install node
fi

# Set npm global prefix to ~/.npm-global (matches dotfiles PATH config)
mkdir -p "$HOME/.npm-global"
npm config set prefix "$HOME/.npm-global"

if ! command -v claude &>/dev/null && \
   [ ! -f "$HOME/.npm-global/bin/claude" ]; then
  echo "==> Installing Claude Code..."
  npm install -g @anthropic-ai/claude-code
fi
echo "==> Claude Code ready."

# ── Symlink dotfiles ──────────────────────────────────────────────────────────

echo "\n==> Symlinking dotfiles..."

backup_and_link "$DOTFILES/home/.zshrc"            "$HOME/.zshrc"
backup_and_link "$DOTFILES/home/.gitconfig"         "$HOME/.gitconfig"
backup_and_link "$DOTFILES/home/.gitignore_global"  "$HOME/.gitignore_global"
backup_and_link "$DOTFILES/config/starship.toml"    "$HOME/.config/starship.toml"

# Claude Code statusline (only if .claude dir exists — created by first run of claude)
if [ -d "$HOME/.claude" ]; then
  backup_and_link "$DOTFILES/claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh"
else
  echo "  [skip] ~/.claude not found — run 'claude' once, then re-run this script to link statusline."
fi

# ── Terminal Profile ──────────────────────────────────────────────────────────

PROFILE_FILE="$DOTFILES/terminal/Catppuccin Mocha Terminal.terminal"

if [ -f "$PROFILE_FILE" ]; then
  echo "\n==> Importing Terminal profile..."
  open "$PROFILE_FILE"
  sleep 2  # give Terminal.app time to register the profile
  defaults write com.apple.Terminal "Default Window Settings" "catppuccin-mocha"
  defaults write com.apple.Terminal "Startup Window Settings" "catppuccin-mocha"
  echo "  [done] Set Catppuccin Mocha as default Terminal profile."
fi

# ── Done ──────────────────────────────────────────────────────────────────────

echo "\n✓ Bootstrap complete."
echo "  Start a new terminal session (or run: source ~/.zshrc) to apply changes."
echo ""
echo "  NOTE: Miniforge/conda is machine-specific — install it separately if needed:"
echo "        https://github.com/conda-forge/miniforge"
echo ""
echo "  NOTE: After running 'claude' for the first time, re-run this script"
echo "        to symlink the statusline config (if it was skipped above)."
