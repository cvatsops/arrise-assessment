terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

module "ec2_fleet" {
  source = "../../modules/ec2-multi"

  instances = {
    web-01 = {
      ami                     = "ami-0abcd1234ef567890"
      instance_type           = "t3.micro"
      key_name                = "web-01-key"
      subnet_id               = "subnet-aaa111"
      vpc_security_group_ids  = ["sg-web-0001"]
      root_volume_type        = "gp3"
      root_volume_size        = 20
      environment              = "dev"
      owner                    = "chaitanya"
      prevent_destroy          = false
    }

    app-01 = {
      ami                     = "ami-0abcd1234ef567890"
      instance_type           = "t3.small"
      key_name                = "app-01-key"
      subnet_id               = "subnet-aaa111"
      vpc_security_group_ids  = ["sg-app-0001"]
      root_volume_type        = "gp3"
      root_volume_size        = 30
      environment              = "dev"
      owner                    = "chaitanya"
      prevent_destroy          = false
    }

    cache-01 = {
      ami                     = "ami-0abcd1234ef567890"
      instance_type           = "r6g.medium"
      key_name                = "cache-01-key"
      subnet_id               = "subnet-bbb222"
      vpc_security_group_ids  = ["sg-cache-0001"]
      root_volume_type        = "gp2"
      root_volume_size        = 20
      environment              = "dev"
      owner                    = "chaitanya"
      prevent_destroy          = false
    }
    
    db-01 = {
      ami                     = "ami-0abcd1234ef567890"
      instance_type           = "m6i.large"
      key_name                = "db-01-key"
      subnet_id               = "subnet-bbb222"
      vpc_security_group_ids  = ["sg-db-0001"]
      root_volume_type        = "io2"
      root_volume_size        = 100
      root_volume_iops        = 4000
      environment              = "dev"
      owner                    = "chaitanya"
      prevent_destroy          = true
    }

    bastion-01 = {
      ami                     = "ami-0abcd1234ef567890"
      instance_type           = "t3.nano"
      key_name                = "bastion-01-key"
      subnet_id               = "subnet-ccc333"
      vpc_security_group_ids  = ["sg-bastion-0001"]
      root_volume_type        = "gp3"
      root_volume_size        = 10
      environment              = "dev"
      owner                    = "chaitanya"
      prevent_destroy          = false
    }
  }
}

output "instance_ids" {
  value = module.ec2_fleet.instance_ids
}

output "instance_private_ips" {
  value = module.ec2_fleet.instance_private_ips
}
