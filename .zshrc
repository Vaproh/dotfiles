# neofetch --kitty ~/Downloads/weirdcore.png --size 350px --gap 3 --crop fit
colorscript -r

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path 
export ZSH="$HOME/.oh-my-zsh"
export PATH="$HOME/.local/bin/scripts:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export EDITOR='nvim'
export QT_QPA_PLATFORMTHEME=qt5ct
export PATH="$HOME/.config/emacs/bin:$PATH"

# ZSH_THEME="powerlevel10k/powerlevel10k"
ZSH_THEME="minimal"

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
alias ls='exa --icons --color=always --group-directories-first'
alias ll='exa -alF --icons --color=always --group-directories-first'
alias la='exa -a --icons --color=always --group-directories-first'
alias l='exa -F --icons --color=always --group-directories-first'
alias l.='exa -a | egrep "^\."'
alias l1='exa --icons --color=always --group-directories-first -1'

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

alias music='tmux new-session -s $$ "tmux source-file ~/.config/ncmpcpp/tsession"'
# _trap_exit() { tmux kill-session -t $$; }

# mpd-discord
alias discord-mpd-on="setsid mpd-discord-rpc &"
alias discord-mpd-off="killall mpd-discord-rpc"

# tty-clock
alias tty-clock='tty-clock -S -c -b -t -n -B'

# update mirrors
alias update-mirrors='sudo reflector --country India --age 12 --sort rate --save /etc/pacman.d/mirrorlist'

# zoxide
eval "$(zoxide init zsh)"

# yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export PATH=$PATH:/home/vaproh/.spicetify

