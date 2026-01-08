# Terraform AWS RDS Aurora MySQL Cluster

This Terraform module provisions an AWS RDS Aurora MySQL Serverless v2 cluster with one writer instance and two reader instances, configured with automatic scaling and backup retention.

## Features

- **Aurora MySQL Serverless v2** cluster with ACU (Aurora Capacity Units) scaling
- **1 Writer instance** (primary)
- **2 Reader instances** (for read scaling)
- **ACU Scaling**: Minimum 1 ACU, Maximum 2 ACU
- **Backup Retention**: 7 days
- **Security Group**: `my-rds-security-group` with MySQL port (3306) access
- **Subnet Group**: Custom subnet group for database isolation
- **Remote State**: Terraform state stored in S3 bucket `terraform-assignment-1`

## Prerequisites

Before you begin, ensure you have the following:

1. **AWS Account** with appropriate permissions
2. **Terraform** installed (version >= 1.0)
   ```bash
   terraform version
   ```
3. **AWS CLI** configured with credentials
   ```bash
   aws configure
   ```
4. **S3 Bucket** named `terraform-assignment-1` must exist in `us-east-1` region
   ```bash
   aws s3 mb s3://terraform-assignment-1 --region us-east-1
   ```
5. **VPC and Subnets** - You need:
   - A VPC ID where the RDS cluster will be deployed
   - At least 2 subnet IDs in different Availability Zones

## Project Structure

```
terraform-aws-rds/
├── main.tf              # Main RDS cluster resources
├── variables.tf          # Variable definitions
├── outputs.tf           # Output values
├── providers.tf         # AWS provider and backend configuration
├── terraform.tfvars.example  # Example variable values
└── README.md            # This file
```

## Configuration

### Step 1: Copy the example variables file

```bash
cp terraform.tfvars.example terraform.tfvars
```

### Step 2: Edit terraform.tfvars

Update the following required variables in `terraform.tfvars`:

```hcl
aws_region                = "us-east-1"
cluster_identifier        = "my-rds-cluster"
database_name             = "your-database-name"
master_username           = "admin"
master_password           = "your-secure-password"  # Change this!
vpc_id                    = "vpc-your-vpc-id"       # Your VPC ID
subnet_ids                = ["subnet-xxx", "subnet-yyy"]  # Your subnet IDs
subnet_group_name         = "my-armond-subig"
```

