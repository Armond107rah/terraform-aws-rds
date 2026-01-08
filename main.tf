# Security Group for RDS
resource "aws_security_group" "rds_security_group" {
  name        = "my-rds-security-group"
  description = "Security group for RDS cluster"
  vpc_id      = var.vpc_id

  ingress {
    description = "MySQL from allowed CIDR blocks"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = length(var.allowed_cidr_blocks) > 0 ? var.allowed_cidr_blocks : ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "my-rds-security-group"
    }
  )
}

# DB Subnet Group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = var.subnet_group_name
  subnet_ids = var.subnet_ids

  tags = merge(
    var.tags,
    {
      Name = var.subnet_group_name
    }
  )
}

# RDS Cluster Parameter Group (for Serverless v2)
resource "aws_rds_cluster_parameter_group" "rds_cluster_parameter_group" {
  name        = "${var.cluster_identifier}-parameter-group"
  family      = var.engine == "aurora-postgresql" ? "aurora-postgresql15" : "aurora-mysql8.0"
  description = "Parameter group for ${var.cluster_identifier}"

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_identifier}-parameter-group"
    }
  )
}

# RDS Cluster
resource "aws_rds_cluster" "rds_cluster" {
  cluster_identifier      = var.cluster_identifier
  engine                  = var.engine
  engine_version          = var.engine_version
  database_name           = var.database_name
  master_username         = var.master_username
  master_password         = var.master_password
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window
  
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_security_group.id]
  
  serverlessv2_scaling_configuration {
    min_capacity = var.min_capacity
    max_capacity = var.max_capacity
  }

  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.rds_cluster_parameter_group.name
  
  skip_final_snapshot = true
  deletion_protection = false

  tags = merge(
    var.tags,
    {
      Name = var.cluster_identifier
    }
  )
}

# Writer Instance (Primary)
resource "aws_rds_cluster_instance" "writer" {
  identifier         = "${var.cluster_identifier}-writer"
  cluster_identifier = aws_rds_cluster.rds_cluster.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.rds_cluster.engine
  engine_version     = aws_rds_cluster.rds_cluster.engine_version

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_identifier}-writer"
    }
  )
}

# Reader Instances
resource "aws_rds_cluster_instance" "readers" {
  count              = var.reader_instance_count
  identifier         = "${var.cluster_identifier}-reader-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.rds_cluster.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.rds_cluster.engine
  engine_version     = aws_rds_cluster.rds_cluster.engine_version

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_identifier}-reader-${count.index + 1}"
    }
  )
}

