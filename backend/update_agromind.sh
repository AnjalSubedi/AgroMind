#!/bin/bash
# Script to update the existing agromind.service to use Performance Mode

SERVICE_FILE="/etc/systemd/system/agromind.service"

echo "🔧 Updating $SERVICE_FILE..."

# Check if the line already exists
if grep -q "KEEP_MODELS_LOADED=True" "$SERVICE_FILE"; then
    echo "✅ Configuration already exists."
else
    # Insert the Environment variable into the [Service] block
    # We look for [Service] and append the line after it (or broadly inside it)
    # A safe way is to replace the [Service] header with [Service] + newline + Enum
    sudo sed -i '/^\[Service\]/a Environment="KEEP_MODELS_LOADED=True"' "$SERVICE_FILE"
    echo "✅ Added KEEP_MODELS_LOADED=True"
fi

echo "🔄 Reloading and Restarting Service..."
sudo systemctl daemon-reload
sudo systemctl restart agromind
sudo systemctl status agromind --no-pager

echo "🚀 Done! Gunicorn is now running in Performance Mode."
