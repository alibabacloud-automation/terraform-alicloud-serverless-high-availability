阿里云 Serverless 高可用架构 Terraform 模块

# terraform-alicloud-serverless-high-availability

[English](https://github.com/alibabacloud-automation/terraform-alicloud-serverless-high-availability/blob/main/README.md) | 简体中文

这个 Terraform 模块在阿里云上创建完整的 Serverless 高可用架构。该模块实现了[极简运维，Serverless 高可用架构](https://www.aliyun.com/solution/tech-solution/serverless-ha)解决方案，提供高效且可扩展的 Serverless 基础设施，具备自动扩缩容能力、多可用区高可用性和全面监控。

该架构包括专有网络（VPC）、交换机（VSwitch）、PolarDB MySQL Serverless 集群、应用型负载均衡（ALB）、Serverless 应用引擎（SAE）应用程序，以及相关的网络和安全配置，为您提供生产就绪的 Serverless 平台。

## 使用方法

此模块可用于快速部署 Serverless 高可用架构。以下示例展示了如何使用最少的配置部署完整的基础设施：

```terraform
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

module "serverless_ha" {
  source = "alibabacloud-automation/serverless-high-availability/alicloud"

  vpc_config = {
    cidr_block = "192.168.0.0/16"
  }

  vswitch_configs = {
    web_01 = {
      cidr_block   = "192.168.1.0/24"
      zone_id      = data.alicloud_zones.default.zones[0].id
      vswitch_name = "web-01"
    }
    web_02 = {
      cidr_block   = "192.168.2.0/24"
      zone_id      = data.alicloud_zones.default.zones[1].id
      vswitch_name = "web-02"
    }
    db_01 = {
      cidr_block   = "192.168.3.0/24"
      zone_id      = data.alicloud_zones.default.zones[0].id
      vswitch_name = "db-01"
    }
  }

  polardb_config = {
    db_node_class = data.alicloud_polardb_node_classes.default.classes[0].supported_engines[0].available_resources[0].db_node_class
    vswitch_key   = "db_01"
  }

  polardb_account_config = {
    account_name     = "appuser"
    account_password = "MySecurePassword123!"
  }

  sae_namespace_config = {
    namespace_id = "${data.alicloud_regions.current.regions[0].id}:serverless${substr(md5(data.alicloud_regions.current.regions[0].id), 0, 5)}"
  }

  sae_application_config = {
    app_name     = "my-app"
    vswitch_keys = ["web_01", "web_02"]
  }

  alb_zone_mappings = ["web_01", "web_02"]
}
```

## 示例

* [完整示例](https://github.com/alibabacloud-automation/terraform-alicloud-serverless-high-availability/tree/main/examples/complete)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_alicloud"></a> [alicloud](#requirement\_alicloud) | >= 1.132.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.7 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_alicloud"></a> [alicloud](#provider\_alicloud) | >= 1.132.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [alicloud_alb_load_balancer.main](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/alb_load_balancer) | resource |
| [alicloud_polardb_account.main](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/polardb_account) | resource |
| [alicloud_polardb_account_privilege.main](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/polardb_account_privilege) | resource |
| [alicloud_polardb_cluster.main](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/polardb_cluster) | resource |
| [alicloud_polardb_database.main](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/polardb_database) | resource |
| [alicloud_sae_application.main](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/sae_application) | resource |
| [alicloud_sae_ingress.main](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/sae_ingress) | resource |
| [alicloud_sae_namespace.main](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/sae_namespace) | resource |
| [alicloud_security_group.main](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/security_group) | resource |
| [alicloud_security_group_rule.rules](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/security_group_rule) | resource |
| [alicloud_vpc.main](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vpc) | resource |
| [alicloud_vswitch.vswitches](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vswitch) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_config"></a> [alb\_config](#input\_alb\_config) | Application Load Balancer configuration. | <pre>object({<br/>    load_balancer_name     = optional(string, "serverless-alb")<br/>    load_balancer_edition  = optional(string, "Basic")<br/>    address_type           = optional(string, "Internet")<br/>    address_allocated_mode = optional(string, "Fixed")<br/>    pay_type               = optional(string, "PayAsYouGo")<br/>  })</pre> | `{}` | no |
| <a name="input_alb_zone_mappings"></a> [alb\_zone\_mappings](#input\_alb\_zone\_mappings) | ALB zone mappings configuration. List of vswitch keys for zone mappings. | `list(string)` | n/a | yes |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Common tags to be applied to all resources | `map(string)` | `{}` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., dev, staging, prod) | `string` | `"dev"` | no |
| <a name="input_polardb_account_config"></a> [polardb\_account\_config](#input\_polardb\_account\_config) | PolarDB account configuration. The attributes 'account\_name' and 'account\_password' are required. | <pre>object({<br/>    account_name     = string<br/>    account_password = string<br/>    account_type     = optional(string, "Normal")<br/>  })</pre> | n/a | yes |
| <a name="input_polardb_account_privilege_config"></a> [polardb\_account\_privilege\_config](#input\_polardb\_account\_privilege\_config) | PolarDB account privilege configuration. | <pre>object({<br/>    account_privilege = optional(string, "ReadWrite")<br/>  })</pre> | `{}` | no |
| <a name="input_polardb_config"></a> [polardb\_config](#input\_polardb\_config) | PolarDB cluster configuration. The attributes 'db\_node\_class' and 'vswitch\_key' are required. | <pre>object({<br/>    db_type          = optional(string, "MySQL")<br/>    db_version       = optional(string, "8.0")<br/>    db_node_class    = string<br/>    pay_type         = optional(string, "PostPaid")<br/>    vswitch_key      = string<br/>    serverless_type  = optional(string, "AgileServerless")<br/>    scale_min        = optional(number, 1)<br/>    scale_max        = optional(number, 16)<br/>    scale_ro_num_min = optional(number, 1)<br/>    scale_ro_num_max = optional(number, 4)<br/>    description      = optional(string, "Serverless high availability architecture PolarDB cluster")<br/>  })</pre> | n/a | yes |
| <a name="input_polardb_database_config"></a> [polardb\_database\_config](#input\_polardb\_database\_config) | PolarDB database configuration. | <pre>object({<br/>    db_name            = optional(string, "applets")<br/>    character_set_name = optional(string, "utf8mb4")<br/>    db_description     = optional(string, "serverless demo")<br/>  })</pre> | `{}` | no |
| <a name="input_sae_application_config"></a> [sae\_application\_config](#input\_sae\_application\_config) | SAE application configuration. The attributes 'app\_name' and 'vswitch\_keys' are required. | <pre>object({<br/>    app_name          = string<br/>    app_description   = optional(string, "serverless-demo")<br/>    package_type      = optional(string, "FatJar")<br/>    package_version   = optional(string, "1718956564756")<br/>    package_url       = optional(string, "https://help-static-aliyun-doc.aliyuncs.com/tech-solution/sae-demo-0.0.3.jar")<br/>    cpu               = optional(number, 2000)<br/>    memory            = optional(number, 4096)<br/>    replicas          = optional(number, 2)<br/>    jdk               = optional(string, "Open JDK 8")<br/>    timezone          = optional(string, "Asia/Shanghai")<br/>    jar_start_args    = optional(string, "$JAVA_HOME/bin/java $Options -jar $CATALINA_OPTS \"$package_path\" $args")<br/>    jar_start_options = optional(string, "-XX:+UseContainerSupport -XX:InitialRAMPercentage=70.0 -XX:MaxRAMPercentage=70.0 -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:/home/admin/nas/gc-$${POD_IP}-$(date '+%s').log -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/home/admin/nas/dump-$${POD_IP}-$(date '+%s').hprof")<br/>    vswitch_keys      = list(string)<br/>    readiness_config = optional(object({<br/>      exec_command          = list(string)<br/>      initial_delay_seconds = number<br/>      timeout_seconds       = number<br/>    }), null)<br/>    liveness_config = optional(object({<br/>      http_get_path         = string<br/>      http_get_port         = number<br/>      http_get_scheme       = string<br/>      initial_delay_seconds = number<br/>      timeout_seconds       = number<br/>      period_seconds        = number<br/>    }), null)<br/>  })</pre> | n/a | yes |
| <a name="input_sae_ingress_config"></a> [sae\_ingress\_config](#input\_sae\_ingress\_config) | SAE ingress configuration. | <pre>object({<br/>    description            = optional(string, "serverless-demo-router")<br/>    load_balance_type      = optional(string, "alb")<br/>    listener_protocol      = optional(string, "HTTP")<br/>    listener_port          = optional(number, 80)<br/>    default_container_port = optional(number, 80)<br/>  })</pre> | `{}` | no |
| <a name="input_sae_ingress_rules"></a> [sae\_ingress\_rules](#input\_sae\_ingress\_rules) | SAE ingress rules configuration. Each rule requires 'container\_port', 'domain' and 'path'. | <pre>list(object({<br/>    container_port   = number<br/>    domain           = string<br/>    path             = string<br/>    backend_protocol = optional(string, "http")<br/>  }))</pre> | `[]` | no |
| <a name="input_sae_namespace_config"></a> [sae\_namespace\_config](#input\_sae\_namespace\_config) | SAE namespace configuration. The attribute 'namespace\_id' is required. | <pre>object({<br/>    namespace_name = optional(string, "serverless-demo")<br/>    namespace_id   = string<br/>  })</pre> | n/a | yes |
| <a name="input_security_group_config"></a> [security\_group\_config](#input\_security\_group\_config) | Security group configuration. | <pre>object({<br/>    security_group_name = optional(string, "serverless-sg")<br/>    description         = optional(string, "Security group for serverless high availability architecture")<br/>  })</pre> | `{}` | no |
| <a name="input_security_group_rules"></a> [security\_group\_rules](#input\_security\_group\_rules) | Security group rules configuration. Each rule requires 'type', 'ip\_protocol', 'port\_range' and 'cidr\_ip'. | <pre>map(object({<br/>    type        = string<br/>    ip_protocol = string<br/>    port_range  = string<br/>    cidr_ip     = string<br/>  }))</pre> | `{}` | no |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | VPC configuration. The attribute 'cidr\_block' is required. | <pre>object({<br/>    vpc_name   = optional(string, "serverless-vpc")<br/>    cidr_block = string<br/>  })</pre> | n/a | yes |
| <a name="input_vswitch_configs"></a> [vswitch\_configs](#input\_vswitch\_configs) | VSwitch configurations. Each VSwitch requires 'cidr\_block' and 'zone\_id'. | <pre>map(object({<br/>    cidr_block   = string<br/>    zone_id      = string<br/>    vswitch_name = optional(string, "default-vswitch")<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | The DNS name of the Application Load Balancer |
| <a name="output_alb_id"></a> [alb\_id](#output\_alb\_id) | The ID of the Application Load Balancer |
| <a name="output_polardb_account_name"></a> [polardb\_account\_name](#output\_polardb\_account\_name) | The name of the PolarDB account |
| <a name="output_polardb_cluster_id"></a> [polardb\_cluster\_id](#output\_polardb\_cluster\_id) | The ID of the PolarDB cluster |
| <a name="output_polardb_connection_string"></a> [polardb\_connection\_string](#output\_polardb\_connection\_string) | The connection string of the PolarDB cluster |
| <a name="output_polardb_database_name"></a> [polardb\_database\_name](#output\_polardb\_database\_name) | The name of the PolarDB database |
| <a name="output_sae_application_id"></a> [sae\_application\_id](#output\_sae\_application\_id) | The ID of the SAE application |
| <a name="output_sae_application_name"></a> [sae\_application\_name](#output\_sae\_application\_name) | The name of the SAE application |
| <a name="output_sae_ingress_id"></a> [sae\_ingress\_id](#output\_sae\_ingress\_id) | The ID of the SAE ingress |
| <a name="output_sae_namespace_id"></a> [sae\_namespace\_id](#output\_sae\_namespace\_id) | The ID of the SAE namespace |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the security group |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | The CIDR block of the VPC |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
| <a name="output_vswitch_ids"></a> [vswitch\_ids](#output\_vswitch\_ids) | The IDs of the VSwitches |
| <a name="output_web_url"></a> [web\_url](#output\_web\_url) | The web access URL |
<!-- END_TF_DOCS -->

## 提交问题

如果您在使用此模块时遇到任何问题，请提交一个 [provider issue](https://github.com/aliyun/terraform-provider-alicloud/issues/new) 并告知我们。

**注意：** 不建议在此仓库中提交问题。

## 作者

由阿里云 Terraform 团队创建和维护(terraform@alibabacloud.com)。

## 许可证

MIT 许可。有关完整详细信息，请参阅 LICENSE。

## 参考

* [Terraform-Provider-Alicloud Github](https://github.com/aliyun/terraform-provider-alicloud)
* [Terraform-Provider-Alicloud Release](https://releases.hashicorp.com/terraform-provider-alicloud/)
* [Terraform-Provider-Alicloud Docs](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs)