variable "instance_name" {
  description = "Enter your instance name. First initial and last name. Example: jsmith"
  type        = string
}

# Get the latest Linux AMI by tag name RHEL 8.5 N
data "aws_ami" "linux" {
  most_recent = true

  # Use Shared Services Account
  owners = ["793022030544"]

  name_regex = "RHEL8_.?-CFG-AMI-*"
  tags = {
    Name = "RHEL 8.5 N"
  }
  filter {
    name   = "block-device-mapping.encrypted"
    values = ["true"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_instance" "web" {
  ami           = data.aws_ami.linux.id
  instance_type = "t3.small"

  key_name = "infra-key"
  # subnet_id              = "subnet-0ef14b887e41af692"
  subnet_id              = "subnet-0009ab6bce0baf4b0" # POC web subnet
  vpc_security_group_ids = ["sg-0e02e0005de6d2e45", "sg-0ee9f04338b138f07"]
  iam_instance_profile   = "cfg-infrastructure-ec2-us-east-1"

  tags = {
    Name            = "${var.instance_name}-infra-instance",
    Criticality     = "Tier 3",
    Requestor       = "cfg-cldsvc-app-automation-role",
    Support         = "gaston.m.cuellar@citizensbank.com",
    ApplicationID   = "05602",
    ApplicationName = "testScheduleTag",
    BackupPlan      = "NonProd",
    "Patch Group"   = "rehydrate",
    BusinessMapping = "AWS",
    Schedule        = "Default"
    CostCenter      = "2009160",
    DataClass       = "internal",
    donotdelete     = "true"
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 50
    delete_on_termination = true
    encrypted             = true
    kms_key_id            = "arn:aws:kms:us-east-1:344776024863:key/0e1a1450-a362-48c7-a0cb-28aa15538814"
  }
}

provider "aws" {
  region = "us-east-1"
}