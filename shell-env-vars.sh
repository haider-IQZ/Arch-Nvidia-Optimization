#!/bin/bash
# NVIDIA Environment Variables for Wayland
# Source this in your ~/.bashrc or ~/.zshrc if not using Hyprland/Niri
# Or add to your compositor's startup script

# Wayland environment
export MOZ_ENABLE_WAYLAND=1
export XDG_SESSION_TYPE=wayland
export MOZ_DBUS_REMOTE=1
export GDK_BACKEND=wayland
export QT_AUTO_SCREEN_SCALE_FACTOR=1
export QT_WAYLAND_FORCE_DPI=physical
export EGL_PLATFORM=wayland
export CLUTTER_BACKEND=wayland

# NVIDIA specific
export NVD_BACKEND=direct
export LIBVA_DRIVER_NAME=nvidia
export GBM_BACKEND=nvidia-drm
export VDPAU_DRIVER=nvidia
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export __GL_VRR_ALLOWED=1
export __GL_GSYNC_ALLOWED=1
export __GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1
export __GL_YIELD=USLEEP
export __EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/10_nvidia.json

# Electron apps
export ELECTRON_OZONE_PLATFORM_HINT=auto

# Qt theming
export QT_QPA_PLATFORMTHEME=qt6ct

# Renderer
export GSK_RENDERER=ngl
