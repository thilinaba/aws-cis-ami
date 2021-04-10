# This will build a CIS Level 1 hardened AMI from Amazon Linux 2 base AMI

# Validate the template
#   eg: packer validate cis-ami.pkr.hcl 

# Set the correct variables in the variables.json file

# A sample build command would look like this
# packer build -var-file=variables.json cis-ami.pkr.hcl 

# If you don't set the profile variable as above, it will take the following as default
variable "profile" {
  type =  string
  default = "default"
}

# Use the Amazon Linux 2 (latest) AMI as the source_ami
variable "source_ami" {
  type = string
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

variable "ami_name_prefix" {
  type = string
  default = "cis-hardened-aws-ami"
}

# Use the Amazon Linux 2 (latest) AMI as the source_ami
locals { 
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")

  standard_tags = {
    BaseOS = "Amazon Linux 2"
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
  source_ami    = "${var.source_ami}"
  ssh_username  = "ec2-user"

  // Set the AMI's Name tag with timestamp
  tag {
    key         = "Name"
    value       = "${var.ami_name_prefix}-${local.timestamp}"
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