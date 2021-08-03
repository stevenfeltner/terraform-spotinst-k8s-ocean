# terraform-spotinst-k8s-ocean
Spotinst Terraform Module to integrate existing k8s with Ocean

## Prerequisites

Installation of the Ocean controller is required by this resource. You can accomplish this by using the [spotinst/ocean-controller](https://registry.terraform.io/modules/spotinst/ocean-controller/spotinst) module as follows:

```hcl
module "k8s-ocean" {
  ...
}

module "ocean-controller" {
  source = "spotinst/ocean-controller/spotinst"

  # Credentials.
  spotinst_token   = "redacted"
  spotinst_account = "redacted"

  # Configuration.
  cluster_identifier = var.cluster_name
}
```

~> You must configure the same `cluster_identifier` both for the Ocean controller and for the `spotinst_ocean_aws` resource. The `k8s-ocean` module will use the cluster name as the identifier. Ensure this is also used in the controller config

## Usage
```hcl
module "k8s-ocean" {
  source = "../"

  # Spot.io Credentials
  spotinst_token              = "redacted"
  spotinst_account            = "redacted"

  # Configuration
  cluster_name                = "Sample-EKS"
  region                      = "us-west-2"
  subnet_ids                  = ["subnet-12345678","subnet-12345678"]
  worker_instance_profile_arn = "arn:aws:iam::123456789:instance-profile/Spot-EKS-Workshop-Nodegroup"
  security_groups             = ["sg-123456789","sg-123456789"]

  # Additional Tags
  tags = [{key = "CreatedBy", value = "Terraform"}]
}
```

## Providers

| Name | Version |
|------|---------|
| spotinst/spotinst | >= 1.30.0 |

## Modules
* `k8s-ocean` - Creates Ocean Cluster
* `ocean-controller` - Create and installs spot ocean controller pod [Doc](https://registry.terraform.io/modules/spotinst/ocean-controller/spotinst/latest)
* `k8s-ocean-launchspec` - (Optional) Add custom virtual node groups [Doc](https://registry.terraform.io/modules/stevenfeltner/k8s-ocean-launchspec/spotinst/latest)

## Documentation

If you're new to [Spot](https://spot.io/) and want to get started, please checkout our [Getting Started](https://docs.spot.io/connect-your-cloud-provider/) guide, available on the [Spot Documentation](https://docs.spot.io/) website.

## Getting Help

We use GitHub issues for tracking bugs and feature requests. Please use these community resources for getting help:

- Ask a question on [Stack Overflow](https://stackoverflow.com/) and tag it with [terraform-spotinst](https://stackoverflow.com/questions/tagged/terraform-spotinst/).
- Join our [Spot](https://spot.io/) community on [Slack](http://slack.spot.io/).
- Open an issue.

## Community

- [Slack](http://slack.spot.io/)
- [Twitter](https://twitter.com/spot_hq/)

## Contributing

Please see the [contribution guidelines](CONTRIBUTING.md).