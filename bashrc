# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# If not in tmux
if [ -z "$TMUX" ]
then
    tmux attach -t home > /dev/null 2>&1 # try to use the default session
    if [ $? -ne 0 ]
    then
        # no session already created so created it
        tmux new -s home
    fi
    exit
fi

# append the history (don't overwrite it)
shopt -s histappend
# not twice the same line and don't save line starting with space
HISTCONTROL=ignoreboth

# the default editor
export EDITOR=emacs
set -o emacs

# Some default option for less
#  no beep (-Q)
#  display colours (-R)
#  don't wrap lines, horizontal scrolling (-S)
export LESS="-QRS"

# save all lines of a multiple-line command in the same history entry
shopt -s cmdhist
# checks the window size after each command and updates it if necessar
shopt -s checkwinsize

# try to change the foreground (setaf) color (red: 1)
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    color=yes
else
    color=
fi

if [ "$color" = yes ]; then
    # user@host:pwd$
    PS1='\[\033[01;32m\]\u\[\033[0m\]@\[\033[01;32m\]\h\[\033[0m\]:\[\033[01;36m\]\w\[\033[0m\]$ '
else
    # user@host:pwd$
    PS1='\u@\h-VM:\w\$ '
fi

# bash completion
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# enable color support of ls and also add handy aliases
if [ "$color" = yes ] && [ -x /usr/bin/dircolors ]; then
    eval "$(dircolors -b)"

    # -F classify: append indicator (one of */=>@|) to entries
    alias ls='ls -F --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    alias egrep='rgrep --color=auto'
fi

# ls
# -l: use a long listing format
# -h: print sizes in human readable formatb
# -F: classify: append indicator (one of */=>@|) to entries
# -A: show hide file but not . and ..
alias ll='ls -lhF'
alias la='ls -AhF'
alias l='ls -hF'

alias cd..='cd ..'
alias cd.='cd ..'
alias cd-='cd -'

# create directory and go to that directory
# -p: create the parent directory if needed
md () { mkdir -p "$1" && cd "$1"; }

# emacs always in console mode
alias emacs='emacs -nw'

alias j='jobs'

alias pep8='pep8 --show-source --statistic --repeat'

#remove tmp file
clean ()
{
    find . -type f \( -name '*~' -o -name '*.o' -o -name '*.pyc' \) -print -delete
    echo $PWD ': cleaned'
}
