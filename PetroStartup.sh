#!/bin/bash
apt update
apt install -y curl jq zip unzip wget

mkdir -p /mnt/server
cd /mnt/server

rm -f start.sh
rm -f install.txt
wget https://raw.githubusercontent.com/TheAFKGamer10/MultiMinecraftPterodactyl/main/Install.sh
chmod -x Install.sh
echo -e "Installation Started. Please be patient as this can take a while depending on your server specs."
bash Install.sh &> install.txt
rm -f Install.sh

echo -e "Installation Complete"
exit 0