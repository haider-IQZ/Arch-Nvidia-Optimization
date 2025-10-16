#!/bin/bash
# Arch Linux NVIDIA Optimization Installer
# Based on PikaOS optimizations

set -e

echo "======================================"
echo "Arch NVIDIA Optimization Installer"
echo "======================================"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo "ERROR: Do not run this script as root!"
    echo "It will ask for sudo when needed."
    exit 1
fi

# Check if NVIDIA drivers are installed
if ! command -v nvidia-smi &> /dev/null; then
    echo "WARNING: nvidia-smi not found. NVIDIA drivers may not be installed."
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "Step 1: Installing kernel module parameters..."
sudo cp nvidia.conf /etc/modprobe.d/nvidia.conf
echo "✓ Copied nvidia.conf to /etc/modprobe.d/"

echo ""
echo "Step 2: Regenerating initramfs..."
sudo mkinitcpio -P
echo "✓ Initramfs regenerated"

echo ""
echo "Step 3: Compositor configuration..."
echo "Which compositor do you use?"
echo "1) Hyprland"
echo "2) Niri"
echo "3) Other/Skip"
read -p "Enter choice (1-3): " choice

case $choice in
    1)
        mkdir -p ~/.config/hypr
        if [ -f ~/.config/hypr/env.conf ]; then
            echo "WARNING: ~/.config/hypr/env.conf already exists"
            read -p "Backup and replace? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                cp ~/.config/hypr/env.conf ~/.config/hypr/env.conf.backup
                cp hyprland-nvidia-env.conf ~/.config/hypr/env.conf
                echo "✓ Backed up old config and installed new one"
            else
                echo "! Skipped Hyprland config installation"
                echo "  Manually merge hyprland-nvidia-env.conf into your config"
            fi
        else
            cp hyprland-nvidia-env.conf ~/.config/hypr/env.conf
            echo "✓ Installed Hyprland NVIDIA config"
        fi
        ;;
    2)
        echo "! For Niri, manually add the environment block from niri-example-env.kdl"
        echo "  to your ~/.config/niri/config.kdl"
        ;;
    3)
        echo "! Skipped compositor configuration"
        echo "  See shell-env-vars.sh for environment variables to set"
        ;;
    *)
        echo "Invalid choice, skipping compositor configuration"
        ;;
esac

echo ""
echo "======================================"
echo "Installation Complete!"
echo "======================================"
echo ""
echo "IMPORTANT: You must REBOOT for changes to take effect!"
echo ""
echo "After reboot, verify with:"
echo "  - nvidia-smi (check GPU is detected)"
echo "  - systool -m nvidia_drm -av | grep modeset (should show 'Y')"
echo "  - env | grep GL (check environment variables)"
echo ""
read -p "Reboot now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Rebooting..."
    sudo reboot
else
    echo "Remember to reboot later!"
fi
