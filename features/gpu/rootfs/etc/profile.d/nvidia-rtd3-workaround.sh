# RTD3 hybrid graphics: when the NVIDIA GPU is a 3D controller without
# display outputs (PCI class 0302), route EGL to Mesa.
if [ -n "$(lspci -d "10de:*:0302")" ]; then
    export __EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/50_mesa.json
fi
