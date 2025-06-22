#!/usr/bin/env bash
# Thanks https://github.com/gh0stzk for this dotfiles installer, i edited some stuff to fit with my needs.
#
#  ▓█████▄  ▒█████  ▄▄▄█████▓  █████▒██▓ ██▓    ▓█████   ██████ 
#  ▒██▀ ██▌▒██▒  ██▒▓  ██▒ ▓▒▓██   ▒▓██▒▓██▒    ▓█   ▀ ▒██    ▒ 
#  ░██   █▌▒██░  ██▒▒ ▓██░ ▒░▒████ ░▒██▒▒██░    ▒███   ░ ▓██▄   
#  ░▓█▄   ▌▒██   ██░░ ▓██▓ ░ ░▓█▒  ░░██░▒██░    ▒▓█  ▄   ▒   ██▒
#  ░▒████▓ ░ ████▓▒░  ▒██▒ ░ ░▒█░   ░██░░██████▒░▒████▒▒██████▒▒
#   ▒▒▓  ▒ ░ ▒░▒░▒░   ▒ ░░    ▒ ░   ░▓  ░ ▒░▓  ░░░ ▒░ ░▒ ▒▓▒ ▒ ░
#   ░ ▒  ▒   ░ ▒ ▒░     ░     ░      ▒ ░░ ░ ▒  ░ ░ ░  ░░ ░▒  ░ ░
#   ░ ░  ░ ░ ░ ░ ▒    ░       ░ ░    ▒ ░  ░ ░      ░   ░  ░  ░  
#     ░        ░ ░                   ░      ░  ░   ░  ░      ░  
#   Script to install my dotfiles
#   Author: vaproh
#   url: https://github.com/Vaproh

CRE=$(tput setaf 1)
CYE=$(tput setaf 3)
CGR=$(tput setaf 2)
CBL=$(tput setaf 4)
BLD=$(tput bold)
CNC=$(tput sgr0)

date=$(date +%Y%m%d-%H%M%S)

logo () {

    local text="${1:?}"
    echo -en "
	               %%%
	        %%%%%//%%%%%
	      %%************%%%
	  (%%//############*****%%
	%%%%%**###&&&&&&&&&###**//
	%%(**##&&&#########&&&##**
	%%(**##*****#####*****##**%%%
	%%(**##     *****     ##**
	   //##   @@**   @@   ##//
	     ##     **###     ##
	     #######     #####//
	       ###**&&&&&**###
	       &&&         &&&
	       &&&////   &&
	          &&//@@@**
	            ..***
    Vaproh Dotfiles\n\n"
    printf ' %s [%s%s %s%s %s]%s\n\n' "${CRE}" "${CNC}" "${CYE}" "${text}" "${CNC}" "${CRE}" "${CNC}"
}


########## ---------- Welcome ---------- ##########

logo "Welcome!"
printf '%s%sThis script will check if you have the necessary dependencies, and if not, it will install them. Then, it will clone my repository in your HOME directory.\nAfter that, it will create a backup of your files, and then copy the new files to your computer.\n\nMy dotfiles DO NOT modify any of your system configurations.\nYou will be prompted for your root password to install missing dependencies and/or to switch to zsh shell if its not your default.\n\nThis script doesnt have the potential power to break your system, it only copies files from my repository to your HOME directory.%s\n\n' "${BLD}" "${CRE}" "${CNC}"

while true; do
    read -rp " Do you wish to continue? [y/N]: " yn
    case $yn in
        [Yy]* ) break ;;
        [Nn]* ) exit ;;
        * ) printf " Error: just write 'y' or 'n'\n\n" ;;
    esac
done
clear

########## ---------- Install packages ---------- ##########

logo "Installing needed packages.."

dependencias=(base-devel bat brightnessctl dunst eza feh gvfs-mtp firefox geany git kitty imagemagick jq \
			        jgmenu libwebp maim mpc mpd neovim ncmpcpp npm pamixer pacman-contrib nodejs \
			        papirus-icon-theme physlock picom playerctl python python-pipx polybar polkit-gnome python-gobject ranger \
			        redshift rofi rustup sxhkd tmux ttf-inconsolata ttf-jetbrains-mono ttf-jetbrains-mono-nerd \
			        ttf-joypixels ttf-terminus-nerd ttf-ubuntu-mono-nerd ueberzug webp-pixbuf-loader xclip xdg-user-dirs \
			        xdo xdotool xsettingsd xorg-xdpyinfo xorg-xkill xorg-xprop xorg-xrandr xorg-xsetroot \
			        xorg-xwininfo zsh noto-fonts noto-fonts-emoji bash-completion bash-language server bat batsignal \
                    breeze breeze-icons btop htop chafa clang clipmenu cmatrix rofi-calc rofi-emoji comicthumb copyq \
                    curl wget docx2txt dunst electron30 electron31 exo lsd ffmpeg ffmpegthumbnailer file \
                    gnome-epub-thumbnailer gnome-keyring gnome-themes-extra gnumeric go gtk2 gtk3 gtk4 gtkmm \
                    hicolor-icon-theme harper http-parser i3lock imagemagick iso-codes kvantum lazygit lesspipe linux-firmware \
                    linux-headers lxrandr libxinerama libxft gd imlib2 libsecret libsecret-docs lua lua-language-server \
                    aerc mpv neofetch neovim vim obsidian pavucontrol-qt poppler qt5ct qt6ct lxappearance reflector \
                    slock sqlite telegram-desktop zoxide xarchiver unrar unzip thunar spotifyd\
                    thunar-volman thunar-archive-plugin thunar-media-tags-plugin thunar-shares-plugin thunar-vcs-plugin)

is_installed() {
    pacman -Q "$1" &> /dev/null
}

printf "%s%sChecking for required packages...%s\n" "${BLD}" "${CBL}" "${CNC}"
for paquete in "${dependencias[@]}"; do
    if ! is_installed "$paquete"; then
        if sudo pacman -S "$paquete" --noconfirm >/dev/null 2>> RiceError.log; then
            printf "%s%s%s %shas been installed succesfully.%s\n" "${BLD}" "${CYE}" "$paquete" "${CBL}" "${CNC}"
            sleep 1
        else
            printf "%s%s%s %shas not been installed correctly. See %sRiceError.log %sfor more details.%s\n" "${BLD}" "${CYE}" "$paquete" "${CRE}" "${CBL}" "${CRE}" "${CNC}"
            sleep 1
        fi
    else
        printf '%s%s%s %sis already installed on your system!%s\n' "${BLD}" "${CYE}" "$paquete" "${CGR}" "${CNC}"
        sleep 1
    fi
done
sleep 5
clear
