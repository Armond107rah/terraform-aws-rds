variable "aws_region" {
  description = "AWS region for RDS cluster"
  type        = string
  default     = "us-east-1"
}

variable "cluster_identifier" {
  description = "Identifier for the RDS cluster"
  type        = string
  default     = "my-rds-cluster"
}

variable "database_name" {
  description = "Name of the default database"
  type        = string
  default     = "mydb"
}

variable "master_username" {
  description = "Master username for the database"
  type        = string
  default     = "admin"
}

variable "master_password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
}

variable "engine" {
  description = "Database engine (aurora-postgresql or aurora-mysql)"
  type        = string
  default     = "aurora-mysql"
}

variable "engine_version" {
  description = "Engine version"
  type        = string
  default     = "8.0.mysql_aurora.3.04.0"
}

variable "backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "Preferred backup window"
  type        = string
  default     = "03:00-04:00"
}

variable "preferred_maintenance_window" {
  description = "Preferred maintenance window"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "min_capacity" {
  description = "Minimum ACU (Aurora Capacity Units)"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum ACU (Aurora Capacity Units)"
  type        = number
  default     = 2
}

variable "reader_instance_count" {
  description = "Number of reader instances"
  type        = number
  default     = 2
}

variable "vpc_id" {
  description = "VPC ID where RDS will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "subnet_group_name" {
  description = "Name for the DB subnet group"
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the RDS cluster"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

