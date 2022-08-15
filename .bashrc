# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin


function subenum(){
	subfinder -d $1 -all | tee $1.txt
	assestfinder --subs-only $1 | tee -a $1.txt
	domained -d $1 --noeyewitness 
	cat $1.txt | while read i; do ctfr -d $i -o $i.ctfr; done 
	curl -sk "http://web.archive.org/cdx/search/cdx?url=*.$1&output=txt&fl=original&collapse=urlkey&page=" | awk -F/ '{gsub(/:.*/, "", $3); print $3}' | sort -u | tee -a $1.txt
	curl -sk "https://crt.sh/?q=%.$1&output=json" | tr ',' '\n' | awk -F'"' '/name_value/ {gsub(/\*\./, "", $4); gsub(/\\n/,"\n",$4);print $4}' | tee -a $1.txt
	cat $1.txt | sort -u | uniq | tee $1_unique
	rm $1.txt
	altdns -i $1_unique -o $1.known -w /home/ubuntu/altdns.txt -r -s $1.resolved

}

function virtualhost()
{
	vhost --ip=$1 --host=$2 --wordlist=/home/ubuntu/virtual-host-discover/wordlist --output=$2.txt | grep $2 | cut -d " " -f2 | cut -d "/" -f 3 | grep -v __cf_bm | grep -v = | grep $2
}

function sublist()
{
	cat $1 | while read i; do subenum $i; done 
}

function alive()
{
	cat $1 | httpx --ports "80,443,3000,3001,3306,21,444,8080,8443,8888,8082,8888,9000,9001,9002" | tee $1.alive
	cat $1.alive | csp -c 20 | tee $1.csp
} 

function slacknotify(){
	nuclei -t /home/ubuntu/nuclei-templates -l $1 --severity low,medium,high,critical -c 100 -o $1.nuclei | notify -silent
}


function getdirs(){
	ffuf -w $1:URL -w /home/ubuntu/words.txt:WORD -u URL/WORD -t 100 -o  $1.dirs -H "Host: localhost"  -s  -mc 200,301,302,401,403
}

function tldenum(){
	tld  -n -d $1 -i /home/ubuntu/tld_scanner/topTLDs.txt -o $1.tld
	cat $1.tld | tr ':' '\n' | grep $1 | cut -d "/" -f 3 | cut -d '"' -f1 | tee $1.tld2
	rm $1.tld
	mv $1.tld2 $1.tld
	cat $1.tld | while read i; do subenum $i ;done 
}

function gitauto()
{
	gitgraber -k /home/ubuntu/tool/gitGraber/wordlists/keywords.txt -q $1 -s
}
