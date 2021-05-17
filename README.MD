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

To automatically connect to a domain controller, run the `connect_to_AD` module.

## FSX for Windows

If the Active Directory is created, we can also created and FSX file share in the environment. Currently the auto-mount feature for the file-share has not been created.

## EFS for Linux instances

### Work in Progress ###

## Workspaces Setup

### Work in Progress ###

## DNS Records ##

This module creates a Sub-domain hosted zone in Route53, while referencing the root domain in Cloudflare. It also creates a certificate, and validates that certificate automatically with Terraform.

The root domain (e.g. example.com) is in cloudflare, and the cloudflare token must be provided as a variable to `main.tf`.

The sub domain (e.g. sub.example.com) will be hosted on Route53, with the right NS records created in cloudflare to point to it.

The vpn domain (e.g. vpn.sub.example.com) will be created, and a certificate will be issued and validated for this domain. You can then use the certificate from this domain to point to something. Note the vpn domain has no corresponding record in Route53, this is left to the module actually implementing something in AWS.

Note: due to some complication you'd need to apply the dns zone first, before applying the entire module.

    $ tf apply module.dns_record.aws_route_53_zone.this
    $ tf apply module.dns_record
    $ tf apply

## Client VPN

Creates a Client-2-Site VPN to connect into the VPC.

You will need to run `gen_certs.sh` prior to applying the module, this will generate the necessary client and server certificates. The module will then upload these to ACM.

`security_group_ids` is a list of security group ids, that will be modified to allow ingress traffic from the VPC endpoint. The subnets provided to the module must be public subnets with internet access.

Once the client vpn endpoint is created, follow instructions here to modify the oVPN file to allow connectivity from your client: https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/cvpn-getting-started.html#cvpn-getting-started-certs. This process is very manual.

Authentication used is active-directory based, and hence you will need to enable the active directory module in order to use this.