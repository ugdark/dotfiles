# poco 設定

DOT=$HOME/.dotfiles
# === cool-peco init ===
FPATH="$FPATH:${DOT}/cool-peco"
autoload -Uz cool-peco
cool-peco
# ======================


function peco-select-history() {
    local tac
    if which tac > /dev/null; then
        tac="tac"
    else
        tac="tail -r"
    fi
    BUFFER=$(\history -n 1 | \
        eval $tac | \
        peco --query "$LBUFFER")
    CURSOR=$#BUFFER
    zle clear-screen
}
zle -N peco-select-history

bindkey '^r' cool-peco-history # ctrl+r
bindkey '^h' cool-peco-ssh
bindkey '^p' cool-peco-ps

alias ff=cool-peco-filename-search
alias gbb=cool-peco-git-checkout
alias gll=cool-peco-git-log
alias ta=cool-peco-tmux-session
alias cg=cool-peco-ghq

