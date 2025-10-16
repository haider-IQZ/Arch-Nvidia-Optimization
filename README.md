# Arch Linux NVIDIA Optimization Guide
Based on PikaOS NVIDIA optimizations for Wayland compositors

## What This Does
- Enables maximum performance mode for NVIDIA GPU
- Optimizes power management and memory allocation
- Configures proper Wayland/NVIDIA environment variables
- Improves gaming and desktop performance

## Requirements
- Arch Linux
- NVIDIA GPU (RTX 20 series or newer recommended)
- NVIDIA proprietary drivers installed (`nvidia` or `nvidia-dkms`)

## Quick Installation (Recommended)

**The installer script handles everything automatically!**

### 1. Install NVIDIA Drivers (if not already installed)

**For newer GPUs (RTX 20 series and newer - RECOMMENDED):**
```bash
sudo pacman -S nvidia-open-dkms nvidia-utils lib32-nvidia-utils
```

**For older GPUs (GTX 10 series and older):**
```bash
sudo pacman -S nvidia-dkms nvidia-utils lib32-nvidia-utils
```

### 2. Clone and Run the Installer
```bash
git clone https://github.com/haider-IQZ/Arch-Nvidia-Optimization.git
cd Arch-Nvidia-Optimization
chmod +x install.sh
./install.sh
```

The installer will:
- ✅ Copy kernel module parameters to `/etc/modprobe.d/`
- ✅ Regenerate initramfs automatically
- ✅ Install compositor configuration (Hyprland/Niri)
- ✅ Offer to reboot when done

### 3. Reboot
The installer will ask if you want to reboot. Say yes!

---

## Manual Installation (Advanced)

If you prefer to install manually or want to customize:

### 1. Apply Kernel Module Parameters
```bash
sudo cp nvidia.conf /etc/modprobe.d/nvidia.conf
sudo mkinitcpio -P
```

### 2. Configure Your Wayland Compositor

#### For Hyprland:
```bash
cp hyprland-nvidia-env.conf ~/.config/hypr/env.conf
```

Or if you already have `env.conf`, append the contents to your existing file.

#### For Niri:
Copy the `environment` block from `niri-example-env.kdl` to your `~/.config/niri/config.kdl`

#### For Sway/River/Other:
Add the environment variables from `shell-env-vars.sh` to your shell profile or compositor config.

### 3. Reboot
```bash
reboot
```

## Files Included

- `nvidia.conf` - Kernel module parameters for optimal NVIDIA performance
- `hyprland-nvidia-env.conf` - Hyprland environment variables
- `niri-config.kdl` - Example Niri config with NVIDIA env vars
- `shell-env-vars.sh` - Environment variables for shell profiles
- `README.md` - This file

## What Each Kernel Parameter Does

- `modeset=1` - Enable kernel mode setting (required for Wayland)
- `fbdev=1` - Enable framebuffer device support
- `NVreg_UsePageAttributeTable=1` - Improves memory performance
- `NVreg_RegistryDwords="OverrideMaxPerf=0x1"` - Force maximum performance mode
- `NVreg_PreserveVideoMemoryAllocations=1` - Better suspend/resume support
- `NVreg_EnableBrightnessControl=1` - Enable laptop brightness control
- `NVreg_EnableS0ixPowerManagement=1` - Modern standby power management
- `NVreg_EnableGpuFirmware=0` - Disable GSP firmware (better compatibility)

## Environment Variables Explained

- `NVD_BACKEND=direct` - Direct rendering backend
- `LIBVA_DRIVER_NAME=nvidia` - Hardware video acceleration
- `GBM_BACKEND=nvidia-drm` - GBM backend for NVIDIA
- `VDPAU_DRIVER=nvidia` - Video decode acceleration
- `__GLX_VENDOR_LIBRARY_NAME=nvidia` - OpenGL vendor library
- `__GL_VRR_ALLOWED=1` - Enable variable refresh rate
- `__GL_GSYNC_ALLOWED=1` - Enable G-SYNC
- `__GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1` - Keep shader cache
- `__GL_YIELD=USLEEP` - Better CPU usage when waiting for GPU
- `__EGL_VENDOR_LIBRARY_FILENAMES` - EGL vendor library path

## Verification

Check if kernel parameters are loaded:
```bash
cat /proc/cmdline
systool -m nvidia_drm -av | grep modeset
```

Check environment variables (in Wayland session):
```bash
env | grep -E "(NVIDIA|GL|GBM|LIBVA|VDPAU)"
```

Check NVIDIA driver info:
```bash
nvidia-smi
```

## Troubleshooting

### Black screen after reboot
- Boot into recovery mode
- Remove `/etc/modprobe.d/nvidia.conf`
- Run `sudo mkinitcpio -P`
- Reboot

### Performance issues
- Make sure you're using the proprietary NVIDIA drivers, not nouveau
- Check `nvidia-smi` to verify GPU is running at full power
- Verify environment variables are set in your Wayland session

### Suspend/resume issues
- Try removing `NVreg_PreserveVideoMemoryAllocations=1` from nvidia.conf
- Regenerate initramfs and reboot

## Credits
Based on PikaOS NVIDIA optimizations by the PikaOS team.
Adapted for Arch Linux.

## License
Public Domain / CC0 - Do whatever you want with it.
