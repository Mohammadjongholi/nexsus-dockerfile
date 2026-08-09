#!/bin/bash

set -e

echo "=========================================="
echo "Starting Nexus + Wine + VNC"
echo "=========================================="

# ------------------------------------------------------------
# VNC password
# ------------------------------------------------------------

mkdir -p "$HOME/.vnc"

if [ -n "${VNC_PASSWORD}" ]; then
    echo "$VNC_PASSWORD" | vncpasswd -f > "$HOME/.vnc/passwd"
    chmod 600 "$HOME/.vnc/passwd"
else
    echo "WARNING: VNC_PASSWORD is not set"
fi

# ------------------------------------------------------------
# XFCE startup
# ------------------------------------------------------------

cat > "$HOME/.vnc/xstartup" <<'EOF'
#!/bin/sh

unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

startxfce4 &
EOF

chmod +x "$HOME/.vnc/xstartup"

# ------------------------------------------------------------
# Start VNC
# ------------------------------------------------------------

vncserver :1 \
    -geometry 1920x1080 \
    -depth 24 \
    -localhost no

echo "VNC started on port 5901"

# ------------------------------------------------------------
# Start Nexus
# ------------------------------------------------------------

echo "Starting Nexus..."

exec /opt/nexus/bin/nexus run
```

