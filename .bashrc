#
# ~/.bashrc
#
export NVM_DIR="$HOME/.nvm"
source /usr/share/nvm/init-nvm.sh

eval "$(ssh-agent -s)"
eval "$(starship init bash)"
# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
