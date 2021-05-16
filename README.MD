# Keith's Terraform scripts for basic environments

Quick Terraform scripts to create a basic AWS environment for testing or prototyping.

# Components

## VPC 

Using `terraform-aws-modules/vpc/aws` we use this module to create our base VPC. Generally we would create 1,2 or 3 AZs and populate them with public,private and database subnets. We enable NAT gateways and DNS looksup. Internet gateways are automatically created if we create a public subnet.

## Windows and Linux instances

The script uses the latest version of MS-Windows or Amazon-Linux-2 to create EC2 instances in subnets specified (one per subnet). The instances and pre-loaded with SSM agent, and will generally have outbound internet access (courtesy of the NAT Gateway)

We assign the right IAM permissions to enable SSM Session Manager, removing the need for Bastion Hosts.

You may provide a specific security group when creating the instances, for now all instances share the same SG, which is the default SG of the VPC created. The default SG allows all outbound access (0.0.0.0/0), and all inbound access from the same SG.

## Active Directory

There are scripts to create an active directory, and auto-join specific windows instances to the domain. The script to auto-join uses the SSM run command, which means the Active Directory is a 'optional' feature.

## FSX for Windows

If the Active Directory is created, we can also created and FSX file share in the environment. Currently the auto-mount feature for the file-share has not been created.

## EFS for Linux instances

### Work in Progress ###

## Workspaces Setup

### Work in Progress ###