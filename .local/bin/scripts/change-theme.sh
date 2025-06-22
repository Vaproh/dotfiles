#!/bin/bash

###############################################################################
# ████████╗██╗  ██╗███████╗███╗   ███╗███████╗    ███████╗██╗    ██╗██╗███╗   ██╗
# ╚══██╔══╝██║  ██║██╔════╝████╗ ████║██╔════╝    ██╔════╝██║    ██║██║████╗  ██║
#    ██║   ███████║█████╗  ██╔████╔██║█████╗      █████╗  ██║ █╗ ██║██║██╔██╗ ██║
#    ██║   ██╔══██║██╔══╝  ██║╚██╔╝██║██╔══╝      ██╔══╝  ██║███╗██║██║██║╚██╗██║
#    ██║   ██║  ██║███████╗██║ ╚═╝ ██║███████╗    ██║     ╚███╔███╔╝██║██║ ╚████║
#    ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝╚══════╝    ╚═╝      ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝
###############################################################################

# === Paths and Constants ===
SCRIPT_DIR="$HOME/.script_stuff/theme-switcher"
LOG_FILE="$SCRIPT_DIR/theme-switcher.log"
BACKUP_DIR="$SCRIPT_DIR/backups"
KITTY_CONF="$HOME/.config/kitty/kitty.conf"
WAYBAR_CSS="$HOME/.config/waybar/style.css"
SWAYNC_CSS="$HOME/.config/swaync/style.css"
WOFI_CSS="$HOME/.config/wofi/style.css"
HYPER_CONF="$HOME/.config/hypr/categories/look-and-feel.conf"
WLOGOUT_CSS="$HOME/.config/wlogout/style.css"

WLOGOUT_THEME_DIR="$HOME/.config/wlogout/themes"
SCHEMES_DIR="$HOME/.config/kitty/terminal-schemes"
WAYBAR_THEME_DIR="$HOME/.config/waybar/themes"
SWAYNC_THEME_DIR="$HOME/.config/swaync/themes"
WOFI_THEME_DIR="$HOME/.config/wofi/themes"

PYWAL_CACHE="$HOME/.cache/wal"
PYWAL_TEMPLATE_DIR="$HOME/wal/templates"
PYWAL_THEME_NAME="pywal"

QUIET=0
AUTO_YES=0
MENU_STYLE="fuzzy"
USE_BAT=0

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

mkdir -p "$SCRIPT_DIR" "$BACKUP_DIR"
exec > >(tee -a "$LOG_FILE") 2> >(tee -a "$LOG_FILE" >&2)

# Use bat if available
if command -v bat &>/dev/null; then
    USE_BAT=1
fi

# === Functions ===
log() {
    [ "$QUIET" -eq 0 ] && echo -e "$1"
}

backup_file() {
    local file="$1"
    local name ts backup
    name=$(basename "$file")
    ts=$(date +%Y%m%d%H%M%S)
    backup="$BACKUP_DIR/${name}_$ts.bak"
    cp "$file" "$backup"
    log "${GREEN}✔ Backup created: $backup${NC}"
    ls -1t "$BACKUP_DIR/${name}_"*.bak 2>/dev/null | tail -n +11 | xargs -r rm --
}

show_help() {
    echo -e "${YELLOW}Usage:${NC} $0 [options] [theme-name]"
    echo ""
    echo -e "${YELLOW}Options:${NC}"
    echo -e "  -q, --quiet         Suppress output"
    echo -e "  -y, --yes           Automatically confirm changes"
    echo -e "  -m, --menu          Use arrow-key number menu instead of fuzzy search"
    echo -e "  -w, --wofi          Use Wofi graphical menu to select theme"
    echo -e "      --help          Show this help message"
    exit 0
}

