export EDITOR=nvim
export MANPAGER="nvim -c MANPAGER -"
export PURE_PROMPT_SYMBOL=">"

alias ls='ls -lha --color=always'

HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS

autoload -U compinit; compinit
autoload -U promptinit; promptinit
prompt pure

bindkey -e
bindkey '^f' forward-word
bindkey '^b' backward-word

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
