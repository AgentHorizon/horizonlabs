#!/bin/bash

################################################################################
# Script Name: set-ip.sh
# Description: Interactive utility to configure static IPv4 addresses, 
#              gateways, and DNS settings. Summarizes changes upon exit.
# Author:      Kshitiz Awasthi
# Date:        2026-04-01
# Usage:       sudo ./set-ip.sh
################################################################################

# 1. Root Check
if [ "$EUID" -ne 0 ]; then 
  echo "[ERROR] Please run with sudo or as root."
  exit 1
fi

# 2. List Devices and Select
nmcli device status
echo ""
read -p "Enter the DEVICE name to configure (e.g., ens33): " DEVICE

if ! nmcli device show "$DEVICE" > /dev/null 2>&1; then
    echo "[ERROR] Device '$DEVICE' not found."
    exit 1
fi

# 3. The Interactive Loop
while true; do
    echo "------------------------------------------------"
    echo "CURRENT CONFIGURATION FOR $DEVICE:"
    nmcli -f IP4.ADDRESS,IP4.GATEWAY,IP4.DNS device show "$DEVICE"
    echo "------------------------------------------------"
    echo "What would you like to update?"
    echo "1) Change IP Address & Subnet"
    echo "2) Change Default Gateway"
    echo "3) Change DNS Servers"
    echo "4) SAVE & APPLY CHANGES NOW (Restart Interface)"
    echo "5) EXIT SCRIPT"
    echo "------------------------------------------------"
    read -p "Selection [1-5]: " CHOICE

    case $CHOICE in
        1)
            read -p "Enter new IP/Subnet (e.g., 192.168.1.10/24): " NEW_IP
            nmcli con mod "$DEVICE" ipv4.addresses "$NEW_IP"
            nmcli con mod "$DEVICE" ipv4.method manual
            echo "[OK] IP updated in configuration."
            ;;
        2)
            read -p "Enter new Gateway (e.g., 192.168.1.1): " NEW_GW
            nmcli con mod "$DEVICE" ipv4.gateway "$NEW_GW"
            echo "[OK] Gateway updated in configuration."
            ;;
        3)
            read -p "Enter DNS (e.g., 8.8.8.8,1.1.1.1): " NEW_DNS
            nmcli con mod "$DEVICE" ipv4.dns "$NEW_DNS"
            echo "[OK] DNS updated in configuration."
            ;;
        4)
            echo "[ACTION] Applying changes to $DEVICE..."
            nmcli con up "$DEVICE"
            if [ $? -eq 0 ]; then
                echo "RESULT: SUCCESS. Settings are now live."
                break 
            else
                echo "RESULT: FAILED. Check your values and try again."
            fi
            ;;
        5)
            echo "Exiting script..."
            break
            ;;
        *)
            echo "[!] Invalid selection. Please choose 1-5."
            ;;
    esac
    
    echo ""
    echo "Returning to menu... You can now choose another option or Apply."
done

# 4. Final Summary Output
echo "================================================"
echo "FINAL NETWORK SUMMARY FOR $DEVICE"
echo "================================================"
nmcli -f IP4.ADDRESS,IP4.GATEWAY,IP4.DNS device show "$DEVICE"
echo "================================================"
echo "[FINISH] Configuration complete. Have a great day!"
