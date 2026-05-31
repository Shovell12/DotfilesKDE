#!/bin/bash

# ============================================================
#  backup-dotfiles.sh — Copia configs y sube a GitHub
# ============================================================

set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

log()    { echo -e "${GREEN}[+]${NC} $1"; }
error()  { echo -e "${RED}[x]${NC} $1"; exit 1; }
section(){ echo -e "\n${CYAN}══════════════════════════════════════${NC}"; echo -e "${CYAN}  $1${NC}"; echo -e "${CYAN}══════════════════════════════════════${NC}"; }

DOTFILES="$HOME/DotfilesKDE"

if [ ! -d "$DOTFILES/.git" ]; then
    error "No se encontró el repositorio en $DOTFILES"
fi

mkdir -p "$DOTFILES/kde"
mkdir -p "$DOTFILES/kitty"
mkdir -p "$DOTFILES/g733"

# ─── KDE Plasma ─────────────────────────────────────────────
section "Copiando configuración de KDE Plasma"

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
    if [ -f "$HOME/.config/$f" ]; then
        cp "$HOME/.config/$f" "$DOTFILES/kde/$f"
        log "Copiado: $f"
    else
        echo -e "  [~] No encontrado: $f (omitido)"
    fi
done

# ─── Tema personalizado ──────────────────────────────────────
section "Copiando tema personalizado"

if [ -d "$HOME/.local/share/plasma/look-and-feel/Personalized" ]; then
    mkdir -p "$DOTFILES/plasma-theme"
    cp -r "$HOME/.local/share/plasma/look-and-feel/Personalized" "$DOTFILES/plasma-theme/"
    log "Copiado: tema Personalized"
fi

# ─── SDDM ───────────────────────────────────────────────────
section "Copiando configuración de SDDM"

mkdir -p "$DOTFILES/sddm"
if [ -d /etc/sddm.conf.d ]; then
    sudo cp /etc/sddm.conf.d/*.conf "$DOTFILES/sddm/" 2>/dev/null || true
    log "Copiado: sddm.conf.d"
fi

# ─── Kitty ──────────────────────────────────────────────────
section "Copiando configuración de Kitty"

if [ -d "$HOME/.config/kitty" ]; then
    cp -r "$HOME/.config/kitty/"* "$DOTFILES/kitty/"
    log "Copiado: kitty"
else
    echo -e "  [~] No encontrado: ~/.config/kitty (omitido)"
fi

# ─── G733 ───────────────────────────────────────────────────
section "Copiando configuración del G733"

if [ -f "/usr/local/bin/g733-monitor.sh" ]; then
    cp /usr/local/bin/g733-monitor.sh "$DOTFILES/g733/"
    log "Copiado: g733-monitor.sh"
fi

if [ -f "$HOME/.config/systemd/user/g733-lights.service" ]; then
    cp "$HOME/.config/systemd/user/g733-lights.service" "$DOTFILES/g733/"
    log "Copiado: g733-lights.service"
fi

if [ -f "/etc/udev/rules.d/99-g733-lights.rules" ]; then
    sudo cp /etc/udev/rules.d/99-g733-lights.rules "$DOTFILES/g733/"
    log "Copiado: 99-g733-lights.rules"
fi

# ─── Git config ─────────────────────────────────────────────
section "Copiando .gitconfig"

if [ -f "$HOME/.gitconfig" ]; then
    cp "$HOME/.gitconfig" "$DOTFILES/.gitconfig"
    log "Copiado: .gitconfig"
fi

# ─── Git push ───────────────────────────────────────────────
section "Subiendo a GitHub"

cd "$DOTFILES"
git add .

if git diff --cached --quiet; then
    echo -e "  [~] No hay cambios para subir"
else
    git commit -m "backup: $(date '+%Y-%m-%d %H:%M')"
    git push
    log "Subido a GitHub"
fi

# ─── Fin ────────────────────────────────────────────────────
section "¡Backup completo!"
