#!/usr/bin/env zsh

# {{{ Keychain
if which keychain &> /dev/null
then
      	keychain id_rsa
        . ~/.keychain/${HOST}-sh
fi
# }}}

# {{{ General settings

# History
HISTFILE=~/.histfile
HISTSIZE=5000
SAVEHIST=5000
setopt append_history hist_ignore_all_dups hist_reduce_blanks

source ~/.zalias

# Misc options
setopt auto_list
setopt auto_param_keys
setopt auto_param_slash
setopt autocd
setopt equals
setopt extended_glob
setopt hash_cmds
setopt hash_dirs
setopt numeric_glob_sort
setopt transient_rprompt
unsetopt beep
unsetopt notify

# Color vars
autoload -U colors
colors

# Watch for login/logout
watch=all

# umask
umask 0022

# }}}

# {{{ Keybindings
bindkey -v
bindkey '\e[1~' beginning-of-line
bindkey '\e[3~' delete-char
bindkey '\e[4~' end-of-line
bindkey '\177' backward-delete-char
bindkey '\e[2~' overwrite-mode

bindkey "\e[7~" beginning-of-line
bindkey "\e[H" beginning-of-line
#bindkey "\e[2~" transpose-words
bindkey "\e[8~" end-of-line
bindkey "\e[F" end-of-line
bindkey "\eOH" beginning-of-line
bindkey "\eOF" end-of-line

# Control + h pour l'aide man
bindkey '^h' run-help

# Control + R pour la recherche incremental
bindkey '^r'      history-incremental-search-backward

# Complete help
bindkey '^c' _complete_help

# Ctrl + p to chdir to the parent directory
bindkey -s '^p' '^Ucd ..; ls^M'

# Edit cmdline
autoload edit-command-line
zle -N edit-command-line
bindkey '^e' edit-command-line
bindkey 'x' execute-named-cmd

# () [] {} ...
bindkey -s '((' '()\ei'
bindkey -s '( (' '(   )\ehhi'
bindkey -s '(((' '(\ea(   ))\ehhhi'
bindkey -s '{{' '{}\ei'
bindkey -s '{ {' '{  }\ehi'
bindkey -s '{{{' '{\ea{   }}\ehhhi' # }}} (quick and ugly folding fix...)
bindkey -s '[[' '[]\ei'
bindkey -s '[ [' '[   ]\ehhi'
bindkey -s '[[[' '[\ea[   ]]\ehhhi'
bindkey -s "''" "'\ea'\ei"
bindkey -s '""' '"\ea"\ei'

# }}}

# {{{ File association
alias -s {txt}=vim

alias -s {chm,CHM}=xdg-open
alias -s {pdf,PDF,ps,djvu,DjVu}=xdg-open
alias -s {pdf,PDF,ps,djvu,DjVu}=xdg-open
alias -s {rar,Rar,RAR,zip,Zip,ZIP}=xdg-open
alias -s {php,css,js,htm,html}="$EDITOR"
alias -s {jpeg,jpg,JPEG,JPG,png,gif,xpm}="$IMAGE_VIEWER"
alias -s {avi,AVI,Avi,divx,DivX,mkv,mpg,mpeg,wmv,WMV,mov,rm,flv,ogm,ogv,mp4}=mplayer
alias -s {aac,ape,au,hsc,flac,gbs,gym,it,lds,ogg,m4a,mod,mp2,mp3,MP3,Mp3,mpc,nsf,nsfe,psf,sid,spc,stm,s3m,vgm,vgz,wav,wma,wv,xm}="$MUSIC_PLAYER"

# }}}

# {{{ Completion

autoload -Uz compinit
autoload -Uz complist
compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' completer _complete _correct _approximate
zstyle ':completion:*' max-errors 2 not-numeric
zstyle ':completion:*:approximate:::' max-errors 3 numeric
zstyle ':completion:*' group-name ''
zstyle ':completion:*' insert-unambiguous true
zstyle ':completion:*' original true
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*:rm:*' ignore-line yes

zstyle ':completion:*:processes' command 'ps -ax'
zstyle ':completion:*:processes-names' command 'ps -aeo comm='

zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*'   force-list always
zstyle ':completion:*:*:killall:*:processes-names' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:*:killall:*' menu yes select

# }}}

# {{{ Per OS settings

case `uname -s` in
  FreeBSD)
    export LSCOLORS="exgxfxcxcxdxdxhbadacec"
    alias ls="ls -G"
    alias ll="ls -h -l -D '%F %T'"
    ZCOLORS="no=00:fi=00:di=00;34:ln=00;36:pi=00;32:so=00;35:do=00;35:bd=00;33:cd=00;33:or=05;37;41:mi=05;37;41:su=37;41:sg=30;43:tw=30;42:ow=34;42:st=37;44:ex=00;32:"
    zstyle ':completion:*' list-colors ${(s.:.)ZCOLORS}
    ;;
  Linux)
    if [[ -r ~/.dir_colors ]]; then
      eval `dircolors -b ~/.dir_colors`
    elif [[ -r /etc/DIR_COLORS ]]; then
      eval `dircolors -b /etc/DIR_COLORS`
    else
      eval `dircolors`
    fi
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
    alias ls="ls --color=auto"
    alias ll="ls -h -l --time-style='+%F %T'"
    which bsdtar >/dev/null && alias tar="bsdtar"
    ;;
