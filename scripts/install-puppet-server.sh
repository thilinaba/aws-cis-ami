#!/bin/bash

# This scrip is to create a new Puppet server AMI

sudo rpm -ivh https://yum.puppet.com/puppet7-release-el-7.noarch.rpm
sudo yum update -y
sudo yum upgrade -y

sudo yum install -y puppetserver

sudo bash -c 'echo "export PATH=/opt/puppetlabs/bin/:$PATH" >> /etc/environment'
sudo bash -c 'echo "autosign = true" >> /etc/puppetlabs/puppet/puppet.conf'
sudo bash -c 'echo "environment = wso2puppet" >> /etc/puppetlabs/puppet/puppet.conf'
sudo bash -c 'echo "environmentpath =  /mnt" >> /etc/puppetlabs/puppet/puppet.conf'

sudo yum install -y git
sudo git config --system credential.helper '!aws codecommit credential-helper $@'
sudo git config --system credential.UseHttpPath true