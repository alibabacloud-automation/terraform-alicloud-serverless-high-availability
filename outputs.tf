output "vpc_id" {
  description = "The ID of the VPC"
  value       = alicloud_vpc.main.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = alicloud_vpc.main.cidr_block
}

output "vswitch_ids" {
  description = "The IDs of the VSwitches"
  value       = { for key, vswitch in alicloud_vswitch.vswitches : key => vswitch.id }
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = alicloud_security_group.main.id
}

output "polardb_cluster_id" {
  description = "The ID of the PolarDB cluster"
  value       = alicloud_polardb_cluster.main.id
}

output "polardb_connection_string" {
  description = "The connection string of the PolarDB cluster"
  value       = alicloud_polardb_cluster.main.connection_string
  sensitive   = true
}

output "polardb_database_name" {
  description = "The name of the PolarDB database"
  value       = alicloud_polardb_database.main.db_name
}

output "polardb_account_name" {
  description = "The name of the PolarDB account"
  value       = alicloud_polardb_account.main.account_name
}

output "alb_id" {
  description = "The ID of the Application Load Balancer"
  value       = alicloud_alb_load_balancer.main.id
}

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = alicloud_alb_load_balancer.main.dns_name
}

output "sae_namespace_id" {
  description = "The ID of the SAE namespace"
  value       = alicloud_sae_namespace.main.id
}

output "sae_application_id" {
  description = "The ID of the SAE application"
  value       = alicloud_sae_application.main.id
}

output "sae_application_name" {
  description = "The name of the SAE application"
  value       = alicloud_sae_application.main.app_name
}

output "sae_ingress_id" {
  description = "The ID of the SAE ingress"
  value       = alicloud_sae_ingress.main.id
}

output "web_url" {
  description = "The web access URL"
  value       = "http://${alicloud_alb_load_balancer.main.dns_name}"
}