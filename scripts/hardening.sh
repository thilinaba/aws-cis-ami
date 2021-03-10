#!/bin/bash

# This script does the AMI harening tasks by executing bash commands
# We can't directly copy the conf files to "root" owned directories via packer file provisioned
# So we put the files in /tmp and move them by executing this shell script

sudo cp /tmp/files/cis-limits.conf /etc/security/limits.d
sudo cp /tmp/files/cis-modprobe.conf /etc/modprobe.d
sudo cp /tmp/files/cis-sysctl.conf /etc/sysctl.d
sudo cp /tmp/files/sshd_config /etc/ssh
sudo cp /tmp/files/ssh_banner /etc/ssh
sudo cp /tmp/files/00-motd-warning /etc/update-motd.d
sudo cp /tmp/files/00-rsyslog-permissions.conf /etc/rsyslog.d

sudo chmod 600 /etc/ssh/sshd_config
sudo chmod 755 /etc/update-motd.d/00-motd-warning
sudo chmod 600 /boot/grub2/grub.cfg 

sudo find /var/log -type f -exec chmod g-wx,o-rwx {} +
sudo chmod og-rwx /etc/cron*

rm -rf /tmp/files