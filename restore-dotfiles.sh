#!/bin/bash

# ============================================================
#  restore-dotfiles.sh — Restaura configs desde DotfilesKDE
# ============================================================

set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()    { echo -e "${GREEN}[+]${NC} $1"; }
warn()   { echo -e "${YELLOW}[!]${NC} $1"; }
error()  { echo -e "${RED}[x]${NC} $1"; exit 1; }
section(){ echo -e "\n${CYAN}══════════════════════════════════════${NC}"; echo -e "${CYAN}  $1${NC}"; echo -e "${CYAN}══════════════════════════════════════${NC}"; }

DOTFILES="$HOME/DotfilesKDE"

if [ ! -d "$DOTFILES/.git" ]; then
    error "No se encontró el repositorio en $DOTFILES\n  Clónalo primero:\n  git clone https://github.com/Shovell12/DotfilesKDE.git ~/DotfilesKDE"
fi

# ─── KDE Plasma ─────────────────────────────────────────────
section "Restaurando configuración de KDE Plasma"

mkdir -p "$HOME/.config"

KDE_FILES=(
    "plasma-org.kde.plasma.desktop-appletsrc"
    "plasmashellrc"
    "kwinrc"
    "kwinoutputconfig.json"
    "kglobalshortcutsrc"
    "khotkeysrc"
    "kdeglobals"
    "kdedefaults"
    "plasmarc"
    "kscreenlockerrc"
    "kcminputrc"
    "kxkbrc"
    "plasma-localerc"
    "plasmakeyboardrc"
)

for f in "${KDE_FILES[@]}"; do
    if [ -f "$DOTFILES/kde/$f" ]; then
        cp "$DOTFILES/kde/$f" "$HOME/.config/$f"
        log "Restaurado: $f"
    else
        warn "No encontrado: $f (omitido)"
    fi
done

# ─── Tema personalizado ──────────────────────────────────────
section "Restaurando tema personalizado"

if [ -d "$DOTFILES/plasma-theme/Personalized" ]; then
    mkdir -p "$HOME/.local/share/plasma/look-and-feel"
    cp -r "$DOTFILES/plasma-theme/Personalized" "$HOME/.local/share/plasma/look-and-feel/"
    log "Restaurado: tema Personalized"
fi

# ─── Kitty ──────────────────────────────────────────────────
section "Restaurando configuración de Kitty"

if [ -d "$DOTFILES/kitty" ] && [ "$(ls -A $DOTFILES/kitty 2>/dev/null)" ]; then
    mkdir -p "$HOME/.config/kitty"
    cp -r "$DOTFILES/kitty/"* "$HOME/.config/kitty/" 2>/dev/null || true
    log "Restaurado: kitty"
else
    warn "No encontrado: kitty (omitido)"
fi

# ─── G733 ───────────────────────────────────────────────────
section "Restaurando configuración del G733"

if [ -f "$DOTFILES/g733/g733-monitor.sh" ]; then
    sudo cp "$DOTFILES/g733/g733-monitor.sh" /usr/local/bin/
    sudo chmod +x /usr/local/bin/g733-monitor.sh
    log "Restaurado: g733-monitor.sh"
fi

if [ -f "$DOTFILES/g733/g733-lights.service" ]; then
    mkdir -p "$HOME/.config/systemd/user"
    cp "$DOTFILES/g733/g733-lights.service" "$HOME/.config/systemd/user/"
    systemctl --user enable g733-lights.service
    systemctl --user start g733-lights.service
    log "Restaurado y habilitado: g733-lights.service"
fi

if [ -f "$DOTFILES/g733/99-g733-lights.rules" ]; then
    sudo cp "$DOTFILES/g733/99-g733-lights.rules" /etc/udev/rules.d/
    sudo udevadm control --reload-rules
    log "Restaurado: 99-g733-lights.rules"
fi

# ─── Git config ─────────────────────────────────────────────
section "Restaurando .gitconfig"

if [ -f "$DOTFILES/.gitconfig" ]; then
    cp "$DOTFILES/.gitconfig" "$HOME/.gitconfig"
    log "Restaurado: .gitconfig"
fi

# ─── Fin ────────────────────────────────────────────────────
section "¡Restauración completa!"
echo -e "${GREEN}Reinicia la sesión de KDE para aplicar los cambios.${NC}"
