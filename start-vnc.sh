#!/bin/bash

set -e

export HOME=/home/guiuser
export USER=guiuser
export DISPLAY=:1

VNC_PASSWORD="${VNC_PASSWORD:-guiuser}"

mkdir -p "$HOME/.vnc"

# Remove old/stale VNC files
rm -f "$HOME/.vnc/passwd"
rm -f "$HOME/.vnc/*.pid"
rm -f "$HOME/.vnc/*.log"
rm -f "$HOME/.Xauthority"

# Create VNC password
printf '%s\n' "$VNC_PASSWORD" | vncpasswd -f > "$HOME/.vnc/passwd"

chmod 600 "$HOME/.vnc/passwd"

# XFCE startup configuration
cat > "$HOME/.vnc/xstartup" <<'XSTARTUP'
#!/bin/sh

unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

export XDG_CURRENT_DESKTOP=XFCE
export XDG_SESSION_DESKTOP=xfce
export DESKTOP_SESSION=xfce

exec dbus-launch --exit-with-session startxfce4
XSTARTUP

chmod +x "$HOME/.vnc/xstartup"

# Start VNC
exec vncserver :1 \
    -geometry 1920x1080 \
    -depth 24 \
    -localhost no \
    -fg
