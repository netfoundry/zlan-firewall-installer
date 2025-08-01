#!/bin/bash
set -e

CONFIG_SRC="/opt/zlan-firewall/etc/filebeat.yml"
CONFIG_DST="/etc/filebeat/filebeat.yml"

echo "[postinst] Setting up Filebeat configuration..."

# Step 1: Back up existing filebeat.yml if it's not already a symlink
if [ -f "$CONFIG_DST" ] && [ ! -L "$CONFIG_DST" ]; then
    echo "[postinst] Backing up existing config to $CONFIG_DST.bak"
    cp "$CONFIG_DST" "$CONFIG_DST.bak"
fi

# Step 2: Ensure parent directory exists (should already from filebeat, but just in case)
mkdir -p "$(dirname "$CONFIG_DST")"

# Step 3: Create symlink
echo "[postinst] Creating symlink from $CONFIG_DST to $CONFIG_SRC"
ln -sf "$CONFIG_SRC" "$CONFIG_DST"

# Step 4: Validate config
echo "[postinst] Validating Filebeat config..."
if /usr/share/filebeat/bin/filebeat test config -c "$CONFIG_DST"; then
    echo "[postinst] Config is valid."
    # Optional: Restart filebeat service
    echo "[postinst] Restarting filebeat..."
    systemctl restart filebeat || true
else
    echo "[postinst] ERROR: Invalid Filebeat config at $CONFIG_DST"
    exit 1
fi

echo "[postinst] Filebeat configuration setup complete."
