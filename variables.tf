variable "cluster_name" {
  type = string
}

variable "security_groups" {
}

variable "subnets" {
}

variable "datadog_api_key" {
  type      = string
  sensitive = true
}

variable "log_group" {
  type    = string
  default = "/aws/ecs/fargate/datadog"
}

variable "log_stream_prefix" {
  type    = string
  default = "datadog"
}

variable "aws_region" {
  type = string
}

variable "role_name" {
  type    = string
  default = "CustomDatadogRole"
}

variable "policy_name" {
  type    = string
  default = "CustomDatadogRolePolicy"
}

variable "retention_in_days" {
  type    = number
  default = 1
}

variable "datadog_site" {
  type    = string
  default = "datadoghq.com"
}
