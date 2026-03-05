# Create VPC
resource "alicloud_vpc" "main" {
  vpc_name   = var.vpc_config.vpc_name
  cidr_block = var.vpc_config.cidr_block
  tags       = var.common_tags
}

# Create VSwitches with for_each
resource "alicloud_vswitch" "vswitches" {
  for_each = var.vswitch_configs

  vpc_id       = alicloud_vpc.main.id
  cidr_block   = each.value.cidr_block
  zone_id      = each.value.zone_id
  vswitch_name = each.value.vswitch_name
  tags         = var.common_tags
}

# Create Security Group
resource "alicloud_security_group" "main" {
  security_group_name = var.security_group_config.security_group_name
  vpc_id              = alicloud_vpc.main.id
  description         = var.security_group_config.description
  tags                = var.common_tags
}

# Create Security Group Rules with for_each
resource "alicloud_security_group_rule" "rules" {
  for_each = var.security_group_rules

  type              = each.value.type
  ip_protocol       = each.value.ip_protocol
  port_range        = each.value.port_range
  security_group_id = alicloud_security_group.main.id
  cidr_ip           = each.value.cidr_ip
}

# Create PolarDB Cluster
resource "alicloud_polardb_cluster" "main" {
  db_type            = var.polardb_config.db_type
  db_version         = var.polardb_config.db_version
  db_node_class      = var.polardb_config.db_node_class
  pay_type           = var.polardb_config.pay_type
  vswitch_id         = alicloud_vswitch.vswitches[var.polardb_config.vswitch_key].id
  zone_id            = alicloud_vswitch.vswitches[var.polardb_config.vswitch_key].zone_id
  security_group_ids = [alicloud_security_group.main.id]

  # Serverless configuration
  serverless_type  = var.polardb_config.serverless_type
  scale_min        = var.polardb_config.scale_min
  scale_max        = var.polardb_config.scale_max
  scale_ro_num_min = var.polardb_config.scale_ro_num_min
  scale_ro_num_max = var.polardb_config.scale_ro_num_max

  description = var.polardb_config.description
  tags        = var.common_tags

  lifecycle {
    ignore_changes = [allow_shut_down]
  }
}

# Create PolarDB Database
resource "alicloud_polardb_database" "main" {
  db_cluster_id      = alicloud_polardb_cluster.main.id
  db_name            = var.polardb_database_config.db_name
  character_set_name = var.polardb_database_config.character_set_name
  db_description     = var.polardb_database_config.db_description

  lifecycle {
    ignore_changes = [account_name]
  }
}

# Create PolarDB Account
resource "alicloud_polardb_account" "main" {
  db_cluster_id    = alicloud_polardb_cluster.main.id
  account_name     = var.polardb_account_config.account_name
  account_password = var.polardb_account_config.account_password
  account_type     = var.polardb_account_config.account_type
}

# Grant database privileges to account
resource "alicloud_polardb_account_privilege" "main" {
  db_cluster_id     = alicloud_polardb_cluster.main.id
  account_name      = alicloud_polardb_account.main.account_name
  db_names          = [alicloud_polardb_database.main.db_name]
  account_privilege = var.polardb_account_privilege_config.account_privilege
}

# Create Application Load Balancer (ALB)
resource "alicloud_alb_load_balancer" "main" {
  load_balancer_name     = var.alb_config.load_balancer_name
  load_balancer_edition  = var.alb_config.load_balancer_edition
  vpc_id                 = alicloud_vpc.main.id
  address_type           = var.alb_config.address_type
  address_allocated_mode = var.alb_config.address_allocated_mode

  load_balancer_billing_config {
    pay_type = var.alb_config.pay_type
  }

  dynamic "zone_mappings" {
    for_each = var.alb_zone_mappings
    content {
      zone_id    = alicloud_vswitch.vswitches[zone_mappings.value].zone_id
      vswitch_id = alicloud_vswitch.vswitches[zone_mappings.value].id
    }
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

# Create SAE Namespace
resource "alicloud_sae_namespace" "main" {
  namespace_name = var.sae_namespace_config.namespace_name
  namespace_id   = var.sae_namespace_config.namespace_id
}

# Create SAE Application
resource "alicloud_sae_application" "main" {
  app_name        = var.sae_application_config.app_name
  app_description = var.sae_application_config.app_description
  namespace_id    = alicloud_sae_namespace.main.id

  package_type    = var.sae_application_config.package_type
  package_version = var.sae_application_config.package_version
  package_url     = var.sae_application_config.package_url

  vpc_id            = alicloud_vpc.main.id
  security_group_id = alicloud_security_group.main.id
  vswitch_id        = join(",", [for key in var.sae_application_config.vswitch_keys : alicloud_vswitch.vswitches[key].id])

  cpu      = var.sae_application_config.cpu
  memory   = var.sae_application_config.memory
  replicas = var.sae_application_config.replicas

  jdk      = var.sae_application_config.jdk
  timezone = var.sae_application_config.timezone

  jar_start_args    = var.sae_application_config.jar_start_args
  jar_start_options = var.sae_application_config.jar_start_options

  envs = jsonencode([
    {
      name  = "APPLETS_MYSQL_ENDPOINT"
      value = alicloud_polardb_cluster.main.connection_string
    },
    {
      name  = "APPLETS_MYSQL_USER"
      value = var.polardb_account_config.account_name
    },
    {
      name  = "APPLETS_MYSQL_PASSWORD"
      value = var.polardb_account_config.account_password
    },
    {
      name  = "APPLETS_MYSQL_DB_NAME"
      value = var.polardb_database_config.db_name
    },
    {
      name  = "APP_MANUAL_DEPLOY"
      value = "false"
    }
  ])

  dynamic "readiness_v2" {
    for_each = var.sae_application_config.readiness_config != null ? [var.sae_application_config.readiness_config] : []
    content {
      exec {
        command = readiness_v2.value.exec_command
      }
      initial_delay_seconds = readiness_v2.value.initial_delay_seconds
      timeout_seconds       = readiness_v2.value.timeout_seconds
    }
  }

  dynamic "liveness_v2" {
    for_each = var.sae_application_config.liveness_config != null ? [var.sae_application_config.liveness_config] : []
    content {
      http_get {
        path   = liveness_v2.value.http_get_path
        port   = liveness_v2.value.http_get_port
        scheme = liveness_v2.value.http_get_scheme
      }
      initial_delay_seconds = liveness_v2.value.initial_delay_seconds
      timeout_seconds       = liveness_v2.value.timeout_seconds
      period_seconds        = liveness_v2.value.period_seconds
    }
  }

  tags = var.common_tags

  lifecycle {
    ignore_changes = [envs]
  }
}

# Create SAE Ingress
resource "alicloud_sae_ingress" "main" {
  depends_on   = [alicloud_sae_application.main]
  namespace_id = alicloud_sae_namespace.main.id
  slb_id       = alicloud_alb_load_balancer.main.id
  description  = var.sae_ingress_config.description

  load_balance_type = var.sae_ingress_config.load_balance_type
  listener_protocol = var.sae_ingress_config.listener_protocol
  listener_port     = var.sae_ingress_config.listener_port

  dynamic "rules" {
    for_each = var.sae_ingress_rules
    content {
      app_name         = alicloud_sae_application.main.app_name
      app_id           = alicloud_sae_application.main.id
      container_port   = rules.value.container_port
      domain           = rules.value.domain
      path             = rules.value.path
      backend_protocol = rules.value.backend_protocol
    }
  }

  default_rule {
    app_id         = alicloud_sae_application.main.id
    container_port = var.sae_ingress_config.default_container_port
  }
}