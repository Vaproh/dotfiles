colorscript -r

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export PATH="/home/vaproh/.local/bin/scripts:$PATH"
export PATH="/hone/.local/bin:$PATH"
export EDITOR='vim'
export QT_QPA_PLATFORMTHEME=qt5ct

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(git
       	zsh-autosuggestions
	zsh-syntax-highlighting
	auto-notify
	you-should-use
)

source $ZSH/oh-my-zsh.sh

# Changing "ls" to "exa"
alias ls='exa --icons --color=always --group-directories-first'
alias ll='exa -alF --icons --color=always --group-directories-first'
alias la='exa -a --icons --color=always --group-directories-first'
alias l='exa -F --icons --color=always --group-directories-first'
alias l.='exa -a | egrep "^\."'

# pacman
alias install='sudo pacman -S'
alias uninstall='sudo pacman -Rns'
alias upgrade='sudo pacman -Syu'
alias search='sudo pacman -Ss'

# ytdlp
alias ytbdl="yt-dlp -f bestvideo+bestaudio -o '%(title)s.%(ext)s'"
alias ytmdl="yt-dlp -x -f bestaudio -o '%(title)s.%(ext)s'"
alias ytdl="yt-dlp -f best -o '%(title)s.%(ext)s'"
alias ytpdl="yt-dlp -f best -o '%(playlist_index)s. %(title)s.%(ext)s'"

alias lf=lfrun

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Created by `pipx` on 2024-06-20 10:24:45
export PATH="$PATH:/home/vaproh/.local/bin"
