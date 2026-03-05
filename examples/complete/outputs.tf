output "web_url" {
  description = "Web access URL"
  value       = module.serverless_ha.web_url
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.serverless_ha.vpc_id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = module.serverless_ha.vpc_cidr_block
}

output "vswitch_ids" {
  description = "VSwitch IDs"
  value       = module.serverless_ha.vswitch_ids
}

output "security_group_id" {
  description = "Security group ID"
  value       = module.serverless_ha.security_group_id
}

output "polardb_cluster_id" {
  description = "PolarDB cluster ID"
  value       = module.serverless_ha.polardb_cluster_id
}

output "polardb_connection_string" {
  description = "PolarDB connection string"
  value       = module.serverless_ha.polardb_connection_string
  sensitive   = true
}

output "alb_id" {
  description = "Application Load Balancer ID"
  value       = module.serverless_ha.alb_id
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = module.serverless_ha.alb_dns_name
}

output "sae_namespace_id" {
  description = "SAE namespace ID"
  value       = module.serverless_ha.sae_namespace_id
}

output "sae_application_id" {
  description = "SAE application ID"
  value       = module.serverless_ha.sae_application_id
}

output "region_id" {
  description = "Current region ID"
  value       = data.alicloud_regions.current.regions[0].id
}