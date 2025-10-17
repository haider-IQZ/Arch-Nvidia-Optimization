# Arch Linux NVIDIA Optimization for Hyprland
Based on PikaOS NVIDIA optimizations

## What This Does
- Configures proper NVIDIA environment variables for Hyprland
- Optimizes kernel module parameters for better performance
- Enables VRR/G-SYNC, max performance mode, and better power management

## Requirements
- Arch Linux with Hyprland
- NVIDIA drivers already installed (`nvidia-open-dkms` or `nvidia-dkms`)

## Installation

### 1. Apply Kernel Module Parameters

Copy the optimized kernel parameters:
```bash
sudo cp nvidia.conf /etc/modprobe.d/nvidia.conf
sudo mkinitcpio -P
```

### 2. Configure Hyprland Environment Variables

Copy the environment variables to your Hyprland config:
```bash
cp hyprland-nvidia-env.conf ~/.config/hypr/env.conf
```

Or if you already have `env.conf`, append the contents to your existing file.

### 3. Reboot
```bash
reboot
```

## Files Included

- `nvidia.conf` - Kernel module parameters
- `hyprland-nvidia-env.conf` - Hyprland environment variables

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

Check if everything is working:
```bash
# Check NVIDIA driver
nvidia-smi

# Check environment variables in Hyprland
env | grep -E "(NVIDIA|GL|GBM|LIBVA|VDPAU)"
```

## Credits

Based on PikaOS NVIDIA optimizations.

## License
Public Domain / CC0 - Do whatever you want with it.
