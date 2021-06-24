#Can move these to variables
locals {
  spotinst_token = ""
  spotinst_account = "act-12345"
  cluster_name = "EKS-Workshop"
}

## Create Ocean Cluster in Spot.io and deploy controller pod ##
module "ocean_eks" {
  source = "../"

  # Spot.io Credentials
  spotinst_token              = local.spotinst_token
  spotinst_account            = local.spotinst_account

  # Configuration
  cluster_name                = local.cluster_name
  region                      = "us-west-2"
  subnet_ids                  = ["subnet-12345678","subnet-12345678"]
  vpc_id                      = "vpc-123456789"

  # Default Worker node specifics
  # If no AMI is provided will use most up to date one
  #ami_id                      = ""
  # instance profile arn should have the EKSWorkerNodePolicy attached
  worker_instance_profile_arn = "arn:aws:iam::123456789:instance-profile/Spot-EKS-Workshop-Nodegroup"
  security_groups             = ["sg-123456789","sg-123456789"]

  # Additional Tags
  tags = [{key = "CreatedBy", value = "terraform"}]
}


## Outputs ##
output "ocean_id" {
  value = module.ocean_eks.ocean_id
}
