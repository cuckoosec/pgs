#!/bin/bash

archive() {
	sudo cp --archive "${1}" "${1}-COPY-$(date+'%Y%m%d%H%M%S')"
}

echo "Update system"
sudo apt update && sudo apt full-upgrade -y

echo "Install packages"
wget https://github.com/cuckoosec/dotfiles/blob/main/debian.server.packages
sudo apt install -y "$(cat debian.server.packges)"

sudo -i
NAME=sysadmn
adduser $NAME
groupadd sshusers suusers sudousers

usermod -a -G {sshusers,suusers,sudousers} $NAME

echo "Setup SSH"
archive /etc/ssh/sshd_config
curl https://raw.githubusercontent.com/cuckoosec/dotfiles/main/sshd_config \
  | sudo tee /etc/sshd_config
sudo sed -i "s/# AllowGroups sshusers/AllowGroups sshusers/g" /etc/sshd_config

echo "Remove Short Diffie-Hellman Keys"
archive /etc/ssh/moduli
sudo awk '$5 >= 3071' /etc/ssh/moduli | sudo tee /etc/ssh/moduli.tmp
sudo mv /etc/ssh/moduli.tmp /etc/ssh/moduli

echo "Secure sudoers file"
archive /etc/sudoers

echo "Setting up firewall"
sudo ufw default deny outgoing comment 'deny all outgoing traffic'
sudo ufw default deny incoming comment 'deny all incoming traffic'
sudo ufw limit in ssh comment 'allow SSH connections in'
sudo ufw allow out ftp comment 'allow FTP traffic out'
sudo ufw allow out whois comment 'allow whois'
sudo ufw allow out 53 comment 'allow DNS calls out'
sudo ufw allow out 67 comment 'allow the DHCP client to update'
sudo ufw allow out 68 comment 'allow the DHCP client to update'
sudo ufw allow out 123 comment 'allow NTP out'
sudo ufw allow out http comment 'allow HTTP traffic out'
sudo ufw allow out https comment 'allow HTTPS traffic out'


echo "Blocking a bunch of bullshit..."
curl https://someonewhocares.org/hosts/hosts | sudo tee -a /etc/hosts

echo "Restarting SSH"
sudo service sshd restart
echo "Remove ubuntu default user"
sudo deluser ubuntu --remove-home