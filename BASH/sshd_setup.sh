#!/bin/bash

# 1. Check for root privileges (EUID 0)
if [ "$EUID" -ne 0 ]; then 
  echo "Error: This script must be run with sudo or as root."
  exit 1
fi

echo "--- Starting SSHD Setup & Verification ---"

# 2. Check if openssh-server is already installed
if rpm -q openssh-server &> /dev/null; then
    echo "[FOUND] openssh-server is already installed."
    echo "[UPDATE] Checking for updates..."
    # Update to latest version (using dnf if available, else yum)
    if command -v dnf &> /dev/null; then
        dnf update -y openssh-server
    else
        yum update -y openssh-server
    fi
else
    echo "[MISSING] openssh-server not found. Installing..."
    if command -v dnf &> /dev/null; then
        dnf install -y openssh-server
    else
        yum install -y openssh-server
    fi
fi

# 3. Verify configuration syntax before proceeding
echo "[CONFIG] Checking /etc/ssh/sshd_config for errors..."
sshd -t
if [ $? -ne 0 ]; then
    echo "Error: SSH configuration has errors. Please fix /etc/ssh/sshd_config."
    exit 1
fi
echo "[CONFIG] Syntax is valid."

# 4. Enable and Start the service
echo "[SERVICE] Ensuring sshd is enabled and running..."
systemctl enable sshd
systemctl restart sshd

# 5. Firewall Configuration
if systemctl is-active --quiet firewalld; then
    echo "[FIREWALL] firewalld is active. Allowing SSH..."
    firewall-cmd --permanent --add-service=ssh
    firewall-cmd --reload
else
    echo "[FIREWALL] firewalld is not running. Skipping firewall rules."
fi

# 6. Final Status Check
echo "--- Verification Results ---"
ssh -V
systemctl is-active sshd && echo "SSHD Status: Running" || echo "SSHD Status: Failed"
echo "Setup complete."
