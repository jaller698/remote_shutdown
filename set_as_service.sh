#!/bin/bash

# Define service name and description
SERVICE_NAME="remote-shutdown"
SERVICE_DESCRIPTION="Service for remote shutdown functionality"

# Get the current directory
CURRENT_DIR=$(pwd)

EXE_DIR="/usr/local/bin"
CONFIG_DIR="/etc/remote_shutdown"

# Define the path to the executable
EXE_PATH="$CURRENT_DIR/remote_shutdown"
WORKING_DIR="$CURRENT_DIR"

# Validate the executable path
if [ ! -x "$EXE_PATH" ]; then
    echo "Error: The executable remote_shutdown was not found or is not executable in the current directory: $CURRENT_DIR"
    EXE_PATH="$CURRENT_DIR/target/release/remote_shutdown"
    WORKING_DIR="$CURRENT_DIR/target/release"
    if [ ! -x "$EXE_PATH" ]; then
        echo "Error: The executable remote_shutdown was not found or is not executable in the target directory: $CURRENT_DIR"
        exit 1
    fi
fi

cp $EXE_PATH $EXE_DIR
sudo mkdir -p $CONFIG_DIR
cp "config.ini" $CONFIG_DIR

EXE_PATH="$EXE_DIR/remote_shutdown"
CONFIG_PATH="$CONFIG_DIR/config.ini"

# Define the systemd service unit file
SERVICE_UNIT="[Unit]
Description=$SERVICE_DESCRIPTION
After=network.target

[Service]
ExecStart=$EXE_PATH
WorkingDirectory=$WORKING_DIR
Restart=always
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=$SERVICE_NAME
Environment=CONFIG_PATH=$CONFIG_PATH

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