# === Option Parsing ===
POSITIONAL=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        -q|--quiet) QUIET=1; shift ;;
        -y|--yes) AUTO_YES=1; shift ;;
        -m|--menu) MENU_STYLE="menu"; shift ;;
        -w|--wofi) MENU_STYLE="wofi"; shift ;;
        --help) show_help ;;
        -*) echo -e "${RED}Unknown option: $1${NC}"; exit 1 ;;
        *) POSITIONAL+=("$1"); shift ;;
    esac
done
set -- "${POSITIONAL[@]}"

# === Theme Selection ===
THEMES=()
for kitty_file in "$SCHEMES_DIR"/*.conf; do
    BASE=$(basename "${kitty_file%.conf}")
    if [[ -f "$WAYBAR_THEME_DIR/$BASE.css" && -f "$SWAYNC_THEME_DIR/$BASE.css" && -f "$WOFI_THEME_DIR/$BASE.css" && -f "$WLOGOUT_THEME_DIR/$BASE.css" ]]; then
        THEMES+=("$BASE")
    fi
done
IFS=$'\n' THEMES=($(sort <<<"${THEMES[*]}")); unset IFS

if [ ${#THEMES[@]} -eq 0 ]; then
    echo -e "${RED}No matching themes found across Kitty, Waybar, SwayNC, and Wofi.${NC}"
    exit 1
fi

if [ -z "$1" ]; then
    if [ "$MENU_STYLE" = "fuzzy" ] && ! command -v fzf &>/dev/null; then
        echo -e "${YELLOW}fzf not found, switching to menu.${NC}"
        MENU_STYLE="menu"
    fi

    case "$MENU_STYLE" in
        fuzzy)
            THEME=$(printf "%s\n" "${THEMES[@]}" | fzf --prompt="Select Theme: ")
            ;;
        menu)
            echo -e "${YELLOW}Available Themes:${NC}"
            select T in "${THEMES[@]}"; do
                if [[ -n "$T" ]]; then THEME="$T"; break; fi
                echo -e "${RED}Invalid selection.${NC}"
            done
            ;;
        wofi)
            if ! command -v wofi &>/dev/null; then
                echo -e "${RED}Wofi not found!${NC}"; exit 1
            fi
            THEME=$(printf "%s\n" "${THEMES[@]}" | wofi --dmenu --prompt="Select Theme: ")
            ;;
        *)
            echo -e "${RED}Unknown menu style: $MENU_STYLE${NC}"
            exit 1
            ;;
    esac

    [[ -z "$THEME" ]] && echo -e "${RED}Cancelled.${NC}" && exit 1
else
    THEME="$1"
    if [[ ! " ${THEMES[*]} " =~ " ${THEME} " ]]; then
        echo -e "${RED}Theme '${THEME}' must exist in all directories.${NC}"
        exit 1
    fi
fi

# === Pywal Flow ===
if [[ "$THEME" == "$PYWAL_THEME_NAME" ]]; then
    CONFIG="$HOME/.config/waypaper/config.ini"
    log "${YELLOW}🎨 Pywal mode selected. Launching Waypaper...${NC}"
    waypaper &
    WP_PID=$!
    inotifywait -q -e close_write "$CONFIG" >/dev/null
    kill "$WP_PID" 2>/dev/null
    WALLPAPER_RAW=$(grep -Po '(?<=wallpaper = ).*' "$CONFIG")
    WALLPAPER_PATH="${WALLPAPER_RAW/#\~/$HOME}"

    if [[ ! -f "$WALLPAPER_PATH" ]]; then
        log "${RED}❌ Invalid wallpaper path: $WALLPAPER_PATH${NC}"
        exit 1
    fi

    log "${GREEN}✔ Wallpaper selected: $WALLPAPER_PATH${NC}"

    wal -i "$WALLPAPER_PATH" --backend hex --saturate 0.7

    for TARGET in "$WAYBAR_THEME_DIR" "$SWAYNC_THEME_DIR" "$WOFI_THEME_DIR"; do
        if cp "$PYWAL_CACHE/colors-apps.css" "$TARGET/$PYWAL_THEME_NAME.css"; then
            log "${GREEN}✔ Copied colors-apps.css to $TARGET${NC}"
        else
            log "${RED}❌ Failed to copy to $TARGET${NC}"
        fi
    done

    if cp "$PYWAL_CACHE/colors-kitty.conf" "$SCHEMES_DIR/$PYWAL_THEME_NAME.conf"; then
        log "${GREEN}✔ Copied colors-kitty.conf to Kitty schemes${NC}"
    else
        log "${RED}❌ Failed to copy colors-kitty.conf to Kitty${NC}"
    fi

    log "${GREEN}✅ Pywal theme generated and copied to theme folders${NC}"
fi

# === Show Diffs ===
log "${YELLOW}📄 Kitty diff:${NC}"
KITTY_DIFF=$(mktemp)
sed "s|^include terminal-schemes/.*|include terminal-schemes/${THEME}.conf|" "$KITTY_CONF" | diff -u "$KITTY_CONF" - > "$KITTY_DIFF"
[ "$USE_BAT" -eq 1 ] && bat --plain --paging=never --language=diff "$KITTY_DIFF" || cat "$KITTY_DIFF"

log "${YELLOW}📄 Waybar diff:${NC}"
WAYBAR_DIFF=$(mktemp)
sed "s|^@import \"./themes/.*\";|@import \"./themes/${THEME}.css\";|" "$WAYBAR_CSS" | diff -u "$WAYBAR_CSS" - > "$WAYBAR_DIFF"
[ "$USE_BAT" -eq 1 ] && bat --plain --paging=never --language=diff "$WAYBAR_DIFF" || cat "$WAYBAR_DIFF"

log "${YELLOW}📄 SwayNC diff:${NC}"
SWAYNC_DIFF=$(mktemp)
sed "s|^@import \"./themes/.*\";|@import \"./themes/${THEME}.css\";|" "$SWAYNC_CSS" | diff -u "$SWAYNC_CSS" - > "$SWAYNC_DIFF"
[ "$USE_BAT" -eq 1 ] && bat --plain --paging=never --language=diff "$SWAYNC_DIFF" || cat "$SWAYNC_DIFF"

log "${YELLOW}📄 Wofi diff:${NC}"
WOFI_DIFF=$(mktemp)
sed "s|^@import url('file://.*/wofi/themes/.*');|@import url('file://${WOFI_THEME_DIR}/${THEME}.css');|" "$WOFI_CSS" | diff -u "$WOFI_CSS" - > "$WOFI_DIFF"
[ "$USE_BAT" -eq 1 ] && bat --plain --paging=never --language=diff "$WOFI_DIFF" || cat "$WOFI_DIFF"

