#!/bin/bash

################################################################################
# Script Name: remote-fetch.sh
# Description: A utility to download files/directories from a remote Linux 
#              server using either SCP or RSYNC.
# Author:      Kshitiz Awasthi
# Date:        2026-04-01
# Usage:       ./remote-fetch.sh
# Requirements: OpenSSH (ssh, scp) and rsync installed on both local and remote.
################################################################################

# 1. Gather Connection Details
echo "--- Remote Connection Details ---"
read -p "Enter Remote IP or Hostname: " REMOTE_HOST
read -p "Enter Remote Username: " REMOTE_USER
echo ""

# 2. Gather File Details
echo "--- File Selection ---"
echo "Note: For directories, rsync is generally faster."
read -p "Enter full path of the remote file/folder: " REMOTE_PATH
read -p "Enter local destination path (use '.' for current folder): " LOCAL_PATH

echo "------------------------------------------------"
echo "Choose your transfer method:"
echo "1) SCP   (Best for simple, one-time file copies)"
echo "2) RSYNC (Best for large folders or resuming interrupted tasks)"
read -p "Selection [1 or 2]: " CHOICE
echo "------------------------------------------------"

# 3. Execute based on choice
case $CHOICE in
    1)
        echo "[ACTION] Starting SCP transfer..."
        echo "Note: You will be prompted for the remote user's password below."
        # -r allows for recursive directory copying
        scp -r "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}" "${LOCAL_PATH}"
        
        if [ $? -eq 0 ]; then
            echo "RESULT: SCP Transfer Successful."
        else
            echo "RESULT: SCP Transfer Failed."
        fi
        ;;
        
    2)
        echo "[ACTION] Starting RSYNC transfer..."
        echo "Note: You will be prompted for the remote user's password below."
        # -a: archive mode, -v: verbose, -z: compress, -P: progress/resume
        rsync -avzP "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}" "${LOCAL_PATH}"
        
        if [ $? -eq 0 ]; then
            echo "RESULT: RSYNC Transfer Successful."
        else
            echo "RESULT: RSYNC Transfer Failed."
        fi
        ;;
        
    *)
        echo "Invalid selection. Exiting."
        exit 1
        ;;
esac
