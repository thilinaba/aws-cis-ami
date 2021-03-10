# This will build the required a CIS hardened AMI from Amazon Linux 2 base AMI

# Validate the template
#   eg: packer validate cis-ami.pkr.hcl 

# Then run the packer build command with the correct profile name set in your ~/.aws/credentials
#   eg: packer build cis-ami.pkr.hcl -var 'profile=aws-admin'

# If you don't set the profile variable as above, it will take the following as default
variable "profile" {
  type =  string
  default = "default"
}

# Use the Amazon Linux 2 (latest) AMI as the source_ami
variable "source_ami" {
  type = string
  default = "ami-0915bcb5fa77e4892"
}


variable "region" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "subnet_id" {
  type = string
}
variable "instance_type" {
  type = string
  default = "t3.micro"
}


# Use the Amazon Linux 2 (latest) AMI as the source_ami
locals { 
  ami_name_prefix = "cis-hardened-aws-ami"
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")

  standard_tags = {
    Name   = "cis-hardened-aws-ami"
    BaseAMI = "Amazon Linux 2"
  }

}

# Set the VPC and Subnet to somewhat which has Internet accesss (Could be any public subnet)
# Packer will take care of the rest
source "amazon-ebs" "cis-ami" {
  profile       = "${var.profile}"
  ami_name      = "${var.ami_name_prefix}-${local.timestamp}"
  instance_type = "${var.instance_type}"
  region        = "${var.region}"
  vpc_id        = "${var.vpc_id}"
  subnet_id     = "${var.subnet_id}"
  associate_public_ip_address = "true"

  // Amazon Linux 2 AMI ID
  source_ami    = "${local.source_ami}"
  ssh_username  = "ec2-user"

  // Set the AMI's Name tag with timestamp
  tag {
    key         = "Name"
    value       = "${local.ami_name_prefix}-${local.timestamp}"
  }

  // Set the default tags for the AMI
  dynamic "tag" {
    for_each = local.standard_tags
    content {
      key                 = tag.key
      value               = tag.value
    }
  }
}

# Building the Puppet Server AMI
build {
  sources = ["source.amazon-ebs.cis-ami"]

  provisioner "file"{
    source = "./files"
    destination = "/tmp"
  }

  provisioner "shell" {
    script = "./scripts/hardening.sh"
  }

  provisioner "shell" {
    script = "./scripts/install.sh"
  }

}