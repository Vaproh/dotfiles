# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# colorscript -r

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export PATH="/home/vaproh/.local/bin/scripts:$PATH"
export PATH="/hone/.local/bin:$PATH"
export EDITOR='vim'
export QT_QPA_PLATFORMTHEME=qt5ct

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
    git
    zsh-autosuggestions
	zsh-syntax-highlighting
	auto-notify
	you-should-use
    fzf-zsh-plugin
    fzf-tab
)

source $ZSH/oh-my-zsh.sh

# Changing "ls" to "exa"
alias ls='lsd'
alias ll='lsd -l'
alias la='lsd -a'
alias l='lsd -F'
alias l.='lsd -a | egrep "^\."'
alias lsla='lsd -la'

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

alias ccat='bat --color auto'


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

eval "$(zoxide init zsh)"
