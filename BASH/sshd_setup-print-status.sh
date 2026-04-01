#!/bin/bash

# 1. Check for root privileges
echo "[STEP 1] Verifying administrative privileges..."
if [ "$EUID" -ne 0 ]; then 
  echo "RESULT: FAILED. Please run with sudo."
  exit 1
fi
echo "RESULT: SUCCESS. Running as root."

echo "------------------------------------------------"

# 2. Package Management (Install/Update)
echo "[STEP 2] Checking for openssh-server package..."
if rpm -q openssh-server &> /dev/null; then
    echo "STATUS: Package already present. Attempting update..."
    if command -v dnf &> /dev/null; then
        dnf update -y openssh-server &> /dev/null
    else
        yum update -y openssh-server &> /dev/null
    fi
else
    echo "STATUS: Package missing. Attempting installation..."
    if command -v dnf &> /dev/null; then
        dnf install -y openssh-server &> /dev/null
    else
        yum install -y openssh-server &> /dev/null
    fi
fi

if [ $? -eq 0 ]; then
    echo "RESULT: SUCCESS. Package is now at the latest version."
else
    echo "RESULT: FAILED. Could not install/update openssh-server."
    exit 1
fi

echo "------------------------------------------------"

# 3. Configuration Validation
echo "[STEP 3] Validating /etc/ssh/sshd_config syntax..."
sshd -t
if [ $? -eq 0 ]; then
    echo "RESULT: SUCCESS. Configuration file is valid."
else
    echo "RESULT: FAILED. Syntax error found in sshd_config. Check the file before restarting."
    exit 1
fi

echo "------------------------------------------------"

# 4. Service Activation
echo "[STEP 4] Enabling and restarting sshd service..."
systemctl enable sshd &> /dev/null && systemctl restart sshd &> /dev/null
if [ $? -eq 0 ]; then
    echo "RESULT: SUCCESS. sshd is active and set to start on boot."
else
    echo "RESULT: FAILED. Could not start sshd service."
    exit 1
fi

echo "------------------------------------------------"

# 5. Firewall Rules
echo "[STEP 5] Checking firewall status..."
if systemctl is-active --quiet firewalld; then
    echo "STATUS: firewalld is active. Applying SSH rule..."
    firewall-cmd --permanent --add-service=ssh &> /dev/null
    firewall-cmd --reload &> /dev/null
    if [ $? -eq 0 ]; then
        echo "RESULT: SUCCESS. Firewall updated."
    else
        echo "RESULT: FAILED. Could not update firewall rules."
    fi
else
    echo "RESULT: SKIPPED. firewalld is not running, no rules needed."
fi

echo "------------------------------------------------"
echo "FINAL VERIFICATION: $(ssh -V 2>&1)"
echo "Script execution finished."
