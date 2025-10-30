terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "terraform-state-devops-portfolio"
    key    = "infrastructure/terraform.tfstate"
    region = "us-west-2"
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project     = "DevOps Portfolio"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "Alam"
    }
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  environment         = var.environment
}

# EC2 Module
module "ec2" {
  source = "./modules/ec2"
  
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  private_subnet_ids  = module.vpc.private_subnet_ids
  instance_type       = var.instance_type
  key_name           = var.key_name
  environment        = var.environment
}

# RDS Module
module "rds" {
  source = "./modules/rds"
  
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  db_instance_class  = var.db_instance_class
  db_name           = var.db_name
  db_username       = var.db_username
  environment       = var.environment
}