log "${YELLOW}📄 Wlogout diff:${NC}"
WLOGOUT_DIFF=$(mktemp)
sed "s|^@import url(\"themes/.*\.css\");|@import url(\"themes/${THEME}.css\");|" "$WLOGOUT_CSS" | diff -u "$WLOGOUT_CSS" - > "$WLOGOUT_DIFF"
[ "$USE_BAT" -eq 1 ] && bat --plain --paging=never --language=diff "$WLOGOUT_DIFF" || cat "$WLOGOUT_DIFF"


# === Confirm Before Applying ===
if [ "$AUTO_YES" -eq 0 ]; then
    echo -en "${YELLOW}Apply these changes? [y/N]: ${NC}"
    read -r CONFIRM
    [[ "$CONFIRM" =~ ^[Yy]$ ]] || {
        echo -e "${RED}Aborted.${NC}"
        rm "$KITTY_DIFF" "$WAYBAR_DIFF" "$SWAYNC_DIFF" "$WOFI_DIFF"
        exit 1
    }
fi

# === Apply Changes ===
backup_file "$KITTY_CONF"
backup_file "$WAYBAR_CSS"
backup_file "$SWAYNC_CSS"
backup_file "$WOFI_CSS"
backup_file "$HYPER_CONF"
backup_file "$WLOGOUT_CSS"


