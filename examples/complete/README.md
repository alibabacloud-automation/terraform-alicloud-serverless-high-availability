# Complete Example

This example demonstrates how to use the serverless-ha module to deploy a complete serverless high availability architecture on Alibaba Cloud.

## Architecture

This example creates:

- **VPC**: A Virtual Private Cloud with CIDR 192.168.0.0/16
- **VSwitches**: 5 VSwitches across 2 availability zones
  - web_01/web_02: For web tier (zones 1&2)
  - db_01: For database tier (zone 1)
  - pub_01/pub_02: For public tier (zones 1&2)
- **Security Group**: With rules for HTTP, HTTPS, and MySQL access
- **PolarDB**: MySQL 8.0 serverless cluster with auto-scaling
- **ALB**: Application Load Balancer for traffic distribution
- **SAE**: Serverless App Engine application with health checks
- **SAE Ingress**: Routing rules for external access

## Usage

1. Set the required variables:

```bash
export TF_VAR_db_password="YourSecurePassword123!"
```

2. Initialize and apply:

```bash
terraform init
terraform plan
terraform apply
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| common_name | Common name prefix for all resources | string | "serverless" | no |
| environment | Environment name | string | "dev" | no |
| db_user_name | MySQL database account name | string | "applets" | no |
| db_password | MySQL database password | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| web_url | Web access URL |
| vpc_id | VPC ID |
| polardb_cluster_id | PolarDB cluster ID |
| alb_dns_name | ALB DNS name |
| sae_application_id | SAE application ID |

## Notes

- The database password must be 8-30 characters long and contain at least three of: uppercase letters, lowercase letters, numbers, special symbols
- The application deployment takes approximately 3 minutes to complete
- The example uses serverless PolarDB with auto-scaling from 1-16 PCUs
- Health checks are configured for both readiness and liveness probes

## Clean Up

```bash
terraform destroy
```