terraform {
  required_version = ">= 0.13.0"
  required_providers {
    spotinst = {
      source = "spotinst/spotinst"
    }
  }
}

### Providers ###
provider "spotinst" {
  token   = var.spotinst_token
  account = var.spotinst_account
}
provider "aws" {
  region = var.region
  profile = var.aws_profile
}
##################

### Data Resources ###
data "aws_eks_cluster" "cluster" {
  name    = var.cluster_name
}
data "aws_eks_cluster_auth" "cluster" {
  name    = var.cluster_name
}
data "aws_ami" "eks_worker" {
  filter {
    name   = "name"
    values = [local.worker_ami_name_filter]
  }
  most_recent = true
  owners = ["amazon"]
}
##################

### Local Variable ###
locals {
  worker_ami_name_filter = "amazon-eks-node-${data.aws_eks_cluster.cluster.version}-v*"
}
##################

## Create Ocean Cluster in Spot.io
resource "spotinst_ocean_aws" "ocean" {
  name                                = var.cluster_name
  controller_id                       = var.cluster_name
  region                              = var.region
  max_size                            = var.max_size
  min_size                            = var.min_size
  desired_capacity                    = var.desired_capacity
  subnet_ids                          = var.subnet_ids
  blacklist                           = var.blacklist
  user_data                           = var.user_data !=null ? var.user_data : <<-EOF
                                          #!/bin/bash
                                          set -o xtrace
                                          /etc/eks/bootstrap.sh ${var.cluster_name}
                                      EOF

  image_id                            = var.ami_id != null ? var.ami_id : data.aws_ami.eks_worker.id
  security_groups                     = var.security_groups
  key_name                            = var.key_name
  iam_instance_profile                = var.worker_instance_profile_arn
  associate_public_ip_address         = var.associate_public_ip_address
  root_volume_size                    = var.root_volume_size
  monitoring                          = var.monitoring
  ebs_optimized                       = var.ebs_optimized
  use_as_template_only                = var.use_as_template_only
  load_balancers {
    arn                               = var.load_balancer_arn
    name                              = var.load_balancer_name
    type                              = var.load_balancer_type
  }
  ## Required Tags ##
  tags {
    key   = "Name"
    value = "${var.cluster_name}-ocean-cluster-node"
  }
  tags {
    key   = "kubernetes.io/cluster/${var.cluster_name}"
    value = "owned"
  }
  # Additional Tags
  dynamic tags {
    for_each = var.tags == null ? [] : var.tags
    content {
      key = tags.value["key"]
      value = tags.value["value"]
    }
  }
  # Strategy
  fallback_to_ondemand                = var.fallback_to_ondemand
  utilize_reserved_instances          = var.utilize_reserved_instances
  draining_timeout                    = var.draining_timeout
  grace_period                        = var.grace_period
  spot_percentage                     = var.spot_percentage

  # Auto Scaler Configurations
  autoscaler {
    autoscale_is_enabled          = var.autoscale_is_enabled
    autoscale_is_auto_config      = var.autoscale_is_auto_config
    autoscale_cooldown            = var.autoscale_cooldown
    auto_headroom_percentage      = var.auto_headroom_percentage
    autoscale_headroom {
      cpu_per_unit                = var.cpu_per_unit
      gpu_per_unit                = var.gpu_per_unit
      memory_per_unit             = var.memory_per_unit
      num_of_units                = var.num_of_unit
    }
    autoscale_down {
      max_scale_down_percentage   = var.max_scale_down_percentage
    }
    resource_limits {
      max_vcpu                    = var.max_vcpu
      max_memory_gib              = var.max_memory_gib
    }
  }

  # Policy when config is updated
  update_policy {
    should_roll               = var.should_roll
    roll_config {
      batch_size_percentage   = var.batch_size_percentage
    }
  }

  ## Scheduled Task ##
  scheduled_task {
    shutdown_hours {
      is_enabled                  = var.shutdown_is_enabled
      time_windows                = var.shutdown_time_windows
    }
    tasks {
      is_enabled                  = var.taskscheduling_is_enabled
      cron_expression             = var.cron_expression
      task_type                   = var.task_type
    }
  }

  # Prevent Capacity from changing during updates
  lifecycle {
    ignore_changes = [
      desired_capacity
    ]
  }
}