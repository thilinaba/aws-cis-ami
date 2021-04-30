
# Building a CIS Hardened AMI on AWS for FREE
## (Technical Documentation)
If you are new to Packer and AWS, Please refer to my [Blog Post](https://medium.com/cloud-life/building-a-cis-hardened-ami-on-aws-for-free-87b482b52ccb) for the beginer's guide for this repository and complete setting up the prerequisite. 

## Directory Structure
### Root directory
This section describes the use of the files residing within the root directory of the repository.

#### [cis-ami.pkr.hcl](https://github.com/thilinaba/aws-cis-ami/blob/dev/cis-ami.pkr.hcl)
This is the Packer template which we used to run with Packer tool. For a basic build, we don't expect you to make any modifications to this file.

#### [variables.json](https://github.com/thilinaba/aws-cis-ami/blob/dev/variables.json)
This is the main variables file which allows you to customize the build accourding to your AWS account and region.  You need to customize the update the parameters of this file correctly, before you run the Packer Build. The definition and use of each variable is as follows.

| Variable | Definition |
| ------ | ------ |
| profile | The AWS CLI Profile which you use to run Packer with. Refer to the  "Setup AWS CLI" section of the [Blog Post](https://medium.com/cloud-life/building-a-cis-hardened-ami-on-aws-for-free-87b482b52ccb) more info  |
| region | The region in which the AMI to be built |
| source_ami | The respective Amazon Linux 2 base AMI ID for your region. Refer to "Building the AMI" section of the [Blog Post](https://medium.com/cloud-life/building-a-cis-hardened-ami-on-aws-for-free-87b482b52ccb) more info |
| vpc_id | The VPC ID in which the resources to be created |
| subnet_id | A Public subnet which Packer can create the temporary resources for the build |
| instance_type | Packer will use an EC2 instance with the type mentioned here to build the AMIs. However, you can use the resulting AMI with any type of instance later. Keep the default “t3.micro” to stay within the Free tear, unless there is a specific requirement. |
| ami_name_prefix | The resulting AMI will be named with this prefix and a timestamp. You can change this to a preferred name or keep it as default. |

### ./files directory
We have a set of configuration files which configures the default [Amazon Linux 2](https://aws.amazon.com/amazon-linux-2/) OS with security hardening parameters that CIS Level 1 Benchmark suggests.

#### [00-motd-warning](https://github.com/thilinaba/aws-cis-ami/blob/dev/files/00-motd-warning)

This is just an SSH Login warning banner. We have added a very basic warning message here. You can customize this according to your organization's needs.

#### [00-rsyslog-permissions.conf](https://github.com/thilinaba/aws-cis-ami/blob/dev/files/00-rsyslog-permissions.conf)

This file sets a more private file permission level (mask) to the log files created by `rsyslog` service.

Default value `$FileCreateMode 0600`


#### [cis-limits.conf](cis-limits.conf)
This file [restricts core dumps](https://secscan.acron.pl/centos7/1/5/1) of the system.


#### [cis-modprobe.conf](https://github.com/thilinaba/aws-cis-ami/blob/dev/files/cis-modprobe.conf)

##### File system Level hardening
These configurations will disable uncommon / vulnerable filesystems from mounting to the system. Rmove the respective line if a particular filesystem is required within your system.
| Config | Definition |
| ------ | ------ |
| install squashfs /bin/true | Disable mounting `squashfs` file system |
| install cramfs /bin/true | Disable mounting `cramfs` file system |
| install freevxfs /bin/true | Disable mounting `freevxfs` file system |
| install jffs2 /bin/true | Disable mounting `jffs2` file system |
| install hfs /bin/true | Disable mounting `hfs` file system |
| install hfsplus /bin/true | Disable mounting `hfsplus` file system |
| install udf /bin/true | Disable mounting `udf` file system |

##### Network Level hardening
These configurations will disable uncommon / vulnerable network protocols from the system. Rmove the respective line if a particular protocol is required within your system.
| Config | Definition |
| ------ | ------ |
| options ipv6 disable=1 | Disable `IP Version 6`. |
| install dccp /bin/true | Disable `Datagram Congestion Control Protocol (DCCP)`. |
| install sctp /bin/true | Disable `Stream Control Transmission Protocol (SCTP)`. |
| install rds /bin/true | Disable `Reliable Datagram Sockets (RDS)`. |
| install tipc /bin/true | Disable `Transparent Inter-Process Communication (TIPC)`. |

#### [cis-sysctl.conf](https://github.com/thilinaba/aws-cis-ami/blob/dev/files/cis-sysctl.conf)
This file contains a set of kernel parameters which will secure system memory and network communications.

Please note that the following networkng configurations (`net.ipv4`) are for IP version 4 protocol only. We use only IPv4 configurations here because we disabled IPv6 protocol from the system in above `cis-modprobe.conf` file. If you enable IPv6, make sure you add the relevant configs here in `cis-sysctl.conf`

| Config | Definition |
| ------ | ------ |
| fs.suid_dumpable = 0 | Even though we disabled core dumps in `cis-limits.conf`, Programs with elevated privileges with `setuid` might be still able to perform a core dump. That is blocked here |
| kernel.randomize_va_space = 2 | Randomize the memory address space which will prevent buffer overflow attacks |
| net.ipv4.ip_forward = 0 | Disable network packet forwarding from one interface to another |
| net.ipv4.conf.all.send_redirects = 0 | Disable accepting IPv4 ICMP redirected packets |
| net.ipv4.conf.default.send_redirects = 0 | Disable accepting IPv4 ICMP redirected packets |
| net.ipv4.conf.all.accept_source_route = 0 | Disable accepting source routed traffic |
| net.ipv4.conf.default.accept_source_route = 0 | Disable accepting source routed traffic |
| net.ipv4.conf.all.accept_redirects = 0 | Disable accepting ICMP redirects |
| net.ipv4.conf.default.accept_redirects = 0 | Disable accepting ICMP redirects |
| net.ipv4.conf.all.secure_redirects = 0 | Disable sending ICPM redirected packets |
| net.ipv4.conf.default.secure_redirects = 0 | Disable sending ICPM redirected packets |
| net.ipv4.conf.all.log_martians = 1 | Log all invalid packets received |
| net.ipv4.conf.default.log_martians = 1 | Log all invalid packets received |
| net.ipv4.conf.default.rp_filter = 1 | Strictly validate revers path forwarding |
| net.ipv4.tcp_syncookies = 1 | Enable TCP SYN Cookies to prevent SYN Flooding attacks |
| net.ipv4.icmp_echo_ignore_broadcasts = 1 | Ignore broadcasted ICMP (ping) requests |
| net.ipv4.icmp_ignore_bogus_error_responses = 1 | Ignore bogus ICMP error messages |
| net.ipv6.conf.all.accept_ra = 0 | Stop accepting IPv6 router advertisements |
| net.ipv6.conf.default.accept_ra = 0 | Stop accepting IPv6 router advertisements |
| net.ipv6.conf.all.accept_redirects = 0 | Stop accepting IPv6 redirects |
| net.ipv6.conf.default.accept_redirects = 0 | Stop accepting IPv6 redirects |

##### [ssh_banner](https://github.com/thilinaba/aws-cis-ami/blob/dev/files/ssh_banner)
This is just a warning banner that will be prompted to the users who are trying to SSH into the server. Feel free to edit it with a custom banner to match your Organizational policy.

( -- more details to be added for the other files and scripts -- )

## Building the AMI
Once the prerequisite are completed according to the [Blog Post](https://medium.com/cloud-life/building-a-cis-hardened-ami-on-aws-for-free-87b482b52ccb), run the following commands to Validate and Build the AMI.

#### Validate template
```sh 
packer validate -var-file=variables.json cis-ami.pkr.hcl
```
If everything is properly in place, the validate command will give you an “empty output”. If there are errors, the errors will be printed.

#### Build the AMI
```sh
packer build  -var-file=variables.json cis-ami.pkr.hcl
```

This will connect to your AWS account using the credentials you set up at the [prerequisite](https://medium.com/cloud-life/building-a-cis-hardened-ami-on-aws-for-free-87b482b52ccb) section and build the AMI. You can find the image in your AWS Console -> EC2 -> AMIs section of the respective region.
