#!/bin/bash
echo "This script will be updating the hostname of the system and will add it to the /etc/hosts file."
read -p "Enter the new hostname: " HNAME

#have to run the following command with sudo!
sudo hostnamectl set-hostname $HNAME

#Now updating the /etc/hosts file
sudo sed -i "/^127.0.0.1/ s/$/ $HNAME/" /etc/hosts
sudo sed -i "/^::1/ s/$/ $HNAME/" /etc/hosts
