output "elastic_beanstalk_url" {
  description = "URL of the Elastic Beanstalk environment"
  value       = aws_elastic_beanstalk_environment.eb_env.cname
}

output "rds_endpoint" {
  description = "Endpoint of the RDS database"
  value       = aws_elastic_beanstalk_environment.eb_env.endpoint_url
  sensitive   = true
}

output "efs_id" {
  description = "ID of the EFS file system"
  value       = aws_efs_file_system.eb_efs.id
}

output "app_bucket" {
  description = "S3 bucket for application versions"
  value       = aws_s3_bucket.app_version_bucket.bucket
}

output "app_version" {
  description = "Application version label"
  value       = aws_elastic_beanstalk_application_version.eb_app_version.name
}