**Important Security Notes:**
- Never commit `terraform.tfvars` to version control (it's in `.gitignore`)
- Use a strong password for `master_password`
- Consider using environment variables for sensitive values:
  ```bash
  export TF_VAR_master_password="your-secure-password"
  ```

### Step 3: Verify S3 Backend Configuration

The Terraform state is configured to be stored in S3 bucket `terraform-assignment-1`. Ensure this bucket exists:

```bash
aws s3 ls s3://terraform-assignment-1
```

If it doesn't exist, create it:
```bash
aws s3 mb s3://terraform-assignment-1 --region us-east-1
```

## Usage

### Initialize Terraform

Download providers and initialize the backend:

```bash
terraform init
```

This will:
- Download the AWS provider
- Configure the S3 backend for state storage

### Plan the Deployment

Preview the changes that will be made:

```bash
terraform plan
```

Review the plan carefully to ensure it matches your expectations.

### Apply the Configuration

Deploy the RDS cluster:

```bash
terraform apply
```

Type `yes` when prompted to confirm the deployment.

**Note:** RDS cluster creation can take 10-15 minutes. Be patient!

### View Outputs

After successful deployment, view the outputs:

```bash
terraform output
```

Key outputs include:
- `cluster_endpoint` - Writer endpoint (for write operations)
- `cluster_reader_endpoint` - Reader endpoint (for read operations)
- `security_group_id` - Security group ID
- `cluster_database_name` - Database name

## Connecting to the Database

After deployment, you can connect to your RDS cluster using:

**Writer Endpoint (for writes):**
```bash
mysql -h <cluster_endpoint> -u <master_username> -p
```

**Reader Endpoint (for reads):**
```bash
mysql -h <cluster_reader_endpoint> -u <master_username> -p
```

Get the endpoints from Terraform outputs:
```bash
terraform output cluster_endpoint
terraform output cluster_reader_endpoint
```

## Pushing Code to Git

### Step 1: Initialize Git Repository (if not already initialized)

```bash
git init
```

### Step 2: Create .gitignore (if not exists)

Ensure `.gitignore` includes:
```
*.tfstate
*.tfstate.*
.terraform/
.terraform.lock.hcl
terraform.tfvars
*.tfvars.backup
.terraformrc
terraform.rc
```

### Step 3: Stage Files

```bash
git add main.tf
git add variables.tf
git add outputs.tf
git add providers.tf
git add terraform.tfvars.example
git add README.md
git add .gitignore
```

Or add all tracked files:
```bash
git add .
```

### Step 4: Commit Changes

```bash
git commit -m "Initial commit: Terraform RDS Aurora MySQL cluster configuration"
```

### Step 5: Add Remote Repository

```bash
git remote add origin <your-repository-url>
```

For example:
```bash
git remote add origin https://github.com/yourusername/terraform-aws-rds.git
```

### Step 6: Push to Remote

```bash
git branch -M main
git push -u origin main
```

Or if using a different branch:
```bash
git push -u origin <branch-name>
```

## Updating the Configuration

1. Make changes to `.tf` files or `terraform.tfvars`
2. Review changes:
   ```bash
   terraform plan
   ```
3. Apply changes:
   ```bash
   terraform apply
   ```
4. Commit and push:
   ```bash
   git add .
   git commit -m "Update: description of changes"
   git push
   ```

## Destroying Resources

To tear down all resources:

```bash
terraform destroy
```

**Warning:** This will delete the RDS cluster and all associated resources. Make sure you have backups if needed!

## Variables Reference

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `aws_region` | AWS region | `us-east-1` | No |
| `cluster_identifier` | RDS cluster identifier | `my-rds-cluster` | No |
| `database_name` | Default database name | `mydb` | No |
| `master_username` | Master username | `admin` | No |
| `master_password` | Master password | - | **Yes** |
| `engine` | Database engine | `aurora-mysql` | No |
| `engine_version` | Engine version | `8.0.mysql_aurora.3.04.0` | No |
| `backup_retention_period` | Backup retention (days) | `7` | No |
| `min_capacity` | Minimum ACU | `1` | No |
| `max_capacity` | Maximum ACU | `2` | No |
| `reader_instance_count` | Number of reader instances | `2` | No |
| `vpc_id` | VPC ID | - | **Yes** |
| `subnet_ids` | List of subnet IDs | - | **Yes** |
| `subnet_group_name` | Subnet group name | - | **Yes** |
| `allowed_cidr_blocks` | Allowed CIDR blocks | `[]` | No |
| `tags` | Resource tags | `{}` | No |

## Outputs Reference

| Output | Description |
|--------|-------------|
| `cluster_id` | RDS Cluster Identifier |
| `cluster_arn` | RDS Cluster ARN |
| `cluster_endpoint` | Writer endpoint |
| `cluster_reader_endpoint` | Reader endpoint |
| `cluster_database_name` | Database name |
| `cluster_master_username` | Master username |
| `security_group_id` | Security Group ID |
| `security_group_name` | Security Group Name |
| `writer_instance_id` | Writer instance ID |
| `reader_instance_ids` | Reader instance IDs |
| `cluster_port` | Database port |

## Troubleshooting

### Error: S3 bucket does not exist
**Solution:** Create the S3 bucket first:
```bash
aws s3 mb s3://terraform-assignment-1 --region us-east-1
```

### Error: Invalid credentials
**Solution:** Configure AWS credentials:
```bash
aws configure
```

### Error: Subnets not in different AZs
**Solution:** Ensure your subnets are in different Availability Zones.

### Error: Insufficient permissions
**Solution:** Ensure your AWS credentials have permissions for:
- RDS (create, modify, delete clusters and instances)
- EC2 (create security groups, subnet groups)
- S3 (read/write state file)

## Security Best Practices

1. **Never commit sensitive data** - Keep `terraform.tfvars` out of version control
2. **Use strong passwords** - Generate secure passwords for database credentials
3. **Restrict CIDR blocks** - Update `allowed_cidr_blocks` to restrict access
4. **Enable encryption** - Consider adding encryption at rest (requires additional configuration)
5. **Use IAM roles** - Use IAM roles instead of access keys when possible
6. **Enable MFA** - Enable Multi-Factor Authentication for AWS account

## Additional Resources

- [AWS RDS Aurora Documentation](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Aurora Serverless v2 Documentation](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.html)

## License

This project is provided as-is for educational and development purposes.

## Support

For issues or questions, please open an issue in the repository or contact the maintainer.