# Rewrite theme references
sed -i "s|^include terminal-schemes/.*|include terminal-schemes/${THEME}.conf|" "$KITTY_CONF"
sed -i "s|^@import \"./themes/.*\";|@import \"./themes/${THEME}.css\";|" "$WAYBAR_CSS"
sed -i "s|^@import \"./themes/.*\";|@import \"./themes/${THEME}.css\";|" "$SWAYNC_CSS"
sed -i "s|^@import url('file://.*/wofi/themes/.*');|@import url('file://${WOFI_THEME_DIR}/${THEME}.css');|" "$WOFI_CSS"
sed -i "s|^@import url(\"themes/.*\.css\");|@import url(\"themes/${THEME}.css\");|" "$WLOGOUT_CSS"

# Update theme-current
echo "$THEME" > "$HOME/.config/theme-current"

# === Hyprland Border Color Sync ===
update_hypr_border_colors() {
    local theme_css="$WAYBAR_THEME_DIR/$THEME.css"
    [[ ! -f "$theme_css" ]] && log "${YELLOW}⚠ Waybar theme file not found for Hyprland color update.${NC}" && return

    local active=$(grep -oP '@define-color\s+color0\s+\K#[a-fA-F0-9]+' "$theme_css")
    local inactive=$(grep -oP '@define-color\s+background\s+\K#[a-fA-F0-9]+' "$theme_css")

    [[ -z "$active" ]] && active="#3f4451"
    [[ -z "$inactive" ]] && inactive="#23272e"

    local active_rgba="rgba(${active:1:2}${active:3:2}${active:5:2}aa)"
    local inactive_rgba="rgba(${inactive:1:2}${inactive:3:2}${inactive:5:2}aa)"

    sed -i -E "s|col\.active_border\s*=.*|col.active_border = ${active_rgba}|" "$HYPER_CONF"
    sed -i -E "s|col\.inactive_border\s*=.*|col.inactive_border = ${inactive_rgba}|" "$HYPER_CONF"

    log "${GREEN}🎨 Hyprland border colors updated.${NC}"
    hyprctl reload >/dev/null 2>&1 && log "${GREEN}🔁 Hyprland reloaded.${NC}"
}

# === Hyprlock Color Sync ===
update_hyprlock_colors() {
    local theme_css="$WAYBAR_THEME_DIR/$THEME.css"
    local hyprlock_conf="$HOME/.config/hypr/hyprlock.conf"
    [[ ! -f "$theme_css" || ! -f "$hyprlock_conf" ]] && log "${YELLOW}⚠ Missing theme CSS or Hyprlock config.${NC}" && return

    local bg=$(grep -oP '@define-color\s+background\s+\K#[a-fA-F0-9]+' "$theme_css")
    local fg=$(grep -oP '@define-color\s+(color15|foreground)\s+\K#[a-fA-F0-9]+' "$theme_css" | head -n1)

    [[ -z "$bg" ]] && bg="#1e1e2e"
    [[ -z "$fg" ]] && fg="#cdd6f4"

    backup_file "$hyprlock_conf"

    sed -i -E \
        -e "s|^( *color = ).*|\1$fg|" \
        -e "s|^( *background_color = ).*|\1$bg|" \
        -e "s|^( *ring_color = ).*|\1$fg|" \
        -e "s|^( *circle_color = ).*|\1$fg|" \
        -e "s|^( *text_color = ).*|\1$fg|" \
        "$hyprlock_conf"

    log "${GREEN}🔒 Hyprlock colors updated to match theme '${THEME}'${NC}"
}

# Running all the hyprland stuff

update_hypr_border_colors
update_hyprlock_colors


