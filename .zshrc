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
alias sjis="iconv -f cp932"
alias utf8_to_sjis="iconv -f UTF8 -t cp932"
alias file-count="ls -1 | wc -l"
function diff_idea () {
    /usr/local/bin/idea diff $(greadlink -f $1) $(greadlink -f $2)
}
alias rm='trash'

alias xss-off-chrome="open -na Google\ Chrome --args --disable-xss-auditor --user-data-dir='/tmp/chrome'"

# ------------------------------------------------------------------------
# anyenv
# ------------------------------------------------------------------------
if [ -d $HOME/.anyenv ] ; then
   export PATH="$HOME/.anyenv/bin:$PATH"
   eval "$(anyenv init - zsh)"
fi

# ------------------------------------------------------------------------
# mysql@5.6 docker化
# ------------------------------------------------------------------------
PATH=/usr/local/opt/mysql@5.6/bin:${PATH}

# ------------------------------------------------------------------------
# mysql@5.6 docker化
# ------------------------------------------------------------------------
#export PATH="/usr/local/opt/mysql@5.6/bin:$PATH"

# ------------------------------------------------------------------------
# postgresql@9.6 docker化
# ------------------------------------------------------------------------
#PATH=/usr/local/opt/postgresql@9.6/bin:${PATH}

# ------------------------------------------------------------------------
# java8 jenvで管理してる
# ------------------------------------------------------------------------
#export JAVA_HOME=`/System/Library/Frameworks/JavaVM.framework/Versions/A/Commands/java_home -v "1.8"`
#PATH=${JAVA_HOME}/bin:${PATH}

# ------------------------------------------------------------------------
# GOPATHで管理してる
# ------------------------------------------------------------------------
GOPATH=$HOME/go
PATH=${GOPATH}/bin:${PATH}

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

# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# ------------------------------------------------------------------------
# docker
# ------------------------------------------------------------------------

# DCT機能の有効化 (改竄チェックon)
DOCKER_CONTENT_TRUST=1
# 自作Imageの実行時は(0=OFF)にする必要あり
#export DOCKER_CONTENT_TRUST=0
