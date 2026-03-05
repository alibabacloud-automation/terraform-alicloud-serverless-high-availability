variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, staging, prod)"
  default     = "dev"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to be applied to all resources"
  default     = {}
}

variable "vpc_config" {
  type = object({
    vpc_name   = optional(string, "serverless-vpc")
    cidr_block = string
  })
  description = "VPC configuration. The attribute 'cidr_block' is required."
}

variable "vswitch_configs" {
  type = map(object({
    cidr_block   = string
    zone_id      = string
    vswitch_name = optional(string, "default-vswitch")
  }))
  description = "VSwitch configurations. Each VSwitch requires 'cidr_block' and 'zone_id'."
}

variable "security_group_config" {
  type = object({
    security_group_name = optional(string, "serverless-sg")
    description         = optional(string, "Security group for serverless high availability architecture")
  })
  description = "Security group configuration."
  default     = {}
}

variable "security_group_rules" {
  type = map(object({
    type        = string
    ip_protocol = string
    port_range  = string
    cidr_ip     = string
  }))
  description = "Security group rules configuration. Each rule requires 'type', 'ip_protocol', 'port_range' and 'cidr_ip'."
  default     = {}
}

variable "polardb_config" {
  type = object({
    db_type          = optional(string, "MySQL")
    db_version       = optional(string, "8.0")
    db_node_class    = string
    pay_type         = optional(string, "PostPaid")
    vswitch_key      = string
    serverless_type  = optional(string, "AgileServerless")
    scale_min        = optional(number, 1)
    scale_max        = optional(number, 16)
    scale_ro_num_min = optional(number, 1)
    scale_ro_num_max = optional(number, 4)
    description      = optional(string, "Serverless high availability architecture PolarDB cluster")
  })
  description = "PolarDB cluster configuration. The attributes 'db_node_class' and 'vswitch_key' are required."
}

variable "polardb_database_config" {
  type = object({
    db_name            = optional(string, "applets")
    character_set_name = optional(string, "utf8mb4")
    db_description     = optional(string, "serverless demo")
  })
  description = "PolarDB database configuration."
  default     = {}
}

variable "polardb_account_config" {
  type = object({
    account_name     = string
    account_password = string
    account_type     = optional(string, "Normal")
  })
  description = "PolarDB account configuration. The attributes 'account_name' and 'account_password' are required."
  sensitive   = true
}

variable "polardb_account_privilege_config" {
  type = object({
    account_privilege = optional(string, "ReadWrite")
  })
  description = "PolarDB account privilege configuration."
  default     = {}
}

variable "alb_config" {
  type = object({
    load_balancer_name     = optional(string, "serverless-alb")
    load_balancer_edition  = optional(string, "Basic")
    address_type           = optional(string, "Internet")
    address_allocated_mode = optional(string, "Fixed")
    pay_type               = optional(string, "PayAsYouGo")
  })
  description = "Application Load Balancer configuration."
  default     = {}
}

variable "alb_zone_mappings" {
  type        = list(string)
  description = "ALB zone mappings configuration. List of vswitch keys for zone mappings."
}

variable "sae_namespace_config" {
  type = object({
    namespace_name = optional(string, "serverless-demo")
    namespace_id   = string
  })
  description = "SAE namespace configuration. The attribute 'namespace_id' is required."
}

variable "sae_application_config" {
  type = object({
    app_name          = string
    app_description   = optional(string, "serverless-demo")
    package_type      = optional(string, "FatJar")
    package_version   = optional(string, "1718956564756")
    package_url       = optional(string, "https://help-static-aliyun-doc.aliyuncs.com/tech-solution/sae-demo-0.0.3.jar")
    cpu               = optional(number, 2000)
    memory            = optional(number, 4096)
    replicas          = optional(number, 2)
    jdk               = optional(string, "Open JDK 8")
    timezone          = optional(string, "Asia/Shanghai")
    jar_start_args    = optional(string, "$JAVA_HOME/bin/java $Options -jar $CATALINA_OPTS \"$package_path\" $args")
    jar_start_options = optional(string, "-XX:+UseContainerSupport -XX:InitialRAMPercentage=70.0 -XX:MaxRAMPercentage=70.0 -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:/home/admin/nas/gc-$${POD_IP}-$(date '+%s').log -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/home/admin/nas/dump-$${POD_IP}-$(date '+%s').hprof")
    vswitch_keys      = list(string)
    readiness_config = optional(object({
      exec_command          = list(string)
      initial_delay_seconds = number
      timeout_seconds       = number
    }), null)
    liveness_config = optional(object({
      http_get_path         = string
      http_get_port         = number
      http_get_scheme       = string
      initial_delay_seconds = number
      timeout_seconds       = number
      period_seconds        = number
    }), null)
  })
  description = "SAE application configuration. The attributes 'app_name' and 'vswitch_keys' are required."
}


variable "sae_ingress_config" {
  type = object({
    description            = optional(string, "serverless-demo-router")
    load_balance_type      = optional(string, "alb")
    listener_protocol      = optional(string, "HTTP")
    listener_port          = optional(number, 80)
    default_container_port = optional(number, 80)
  })
  description = "SAE ingress configuration."
  default     = {}
}

variable "sae_ingress_rules" {
  type = list(object({
    container_port   = number
    domain           = string
    path             = string
    backend_protocol = optional(string, "http")
  }))
  description = "SAE ingress rules configuration. Each rule requires 'container_port', 'domain' and 'path'."
  default     = []
}