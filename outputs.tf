output "cluster_id" {
  description = "RDS Cluster Identifier"
  value       = aws_rds_cluster.rds_cluster.id
}

output "cluster_arn" {
  description = "RDS Cluster ARN"
  value       = aws_rds_cluster.rds_cluster.arn
}

output "cluster_endpoint" {
  description = "Writer endpoint for the RDS cluster"
  value       = aws_rds_cluster.rds_cluster.endpoint
}

output "cluster_reader_endpoint" {
  description = "Reader endpoint for the RDS cluster"
  value       = aws_rds_cluster.rds_cluster.reader_endpoint
}

output "cluster_database_name" {
  description = "Name of the default database"
  value       = aws_rds_cluster.rds_cluster.database_name
}

output "cluster_master_username" {
  description = "Master username for the database"
  value       = aws_rds_cluster.rds_cluster.master_username
  sensitive   = false
}

output "security_group_id" {
  description = "Security Group ID for RDS cluster"
  value       = aws_security_group.rds_security_group.id
}

output "security_group_name" {
  description = "Security Group Name for RDS cluster"
  value       = aws_security_group.rds_security_group.name
}

output "writer_instance_id" {
  description = "Writer instance ID"
  value       = aws_rds_cluster_instance.writer.id
}

output "reader_instance_ids" {
  description = "Reader instance IDs"
  value       = aws_rds_cluster_instance.readers[*].id
}

output "cluster_port" {
  description = "Port on which the cluster accepts connections"
  value       = aws_rds_cluster.rds_cluster.port
}