# Generate colors.json from theme CSS for Pywalfox
generate_pywalfox_json() {
    local css_file="$WAYBAR_THEME_DIR/$THEME.css"
    local wal_json="$HOME/.cache/wal/colors.json"

    if [[ ! -f "$css_file" ]]; then
        log "${RED}❌ CSS file not found: $css_file${NC}"
        return
    fi

    log "${YELLOW}🔍 Extracting colors from: $css_file${NC}"

    # Extract all relevant colors into a map
    declare -A colors
    local bg="" fg=""

    while read -r name value; do
        case "$name" in
            background) bg="$value" ;;
            foreground) fg="$value" ;;
            color[0-9]|color1[0-5]) colors["$name"]="$value" ;;
        esac
    done < <(grep -E '@define-color (background|foreground|color[0-9]+) #[a-fA-F0-9]{6}' "$css_file" | \
             sed -E 's/@define-color[[:space:]]+([a-zA-Z0-9_-]+)[[:space:]]+(#[a-fA-F0-9]{6});/\1 \2/')

    # Verify
    if [[ -z "$bg" || -z "$fg" ]]; then
        log "${RED}❌ Missing background or foreground definition${NC}"
        return
    fi

    mkdir -p "$(dirname "$wal_json")"

    {
        echo '{'
        echo '  "wallpaper": "/home/vaproh/.config/wall.png",'
        echo '  "special": {'
        echo "    \"background\": \"${bg}\","
        echo "    \"foreground\": \"${fg}\","
        echo "    \"cursor\": \"${fg}\""
        echo '  },'
        echo '  "colors": {'
        for i in {0..15}; do
            key="color$i"
            if [ "$i" -eq 0 ]; then
                value="$bg"  # Set color0 to background
            else
                value="${colors[$key]:-#000000}"
            fi
            comma=$([[ $i -lt 15 ]] && echo ',' || echo '')
            echo "    \"$key\": \"$value\"$comma"
        done
        echo '  }'
        echo '}'
    } > "$wal_json"


    if [[ -f "$wal_json" ]]; then
        log "${GREEN}✅ Generated colors.json for Pywalfox${NC}"
        if command -v pywalfox &>/dev/null; then
            pywalfox update && log "${GREEN}🦊 Firefox updated via Pywalfox${NC}"
        else
            log "${YELLOW}⚠ pywalfox not found${NC}"
        fi
    else
        log "${RED}❌ Failed to create $wal_json${NC}"
    fi
}
generate_pywalfox_json

# === Reload Kitty ===
if pgrep -x kitty >/dev/null; then
    pkill -SIGUSR1 kitty
    log "${GREEN}🔄 Reloaded Kitty.${NC}"
else
    log "${YELLOW}⚠ No Kitty process found.${NC}"
fi

# === Restart SwayNC ===
if pgrep -x swaync >/dev/null; then
    killall swaync
    sleep 0.5
fi
if command -v swaync &>/dev/null; then
    nohup swaync >/dev/null 2>&1 &
    log "${GREEN}🔄 Restarted SwayNC.${NC}"
else
    log "${YELLOW}⚠ swaync not found in PATH. Start it manually.${NC}"
fi

# === Apply Firefox Theme ===
if command -v pywalfox &>/dev/null; then
    pywalfox update && log "${GREEN}🦊 Firefox theme updated via Pywalfox.${NC}"
else
    log "${YELLOW}⚠ pywalfox not installed. Skipping Firefox theming.${NC}"
fi

# === Cleanup ===
rm "$KITTY_DIFF" "$WAYBAR_DIFF" "$SWAYNC_DIFF" "$WOFI_DIFF" "$WLOGOUT_DIFF"
log "${GREEN}✅ Theme successfully applied: ${THEME}${NC}"

# === Desktop Notification ===
if command -v notify-send &>/dev/null; then
    notify-send -u normal -i preferences-desktop-theme "Theme Applied" "✅ ${THEME} has been activated."
fi

