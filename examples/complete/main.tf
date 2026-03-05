# Data sources to query available zones, node classes, and current region
data "alicloud_regions" "current" {
  current = true
}

data "alicloud_zones" "default" {
  available_resource_creation = "VSwitch"
}

data "alicloud_polardb_node_classes" "default" {
  db_type       = "MySQL"
  db_version    = "8.0"
  category      = "Normal"
  pay_type      = "PostPaid"
  db_node_class = "polar.mysql.sl.small"
}

locals {
  zone_id_1 = data.alicloud_polardb_node_classes.default.classes[0].zone_id
  zone_id_2 = data.alicloud_zones.default.zones[0].id
}

# Call the serverless-high-availability module
module "serverless_ha" {
  source = "../../"

  environment = var.environment

  vpc_config = {
    vpc_name   = "${var.common_name}-vpc"
    cidr_block = "192.168.0.0/16"
  }

  vswitch_configs = {
    web_01 = {
      cidr_block   = "192.168.1.0/24"
      zone_id      = local.zone_id_1
      vswitch_name = "${var.common_name}-web-01"
    }
    web_02 = {
      cidr_block   = "192.168.2.0/24"
      zone_id      = local.zone_id_2
      vswitch_name = "${var.common_name}-web-02"
    }
    db_01 = {
      cidr_block   = "192.168.3.0/24"
      zone_id      = local.zone_id_1
      vswitch_name = "${var.common_name}-db-01"
    }
    pub_01 = {
      cidr_block   = "192.168.4.0/24"
      zone_id      = local.zone_id_1
      vswitch_name = "${var.common_name}-pub-01"
    }
    pub_02 = {
      cidr_block   = "192.168.5.0/24"
      zone_id      = local.zone_id_2
      vswitch_name = "${var.common_name}-pub-02"
    }
  }

  security_group_config = {
    security_group_name = "${var.common_name}-sg"
    description         = "Security group for serverless high availability architecture"
  }

  security_group_rules = {
    allow_https = {
      type        = "ingress"
      ip_protocol = "tcp"
      port_range  = "443/443"
      cidr_ip     = "0.0.0.0/0"
    }
    allow_http = {
      type        = "ingress"
      ip_protocol = "tcp"
      port_range  = "80/80"
      cidr_ip     = "0.0.0.0/0"
    }
    allow_mysql = {
      type        = "ingress"
      ip_protocol = "tcp"
      port_range  = "3306/3306"
      cidr_ip     = "0.0.0.0/0"
    }
  }

  polardb_config = {
    db_type          = "MySQL"
    db_version       = "8.0"
    db_node_class    = data.alicloud_polardb_node_classes.default.classes[0].supported_engines[0].available_resources[0].db_node_class
    pay_type         = "PostPaid"
    vswitch_key      = "db_01"
    serverless_type  = "AgileServerless"
    scale_min        = 1
    scale_max        = 16
    scale_ro_num_min = 1
    scale_ro_num_max = 4
    description      = "Serverless high availability architecture PolarDB cluster"
  }

  polardb_database_config = {
    db_name            = "applets"
    character_set_name = "utf8mb4"
    db_description     = "serverless demo"
  }

  polardb_account_config = {
    account_name     = var.db_user_name
    account_password = var.db_password
    account_type     = "Normal"
  }

  polardb_account_privilege_config = {
    account_privilege = "ReadWrite"
  }

  alb_config = {
    load_balancer_name     = "${var.common_name}-alb"
    load_balancer_edition  = "Basic"
    address_type           = "Internet"
    address_allocated_mode = "Fixed"
    pay_type               = "PayAsYouGo"
  }

  alb_zone_mappings = ["web_01", "web_02"]

  sae_namespace_config = {
    namespace_name = "serverless-demo"
    namespace_id   = "${data.alicloud_regions.current.regions[0].id}:serverless${substr(md5(data.alicloud_regions.current.regions[0].id), 0, 5)}"
  }

  sae_application_config = {
    app_name          = "${var.common_name}-demo"
    app_description   = "serverless-demo"
    package_type      = "FatJar"
    package_version   = "1718956564756"
    package_url       = "https://help-static-aliyun-doc.aliyuncs.com/tech-solution/sae-demo-0.0.3.jar"
    cpu               = 2000
    memory            = 4096
    replicas          = 2
    jdk               = "Open JDK 8"
    timezone          = "Asia/Shanghai"
    jar_start_args    = "$JAVA_HOME/bin/java $Options -jar $CATALINA_OPTS \"$package_path\" $args"
    jar_start_options = "-XX:+UseContainerSupport -XX:InitialRAMPercentage=70.0 -XX:MaxRAMPercentage=70.0 -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:/home/admin/nas/gc-$${POD_IP}-$(date '+%s').log -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/home/admin/nas/dump-$${POD_IP}-$(date '+%s').hprof"
    vswitch_keys      = ["pub_01", "pub_02"]
    readiness_config = {
      exec_command          = ["sleep", "6s"]
      initial_delay_seconds = 15
      timeout_seconds       = 12
    }
    liveness_config = {
      http_get_path         = "/"
      http_get_port         = 80
      http_get_scheme       = "HTTP"
      initial_delay_seconds = 10
      timeout_seconds       = 10
      period_seconds        = 10
    }
  }

  sae_ingress_config = {
    description            = "serverless-demo-router"
    load_balance_type      = "alb"
    listener_protocol      = "HTTP"
    listener_port          = 80
    default_container_port = 80
  }

  sae_ingress_rules = [
    {
      container_port   = 80
      domain           = "example.com"
      path             = "/"
      backend_protocol = "http"
    }
  ]

  common_tags = {
    Project = "serverless-high-availability"
    Owner   = "terraform"
  }
}