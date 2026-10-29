#!/bin/sh

# X resources
userresources=$HOME/.Xresources
sysresources=/etc/X11/xinit/.Xresources

if [ -f "$sysresources" ]; then
    xrdb -merge "$sysresources"
fi
if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

# source any distro xinitrc.d scripts
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

# detect NVIDIA GPU once at startup
GPU_AVAILABLE=0
if command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi -L >/dev/null 2>&1; then
    GPU_AVAILABLE=1
fi

dwm-status &

# start gnome-keyring for secrets
eval $(gnome-keyring-daemon --start)
export SSH_AUTH_SOCK

# Escape and Caps Lock are swapped in the kernel by /etc/udev/hwdb.d/90-swap-caps-esc.hwdb,
# so every app agrees on the keys. Only fall back to the XKB swap when that file is missing,
# otherwise the two swaps cancel out.
[ -e /etc/udev/hwdb.d/90-swap-caps-esc.hwdb ] || setxkbmap -option "caps:swapescape"

# daemons
sxhkd &
dunst &
unclutter &
nm-applet &
picom --backend glx &

# set your own latitude:longitude
redshift -l 0:0 &

"$HOME/.local/bin/start-day" &

exec dwm
