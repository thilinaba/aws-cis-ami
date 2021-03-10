#!/bin/bash

# This scrip is to create a new Puppet agent AMI for WSO2 application servers

sudo rpm -ivh https://yum.puppet.com/puppet7-release-el-7.noarch.rpm
sudo yum update -y
sudo yum upgrade -y

sudo yum install -y puppet-agent
sudo yum install -y amazon-efs-utils

sudo bash -c 'echo "export PATH=/opt/puppetlabs/bin/:$PATH" >> /etc/environment'