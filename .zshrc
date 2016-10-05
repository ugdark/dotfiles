# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh
DOT=$HOME/.dotfiles

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="robbyrussell"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable bi-weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment to change how many often would you like to wait before auto-updates occur? (in days)
# export UPDATE_ZSH_DAYS=13

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# plugins=(git cp sudo knife scala gem node npm nvm vagrant)
 plugins=(git cp sudo knife scala gem node nvm vagrant)

source $ZSH/oh-my-zsh.sh

export LC_ALL=en_US.UTF-8
export LANG=ja_JP.UTF-8

# ------------------------------------------------------------------------
# alias
# ------------------------------------------------------------------------
alias vi='/usr/bin/vim'
# ssh をまとめる
alias ssh-config-update="cat ~/.ssh/conf.d/common-config ~/.ssh/conf.d/*.conf > ~/.ssh/config"

# ------------------------------------------------------------------------
# anyenv
# ------------------------------------------------------------------------
if [ -d $HOME/.anyenv ] ; then
    export PATH="$HOME/.anyenv/bin:$PATH"
    eval "$(anyenv init - zsh)"
fi

# anyenv -all in one
export PATH="${HOME}/.anyenv/bin:${PATH}"
eval "$(anyenv init - zsh)"

# ------------------------------------------------------------------------
# node
# node setting localの.binを読み込む用にする コマンド補完が効かないので他にいいのが知りたい
# ------------------------------------------------------------------------
PATH=./node_modules/.bin:${PATH}


# ------------------------------------------------------------------------
# ヒストリ(履歴)を保存、数を増やす
# ------------------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000


# ------------------------------------------------------------------------
# cool-peco コマンド保管強化
# ------------------------------------------------------------------------

source $DOT/peco.sh
