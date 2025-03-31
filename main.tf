provider "aws" {
  region = var.aws_region
}

# S3 bucket for application versions
resource "aws_s3_bucket" "app_version_bucket" {
  bucket = var.app_version_bucket_name
}

# Create S3 bucket for the website content
resource "aws_s3_bucket" "website_bucket" {
  bucket = var.website_bucket_name
}

# Enable website hosting on the S3 bucket
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# Make S3 bucket public
resource "aws_s3_bucket_public_access_block" "website_public" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# S3 bucket policy to allow public read access
resource "aws_s3_bucket_policy" "website_policy" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website_bucket.arn}/*"
      },
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.website_public]
}

# Upload website files to S3
resource "aws_s3_object" "website_files" {
  for_each = fileset("${path.module}/S3Website", "**/*")
  
  bucket = aws_s3_bucket.website_bucket.id
  key    = each.value
  source = "${path.module}/S3Website/${each.value}"
  etag   = filemd5("${path.module}/S3Website/${each.value}")
  content_type = lookup(local.mime_types, regex("\\.[^.]+$", each.value), null)
}

locals {
  mime_types = {
    ".html" = "text/html"
    ".css"  = "text/css"
    ".js"   = "application/javascript"
    ".json" = "application/json"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".jpeg" = "image/jpeg"
    ".ico"  = "image/x-icon"
  }
  
  # Create a zip of the S3Website directory for Elastic Beanstalk
  app_zip_path = "${path.module}/application.zip"
}

# The script to create the application zip
resource "null_resource" "create_app_zip" {
  triggers = {
    # Trigger on any change to the S3Website files
    website_files = sha256(join("", [for f in fileset("${path.module}/S3Website", "**/*") : filesha256("${path.module}/S3Website/${f}")]))
  }

  provisioner "local-exec" {
    command = "cd ${path.module} && mkdir -p tmp-package && cp -r S3Website/* tmp-package/ && cd tmp-package && zip -r ../${basename(local.app_zip_path)} * && cd .. && rm -rf tmp-package"
  }
}

# Upload application zip to S3
resource "aws_s3_object" "app_version" {
  bucket = aws_s3_bucket.app_version_bucket.id
  key    = "${var.app_name}-${var.app_version}.zip"
  source = local.app_zip_path
  etag   = fileexists(local.app_zip_path) ? filemd5(local.app_zip_path) : md5(timestamp())
  depends_on = [null_resource.create_app_zip]
}

# Elastic Beanstalk application
resource "aws_elastic_beanstalk_application" "eb_app" {
  name        = var.app_name
  description = "${var.app_name} application"
}

# Elastic Beanstalk version
resource "aws_elastic_beanstalk_application_version" "eb_app_version" {
  name        = "${var.app_name}-${var.app_version}"
  application = aws_elastic_beanstalk_application.eb_app.name
  description = "Version ${var.app_version} of ${var.app_name}"
  bucket      = aws_s3_bucket.app_version_bucket.id
  key         = aws_s3_object.app_version.id
  depends_on  = [aws_s3_object.app_version]
}

# Security group for EFS
resource "aws_security_group" "efs_sg" {
  name        = "${var.app_name}-efs-sg"
  description = "Allow NFS traffic from EC2 instances"
  vpc_id      = var.vpc_id

  ingress {
    description = "NFS from EC2"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EFS file system
resource "aws_efs_file_system" "eb_efs" {
  creation_token = "${var.app_name}-efs"
  
  tags = {
    Name = "${var.app_name}-efs"
  }
}

# Mount targets in each subnet
resource "aws_efs_mount_target" "eb_efs_mount" {
  count           = length(var.efs_subnet_ids)
  file_system_id  = aws_efs_file_system.eb_efs.id
  subnet_id       = var.efs_subnet_ids[count.index]
  security_groups = [aws_security_group.efs_sg.id]
}

# Elastic Beanstalk environment
resource "aws_elastic_beanstalk_environment" "eb_env" {
  name                = "${var.app_name}-env"
  application         = aws_elastic_beanstalk_application.eb_app.name
  solution_stack_name = "64bit Amazon Linux 2 v3.5.3 running PHP 8.0"
  version_label       = aws_elastic_beanstalk_application_version.eb_app_version.name
  
  # Pass the S3 website URL to the application
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "S3_WEBSITE_URL"
    value     = "http://${aws_s3_bucket_website_configuration.website.website_endpoint}"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "LabRole"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t3.small"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "LoadBalanced"
  }

  setting {
    namespace = "aws:ec2:instances"
    name      = "EnableSpot"
    value     = "false"
  }

  setting {
    namespace = "aws:ec2:instances"
    name      = "InstanceTypes"
    value     = "t3.small"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "1"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "2"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.vpc_id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", var.subnet_ids)
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = join(",", var.elb_subnet_ids)
  }

  # EFS configuration
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "EFS_FILE_SYSTEM_ID"
    value     = aws_efs_file_system.eb_efs.id
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "EFS_MOUNT_DIRECTORY"
    value     = "/var/app/efs"
  }

  # Database settings
  setting {
    namespace = "aws:rds:dbinstance"
    name      = "DBEngine"
    value     = "mysql"
  }

  setting {
    namespace = "aws:rds:dbinstance"
    name      = "DBEngineVersion"
    value     = "8.0"
  }

  setting {
    namespace = "aws:rds:dbinstance"
    name      = "DBInstanceClass"
    value     = "db.t3.small"
  }

  setting {
    namespace = "aws:rds:dbinstance"
    name      = "DBUser"
    value     = var.db_username
  }

  setting {
    namespace = "aws:rds:dbinstance"
    name      = "DBPassword"
    value     = var.db_password
  }

  setting {
    namespace = "aws:rds:dbinstance"
    name      = "DBAllocatedStorage"
    value     = "5"
  }

  setting {
    namespace = "aws:rds:dbinstance"
    name      = "DBDeletionPolicy"
    value     = "Delete"
  }

  # IMDSv1 is enabled
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "DisableIMDSv1"
    value     = "false"
  }

  depends_on = [
    aws_elastic_beanstalk_application_version.eb_app_version,
    aws_efs_mount_target.eb_efs_mount
  ]
}

# Custom EFS mount script
resource "aws_s3_object" "efs_mount_script" {
  bucket  = aws_s3_bucket.app_version_bucket.id
  key     = "efs-mount.sh"
  content = <<EOT
#!/bin/bash
EFS_ID=${aws_efs_file_system.eb_efs.id}
EFS_MOUNT_DIR=/var/app/efs
mkdir -p $EFS_MOUNT_DIR
echo "$EFS_ID:/ $EFS_MOUNT_DIR nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,_netdev 0 0" >> /etc/fstab
mount -a
chown webapp:webapp $EFS_MOUNT_DIR
EOT
}

# Output the Elastic Beanstalk environment URL
output "elastic_beanstalk_url" {
  value = aws_elastic_beanstalk_environment.eb_env.cname
}

# Output the RDS endpoint
output "rds_endpoint" {
  value = aws_elastic_beanstalk_environment.eb_env.endpoint_url
}

# Output the EFS ID
output "efs_id" {
  value = aws_efs_file_system.eb_efs.id
}