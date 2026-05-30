#!/bin/bash

# ============================================================
#  arch-install.sh — Post-install setup para Arch Linux
# ============================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

log()    { echo -e "${GREEN}[+]${NC} $1"; }
error()  { echo -e "${RED}[x]${NC} $1"; exit 1; }
section(){ echo -e "\n${CYAN}══════════════════════════════════════${NC}"; echo -e "${CYAN}  $1${NC}"; echo -e "${CYAN}══════════════════════════════════════${NC}"; }

if [ "$EUID" -eq 0 ]; then
    error "No corras este script como root. Usa tu usuario normal."
fi

# ─── Verificar internet ──────────────────────────────────────
if ! ping -c 1 archlinux.org &>/dev/null; then
    error "No hay conexión a internet."
fi

# ─── Verificar yay ──────────────────────────────────────────
if ! command -v yay &>/dev/null; then
    section "Instalando yay (AUR helper)"
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay && makepkg -si --noconfirm
    cd ~ && rm -rf /tmp/yay
    log "yay instalado"
fi

# ─── Actualizar sistema ──────────────────────────────────────
section "Actualizando sistema"
sudo pacman -Syu --noconfirm
log "Sistema actualizado"

# ─── KDE Plasma ─────────────────────────────────────────────
section "Instalando KDE Plasma"
sudo pacman -S --needed --noconfirm \
    plasma-desktop plasma-workspace plasma-activities plasma-activities-stats \
    plasma-nm plasma-pa plasma-systemmonitor plasma-integration plasma-browser-integration \
    plasma-disks plasma-firewall plasma-keyboard plasma-workspace-wallpapers \
    plasma-login-manager plasma5support \
    kwin kwin-x11 kwayland kscreen kscreenlocker \
    kglobalacceld kactivitymanagerd kpipewire kwallet-pam \
    bluedevil bluez bluez-utils breeze breeze-gtk breeze-cursors \
    kde-cli-tools kde-gtk-config kdecoration kdeplasma-addons \
    kgamma kinfocenter kio-admin kmenuedit kwrited \
    layer-shell-qt libkscreen libksysguard libplasma \
    milou ocean-sound-theme polkit-kde-agent powerdevil \
    power-profiles-daemon qqc2-breeze-style qt5-wayland \
    sddm sddm-kcm systemsettings xdg-desktop-portal-kde \
    ksshaskpass ksystemstats aurorae
log "KDE Plasma instalado"

# ─── Xorg ───────────────────────────────────────────────────
section "Instalando Xorg"
sudo pacman -S --needed --noconfirm \
    xorg-server xorg-server-common xorg-server-xvfb xorg-xwayland \
    xorg-fonts-encodings xorg-setxkbmap xorg-xauth \
    xorg-xinput xorg-xkbcomp xorg-xkill \
    xorg-xprop xorg-xrandr xorg-xrdb xorg-xset
log "Xorg instalado"

# ─── Apps KDE ────────────────────────────────────────────────
section "Instalando apps KDE"
sudo pacman -S --needed --noconfirm \
    ark dolphin gwenview kcalc spectacle partitionmanager print-manager
log "Apps KDE instaladas"

# ─── NVIDIA ──────────────────────────────────────────────────
section "Instalando drivers NVIDIA"
sudo pacman -S --needed --noconfirm \
    nvidia-open-dkms nvidia-utils nvidia-prime \
    lib32-mangohud mangohud gamemode
log "NVIDIA instalado"

# ─── Audio / Video ───────────────────────────────────────────
section "Instalando audio y video"
sudo pacman -S --needed --noconfirm \
    alsa-utils gst-plugins-bad gst-plugins-ugly \
    celluloid obs-studio
log "Audio y video instalados"

# ─── Juegos ──────────────────────────────────────────────────
section "Instalando juegos"
sudo pacman -S --needed --noconfirm \
    steam
log "Juegos instalados"

# ─── Desarrollo ──────────────────────────────────────────────
section "Instalando herramientas de desarrollo"
sudo pacman -S --needed --noconfirm \
    base-devel git nodejs npm
log "Desarrollo instalado"

# ─── Terminal / Sistema ───────────────────────────────────────
section "Instalando terminal y herramientas del sistema"
sudo pacman -S --needed --noconfirm \
    kitty btop fastfetch nano less unzip sudo acpid headsetcontrol
log "Terminal y sistema instalados"

# ─── Red / Seguridad ─────────────────────────────────────────
section "Instalando red y seguridad"
sudo pacman -S --needed --noconfirm \
    networkmanager ufw nmap
log "Red y seguridad instalados"

# ─── Impresión ───────────────────────────────────────────────
section "Instalando impresión"
sudo pacman -S --needed --noconfirm \
    cups hplip system-config-printer
log "Impresión instalada"

# ─── Fuentes ─────────────────────────────────────────────────
section "Instalando fuentes"
sudo pacman -S --needed --noconfirm \
    ttf-jetbrains-mono
log "Fuentes instaladas"

# ─── Aplicaciones ────────────────────────────────────────────
section "Instalando aplicaciones"
sudo pacman -S --needed --noconfirm \
    firefox discord libreoffice-still
log "Aplicaciones instaladas"

# ─── Sistema base ────────────────────────────────────────────
section "Instalando sistema base"
sudo pacman -S --needed --noconfirm \
    base linux linux-firmware linux-headers efibootmgr grub plymouth
log "Sistema base instalado"

# ─── AUR ─────────────────────────────────────────────────────
section "Instalando paquetes AUR"
yay -S --needed --noconfirm \
    debtap \
    protonup-qt \
    qtspim \
    vscodium-bin \
    prismlauncher
log "Paquetes AUR instalados"

# ─── Servicios ───────────────────────────────────────────────
section "Habilitando servicios"
sudo systemctl enable sddm
sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth
sudo systemctl enable acpid
sudo systemctl enable cups
sudo systemctl enable ufw
log "Servicios habilitados"

# ─── Fin ─────────────────────────────────────────────────────
section "¡Instalación completa!"
echo -e "${GREEN}Reinicia el sistema para aplicar todos los cambios.${NC}"
echo -e "  sudo reboot"
