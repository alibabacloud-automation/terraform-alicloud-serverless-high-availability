# Complete Example

This example demonstrates how to use the serverless-high-availability module to deploy a complete serverless high availability architecture on Alibaba Cloud.

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

To run this example, you need to execute:

```bash
terraform init
terraform plan
terraform apply
```

Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources.


## Notes

- The database password must be 8-30 characters long and contain at least three of: uppercase letters, lowercase letters, numbers, special symbols
- The application deployment takes approximately 3 minutes to complete
- The example uses serverless PolarDB with auto-scaling from 1-16 PCUs
- Health checks are configured for both readiness and liveness probes

## Destroy

To destroy the infrastructure when you're done:

```bash
terraform destroy
```