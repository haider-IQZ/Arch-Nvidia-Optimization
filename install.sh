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

# Detect GPU generation
detect_gpu() {
    if command -v nvidia-smi &> /dev/null; then
        GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -1)
        echo "Detected GPU: $GPU_NAME"
        
        # Simple detection based on name
        if echo "$GPU_NAME" | grep -qE "(RTX [2-4][0-9]|RTX [5-9][0-9]|A[0-9]{3,4})"; then
            echo "This is a newer GPU (RTX 20+ series)"
            return 0
        else
            echo "This is an older GPU (GTX series or older)"
            return 1
        fi
    else
        echo "Could not detect GPU. nvidia-smi not found."
        return 2
    fi
}

# Package installation function
install_packages() {
    echo ""
    echo "======================================"
    echo "Step 1: NVIDIA Package Installation"
    echo "======================================"
    echo ""
    
    # Check if drivers already installed
    DRIVERS_INSTALLED=false
    if command -v nvidia-smi &> /dev/null; then
        echo "✓ NVIDIA drivers already detected!"
        DRIVERS_INSTALLED=true
    fi
    
    echo "Choose installation mode:"
    echo "1) Full installation (all gaming/desktop packages)"
    echo "2) Custom installation (choose what to install)"
    echo "3) Skip package installation"
    read -p "Enter choice (1-3): " install_choice
    
    case $install_choice in
        1)
            echo ""
            echo "Installing ALL NVIDIA packages..."
            
            # Determine which driver to use
            if [ "$DRIVERS_INSTALLED" = true ]; then
                echo "Drivers already installed, installing additional packages only..."
                PACKAGES="nvidia-settings opencl-nvidia lib32-opencl-nvidia \
                         libva-nvidia-driver libva-utils vdpauinfo \
                         vulkan-icd-loader lib32-vulkan-icd-loader \
                         libvdpau lib32-libvdpau"
            else
                # Detect GPU and choose driver
                detect_gpu
                GPU_TYPE=$?
                
                if [ $GPU_TYPE -eq 0 ]; then
                    DRIVER="nvidia-open-dkms"
                else
                    DRIVER="nvidia-dkms"
                fi
                
                echo "Using driver: $DRIVER"
                
                PACKAGES="$DRIVER nvidia-utils lib32-nvidia-utils \
                         nvidia-settings opencl-nvidia lib32-opencl-nvidia \
                         libva-nvidia-driver libva-utils vdpauinfo \
                         vulkan-icd-loader lib32-vulkan-icd-loader \
                         libvdpau lib32-libvdpau"
            fi
            
            # Install packages
            sudo pacman -S --needed $PACKAGES
            
            echo "✓ All packages installed"
            ;;
            
        2)
            echo ""
            echo "Custom installation mode"
            echo ""
            
            # Install drivers if not already installed
            if [ "$DRIVERS_INSTALLED" = false ]; then
                # Detect GPU and choose driver
                detect_gpu
                GPU_TYPE=$?
                
                if [ $GPU_TYPE -eq 0 ]; then
                    DRIVER="nvidia-open-dkms"
                elif [ $GPU_TYPE -eq 1 ]; then
                    DRIVER="nvidia-dkms"
                else
                    echo "Choose driver:"
                    echo "1) nvidia-open-dkms (RTX 20+ series)"
                    echo "2) nvidia-dkms (GTX 10 series and older)"
                    read -p "Enter choice (1-2): " driver_choice
                    if [ "$driver_choice" = "1" ]; then
                        DRIVER="nvidia-open-dkms"
                    else
                        DRIVER="nvidia-dkms"
                    fi
                fi
                
                # Core drivers (mandatory)
                echo "Installing core drivers..."
                sudo pacman -S --needed $DRIVER nvidia-utils lib32-nvidia-utils
            else
                echo "✓ Drivers already installed, skipping driver installation"
            fi
            
            # NVIDIA Settings
            read -p "Install nvidia-settings (GUI configuration tool)? (Y/n): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Nn]$ ]]; then
                sudo pacman -S --needed nvidia-settings
            fi
            
            # OpenCL
            read -p "Install OpenCL support (for compute tasks)? (Y/n): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Nn]$ ]]; then
                sudo pacman -S --needed opencl-nvidia lib32-opencl-nvidia
            fi
            
            # Video acceleration
            read -p "Install video acceleration (VA-API/VDPAU)? (Y/n): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Nn]$ ]]; then
                sudo pacman -S --needed libva-nvidia-driver libva-utils vdpauinfo libvdpau lib32-libvdpau
            fi
            
            # Vulkan
            read -p "Install Vulkan support (for gaming)? (Y/n): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Nn]$ ]]; then
                sudo pacman -S --needed vulkan-icd-loader lib32-vulkan-icd-loader
            fi
            
            # CUDA
            read -p "Install CUDA (for AI/ML - large download)? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                sudo pacman -S --needed cuda cuda-tools
            fi
            
            echo "✓ Custom packages installed"
            ;;
            
        3)
            echo "Skipping package installation."
            if ! command -v nvidia-smi &> /dev/null; then
                echo "WARNING: NVIDIA drivers not detected!"
                read -p "Continue anyway? (y/N): " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    exit 1
                fi
            fi
            ;;
            
        *)
            echo "Invalid choice. Skipping package installation."
            ;;
    esac
}

# Run package installation
install_packages

echo ""
echo "======================================"
echo "Step 2: Kernel Module Configuration"
echo "======================================"
echo ""
echo "Installing kernel module parameters..."
sudo cp nvidia.conf /etc/modprobe.d/nvidia.conf
echo "✓ Copied nvidia.conf to /etc/modprobe.d/"

echo ""
echo "Regenerating initramfs..."
sudo mkinitcpio -P
echo "✓ Initramfs regenerated"

echo ""
echo "======================================"
echo "Step 3: Compositor Configuration"
echo "======================================"
echo ""
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
