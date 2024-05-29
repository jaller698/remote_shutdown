#!/bin/bash

# Define service name and description
SERVICE_NAME="remote-shutdown"
SERVICE_DESCRIPTION="Service for remote shutdown functionality"

# Get the current directory
CURRENT_DIR=$(pwd)

# Define the path to the executable
EXE_PATH="$CURRENT_DIR/remote_shutdown"

# Validate the executable path
if [ ! -x "$EXE_PATH" ]; then
    echo "Error: The executable remote_shutdown was not found or is not executable in the current directory: $CURRENT_DIR"
    exit 1
fi

# Define the systemd service unit file
SERVICE_UNIT="[Unit]
Description=$SERVICE_DESCRIPTION

[Service]
ExecStart=$EXE_PATH
Restart=always
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=$SERVICE_NAME

[Install]
WantedBy=multi-user.target"

# Write the service unit file to /etc/systemd/system/
echo "$SERVICE_UNIT" | sudo tee /etc/systemd/system/$SERVICE_NAME.service > /dev/null

# Reload systemd daemon to read the new service unit
sudo systemctl daemon-reload

# Start and enable the service
sudo systemctl start $SERVICE_NAME
sudo systemctl enable $SERVICE_NAME

echo "Service '$SERVICE_NAME' created and started successfully using systemd."
