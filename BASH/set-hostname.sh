#!/bin/bash

################################################################################
# Script Name: set-hostname.sh
# Description: A system utility to update the Linux hostname and safely 
#              synchronize the /etc/hosts file loopback entries.
# Author:      Kshitiz Awasthi
# Date:        2026-04-01
# Usage:       sudo ./set-hostname.sh
# Requirements: Systemd-based Linux (CentOS 7+, RHEL, Fedora, Ubuntu).
################################################################################

# 1. Check for root privileges (EUID 0)
echo "[STEP 1] Verifying administrative privileges..."
if [ "$EUID" -ne 0 ]; then 
  echo "RESULT: FAILED. This script must be run with sudo or as root."
  exit 1
fi
echo "RESULT: SUCCESS. Running as root."

echo "------------------------------------------------"

# 2. Gather and Validate Input
echo "[STEP 2] Gathering new hostname..."
read -p "Enter the new hostname: " HNAME

if [ -z "$HNAME" ]; then
    echo "RESULT: FAILED. Hostname cannot be empty."
    exit 1
fi
echo "STATUS: Hostname set to '$HNAME'."

echo "------------------------------------------------"

# 3. Update System Hostname
echo "[STEP 3] Updating system hostname via hostnamectl..."
hostnamectl set-hostname "$HNAME"
if [ $? -eq 0 ]; then
    echo "RESULT: SUCCESS. System hostname updated."
else
    echo "RESULT: FAILED. Could not update system hostname."
    exit 1
fi

echo "------------------------------------------------"

# 4. Update /etc/hosts (Clean & Append)
echo "[STEP 4] Synchronizing /etc/hosts file..."

# First, remove the specific hostname if it already exists on loopback lines to prevent duplicates
# \b ensures we match the whole word only
sudo sed -i "/^127.0.0.1/ s/\b$HNAME\b//" /etc/hosts
sudo sed -i "/^::1/ s/\b$HNAME\b//" /etc/hosts

# Now append the new hostname to the end of the 127.0.0.1 and ::1 lines
sudo sed -i "/^127.0.0.1/ s/$/ $HNAME/" /etc/hosts
sudo sed -i "/^::1/ s/$/ $HNAME/" /etc/hosts

if [ $? -eq 0 ]; then
    echo "RESULT: SUCCESS. /etc/hosts updated while preserving existing entries."
else
    echo "RESULT: FAILED. Could not modify /etc/hosts."
    exit 1
fi

echo "------------------------------------------------"
echo "[FINISH] Hostname update complete!"
echo "Current Status:"
hostnamectl status | grep "Static hostname"
echo "------------------------------------------------"
echo "NOTE: Please restart your terminal session (or type 'exec bash') to see the change in your prompt."
