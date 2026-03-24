# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="robbyrussell"

# Uncomment one of the following lines to change the auto-update behavior
zstyle ':omz:update' mode auto      # update automatically without asking

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration
ulimit -n 10240 # increases the default max number of open files

# Export Homebrew Paths:
export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
export PATH="/opt/homebrew/opt/python@2/libexec/bin:$PATH"
export PATH="/opt/homebrew/opt/apr/bin:$PATH"

# npm global (Claude Code, etc.)
export PATH=~/.npm-global/bin:$PATH

# use starship (terminal prompt)
eval "$(starship init zsh)"

## Miniforge / Conda (machine-specific — only loads if miniforge3 is installed)
__conda_setup="$("$HOME/miniforge3/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/miniforge3/etc/profile.d/conda.sh" ]; then
        . "$HOME/miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/miniforge3/bin:$PATH"
    fi
fi
unset __conda_setup

# Fabric bootstrap (loads if fabric is installed)
if [ -f "$HOME/.config/fabric/fabric-bootstrap.inc" ]; then
    . "$HOME/.config/fabric/fabric-bootstrap.inc"
fi

# LM Studio CLI (loads if lms is installed)
export PATH="$PATH:$HOME/.cache/lm-studio/bin"
