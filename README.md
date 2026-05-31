# DotfilesKDE

Configuración personal de Arch Linux con KDE Plasma. Incluye scripts para instalar paquetes, restaurar configuraciones y mantener un backup actualizado en GitHub.

---

## Contenido del repositorio

```
DotfilesKDE/
├── arch-install.sh        # Instala todos los paquetes
├── backup-dotfiles.sh     # Respalda configs y hace push a GitHub
├── restore-dotfiles.sh    # Restaura configs en una instalación nueva
├── kde/                   # Configuración de KDE Plasma
├── kitty/                 # Configuración de la terminal Kitty
├── g733/                  # Scripts para apagar luces del G733
├── icons/                 # Iconos Papirus
├── aurorae/               # Decoración de ventanas MoeDark
├── plasmoids/             # Widgets de terceros
├── plasma-theme/          # Tema personalizado de Plasma
└── sddm/                  # Configuración de SDDM
```

---

## Instalación de Arch Linux desde cero

### 1. Arrancar desde la ISO

Descarga la ISO desde [archlinux.org/download](https://archlinux.org/download) y arranca desde ella.

Verifica internet:
```bash
ping -c 3 archlinux.org
```

Sincroniza el reloj:
```bash
timedatectl set-ntp true
```

### 2. Particionar el disco

```bash
cfdisk /dev/sda
```

Selecciona **gpt** y crea 3 particiones:

| Partición | Tamaño | Tipo |
|-----------|--------|------|
| sda1 | 2 GB | Linux swap |
| sda2 | 512 MB | EFI System |
| sda3 | Resto | Linux filesystem |

Guarda con **Write** → `yes` → **Quit**.

### 3. Formatear particiones

```bash
mkfs.fat -F32 /dev/sda2
mkswap /dev/sda1 && swapon /dev/sda1
mkfs.ext4 /dev/sda3
```

### 4. Montar particiones

```bash
mount /dev/sda3 /mnt
mkdir -p /mnt/boot/efi
mount /dev/sda2 /mnt/boot/efi
```

### 5. Instalar sistema base

```bash
pacstrap /mnt base linux linux-firmware base-devel git nano networkmanager sudo
```

### 6. Generar fstab

```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

### 7. Entrar al chroot

```bash
arch-chroot /mnt
```

### 8. Configurar zona horaria e idioma

```bash
ln -sf /usr/share/zoneinfo/America/Lima /etc/localtime
hwclock --systohc
```

Edita `/etc/locale.gen` y descomenta `en_US.UTF-8 UTF-8`:
```bash
nano /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
```

### 9. Configurar hostname

```bash
echo "arch" > /etc/hostname
nano /etc/hosts
```

Agrega:
```
127.0.0.1   localhost
::1         localhost
127.0.1.1   arch.localdomain arch
```

### 10. Contraseña de root y usuario

```bash
passwd
useradd -m -G wheel -s /bin/bash tu_usuario
passwd tu_usuario
```

Habilita sudo para el grupo wheel:
```bash
EDITOR=nano visudo
```
Descomenta: `%wheel ALL=(ALL:ALL) ALL`

### 11. Bootloader (GRUB)

```bash
pacman -S grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
```

### 12. Habilitar NetworkManager y reiniciar

```bash
systemctl enable NetworkManager
exit
umount -R /mnt
reboot
```

---

## Post-instalación

Una vez en el sistema con tu usuario:

### 1. Instalar paquetes

```bash
git clone https://github.com/Shovell12/DotfilesKDE.git ~/DotfilesKDE
bash ~/DotfilesKDE/arch-install.sh
```

El script instala KDE Plasma, Xorg, drivers NVIDIA, aplicaciones y paquetes AUR automáticamente. Tarda entre 20 y 40 minutos dependiendo de la conexión.

> **Nota:** Antes de correr el script habilita el repositorio `multilib` en `/etc/pacman.conf` descomentando las líneas `[multilib]` e `Include`.

### 2. Restaurar configuración

```bash
bash ~/DotfilesKDE/restore-dotfiles.sh
sudo reboot
```

Restaura: tema de KDE, iconos Papirus, decoración MoeDark, widgets, atajos de teclado, configuración de Kitty, G733 y SDDM.

### 3. Ajustes manuales post-restauración

- **Wallpaper:** clic derecho en el escritorio → Configurar escritorio
- **Icono del menú:** clic derecho en el botón de inicio → Configurar

---

## Mantener el backup actualizado

Cada vez que cambies algo en tu configuración:

```bash
bash ~/DotfilesKDE/backup-dotfiles.sh
```

El script copia las configs al repositorio y hace `git push` automáticamente con la fecha y hora como mensaje de commit.

---

## G733 — Apagar luces automáticamente

El script `restore-dotfiles.sh` configura automáticamente el servicio que apaga las luces del headset cada vez que lo enciendes.

Si necesitas configurarlo manualmente:

```bash
sudo cp ~/DotfilesKDE/g733/g733-monitor.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/g733-monitor.sh
mkdir -p ~/.config/systemd/user
cp ~/DotfilesKDE/g733/g733-lights.service ~/.config/systemd/user/
systemctl --user enable g733-lights.service
systemctl --user start g733-lights.service
sudo cp ~/DotfilesKDE/g733/99-g733-lights.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules
```

---

## Paquetes incluidos

| Categoría | Paquetes destacados |
|-----------|-------------------|
| Escritorio | KDE Plasma, SDDM, Xorg |
| GPU | nvidia-open-dkms, nvidia-prime |
| Audio/Video | alsa-utils, celluloid, obs-studio |
| Juegos | Steam, Prismlauncher, ProtonUp-Qt |
| Desarrollo | VSCodium, Git, Node.js |
| Aplicaciones | Firefox, Discord, LibreOffice |
| Sistema | btop, fastfetch, kitty, headsetcontrol |
