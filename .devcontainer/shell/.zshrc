# If you come from bash you might have to change your $PATH.

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git ssh F-Sy-H kubectl zsh-autosuggestions)

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#cccccc"

# Disable completion waiting dots - causes character duplication in containers
COMPLETION_WAITING_DOTS="false"

source $ZSH/oh-my-zsh.sh

autoload -U compinit; compinit
fpath=(~/.oh-my-zsh/custom/completions $fpath)

eval "$(starship init zsh)"

source "$HOME/edactl_completion.zsh"

# locale -a shows available locales
# in vscode it was C.UTF-8
export LOCALE="C.UTF-8"