esac

# }}}

# {{{ General aliases

alias :e="\$EDITOR"
alias :q="exit"
alias l="ls -A -F"
alias la="ls -a"
alias grep="grep --color=auto"
alias egrep="egrep --color=auto"
alias iroute="netstat -nr -f inet"

# }}}

# {{{ Prompts

# Git prompt
#if [ -f "$HOME/.zsh/git-prompt/zshrc.sh" ]; then
#  source "$HOME/.zsh/git-prompt/zshrc.sh"
#  #ZSH_THEME_GIT_PROMPT_NOCACHE=1
#  HAS_GIT_PROMPT=1
#fi

# Right prompt with clock
RPS1="  %{$fg_no_bold[yellow]%}%D{%d/%m/%y %H:%M:%S}%{${reset_color}%}"

# Others prompts
PS2="%{$fg_no_bold[yellow]%}%_>%{${reset_color}%} "
PS3="%{$fg_no_bold[yellow]%}?#%{${reset_color}%} "

# }}}

# {{{ title()

# Display the title
function title {
  local t="%n@%m %~"

  case $TERM in
    screen) # and tmux
      print -nP "\ek$t\e\\"
      print -nP "\e]0;$t\a"
      ;;
    xterm*|rxvt*|(E|e)term)
      print -nP "\e]0;$t\a"
      ;;
  esac
}

# }}}

# {{{ precmd()

function precmd {
  # Set window title
  title

  # Color for non-text things
  local misc="%{${fg_no_bold[white]}%}"

  # Change path color given user rights on it
  if [[ -O "${PWD}" ]]; then # owner
    local path_color="${fg_bold[yellow]}"
  elif [[ -w "${PWD}" ]]; then # can write
    local path_color="${fg_bold[blue]}"
  else # other
    local path_color="${fg_bold[red]}"
  fi

  if [[ $UID = 0 ]]; then
    local login_color="${fg_bold[red]}"
  else
    local login_color="${fg_bold[green]}"
  fi

  # Jailed ?
  if [[ "`uname -s`" = 'FreeBSD' && "`sysctl -n security.jail.jailed 2>/dev/null`" = 1 ]]; then
    local jailed="${misc}(%{${fg_no_bold[yellow]}%}jail${misc})"
  else
    local jailed=""
  fi
  # Display return code when not 0
  local return_code="%(?..${misc}!%{${fg_no_bold[red]}%}%?${misc}! )"
  # Host
  local host="%{${fg_no_bold[cyan]}%}%m"
  # User
  local user="${misc}[%{${login_color}%}%n${misc}]"
  # Current path
  local cwd="%{${path_color}%}%48<...<%~"
  # Red # for root, green % for user
  local sign="%{${login_color}%}%#"

  # Git
  if [ -n "$HAS_GIT_PROMPT" ]; then
    local git_status="\$(git_super_status)"
  else
    local git_status=""
  fi

  # Set the prompt
  PS1="${return_code}${host}${jailed} ${user} ${cwd}${git_status} ${sign}%{${reset_color}%} "
}

# }}}

# {{{ extract()

extract () {
        if [ -f $1 ] ; then
           case $1 in
                *.tar.bz2) tar xvjf $1 ;;
                *.tar.gz) tar xvzf $1 ;;
                *.bz2) bunzip2 $1 ;;
                *.rar) rar x $1 ;;
                *.gz) gunzip $1 ;;
                *.tar) tar xvf $1 ;;
                *.tbz2) tar xvjf $1 ;;
                *.tgz) tar xvzf $1 ;;
                *.zip) unzip $1 ;;
                *.Z) uncompress $1 ;;
                *.7z) 7z x $1 ;;
                *) echo "don't know how to extract '$1′…" ;;
            esac
        else
                echo "'$1′ is not a valid file!"
        fi
}


# }}}

# {{{ run-help-sudo

function run-help-sudo {
  if [ $# -eq 0 ]; then
    man sudo
  else
    man $1
  fi
}

# }}}

# {{{ Others Functions 
# URL encode something and print it.
function url-encode; {
        setopt extendedglob
        echo "${${(j: :)@}//(#b)(?)/%$[[##16]##${match[1]}]}"
}

# Search google for the given keywords.
function google; {
        elinks "http://www.google.com/search?q=`url-encode "${(j: :)@}"`"
}

# }}}

# {{{ Reminder

if [[ -f ~/.zshrc.local ]]; then
  source ~/.zshrc.local
fi

# }}}

# {{{ Reminder

if [[ -f ~/.reminder ]]; then
  cat ~/.reminder
fi

# }}}

: # noop

# vim:filetype=zsh:tabstop=2:shiftwidth=2:fdm=marker:
