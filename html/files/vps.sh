#!/bin/sh
#
# CentOS 7 VPS Setup script
#
# By: Tom Reeb
# 11-11-15
#
# Instructions: Run locally as root when you first log in
#
#
# Future considerations:
# - Ask about configuring firewall ports
# - Configure fail2ban allowed IPs
# 

echo "yosup? I am a script that will help configure your new VPS!"
echo "FYI, your server will reboot after this"
echo "This server is running " cat /etc/redhat-release
echo "First things first, let's reset your root password "
passwd
echo "Cool, that's done"
echo "While we're at it, let's lock down root ssh to a tursted IP "
read -p "Enter a trusted IP: " -r trustedIP
read -p "Paste in your ssh pub key: " -r pubkey
read -p "Enter the Hostname of the VPS: " -r vpshostname
read -p "Enter the Domain name: " -r domainName
echo "Your FQDN is " $vpshostname.$domainName
echo "We should create a non-root user for you"
read -p "Enter the account name: " -r serveradminUser
useradd $serveradminUser
passwd $serveradminUser
echo ""
echo "Ok I go do things now, brb"

# Set hostname
hostnamectl set-hostname $vpshostname.$domainName

# I over engineered this, but I like it so I'm keeping it
# read -s -p "Enter the password for $serveradminUser user: " -r serveradminPasswd
# useradd $serveradminUser
# echo $serveradminPassword | passwd $serveradminUser --stdin > /dev/null 2>&1

echo "$serveradminUser ALL=(ALL) ALL" >> /etc/sudoers

mkdir /home/$serveradminUser/.ssh/
chmod 700 /home/$serveradminUser/.ssh/
touch /home/$serveradminUser/.ssh/authorized_keys
echo $pubkey > /home/$serveradminUser/.ssh/authorized_keys
chmod 600 /home/$serveradminUser/.ssh/authorized_keys
chown -R $serveradminUser:$serveradminUser /home/$serveradminUser/

# Install some repos
rpm -Uvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm > /dev/null 2>&1
rpm -iv http://dl.iuscommunity.org/pub/ius/stable/CentOS/7/x86_64/ius-release-1.0-14.ius.centos7.noarch.rpm > /dev/null 2>&1

# Update System
yum -y update > /dev/null 2>&1

# Install necessary packages
yum -y install python-pip htop tmux nano fail2ban > /dev/null 2>&1
pip install --upgrade pip > /dev/null 2>&1
pip install speedtest-cli > /dev/null 2>&1

# Enable Firewalld
systemctl enable firewalld.service > /dev/null 2>&1
systemctl start firewalld.service > /dev/null 2>&1

# Set Up DNS
echo "
DNS1=8.8.8.8
DNS2=8.8.4.4
DOMAIN=$domainName
" >> /etc/sysconfig/network-scripts/ifcfg-eth0

# Secure SSH
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

echo "
RSAAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysFile      .ssh/authorized_keys
AllowUsers root@$trsutedIP $serveradminUser
" >> /etc/ssh/sshd_config

# Install Fail2Ban
systemctl enable fail2ban > /dev/null 2>&1
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
#sed -i 's/ignoreip = 127.0.0.1/8/ignoreip = 127.0.0.1/8 8.8.8.8/' /etc/fail2ban/jail.local

echo "
[sshd]
enabled  = true" >> /etc/fail2ban/jail.local

# Reboot for good measure
echo " Oh Hi, I'm done but I'm going to reboot now"
sleep 10
shutdown -r now 'Bye Bye, See you soon!'