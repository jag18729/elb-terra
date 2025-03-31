# Elastic Beanstalk Website with MySQL and EFS

This Terraform project deploys a website to AWS Elastic Beanstalk with MySQL database and EFS (Elastic File System) for persistent shared storage.

## Prerequisites

- Terraform installed (v1.0.0 or newer)
- AWS CLI configured
- Website ZIP file ready for deployment

## Configuration

1. Update the `terraform.tfvars` file with your specific values:
   - Make sure `app_version_bucket_name` is globally unique
   - Set a strong database password
   - Verify the path to your application ZIP file
   - Add your VPC ID and subnet IDs for EFS mount targets

2. The `instance_profile` is already set to "LabRole" as requested

3. Ensure your application code is prepared to use EFS storage:
   - EFS will be mounted at `/var/app/efs` in your application
   - Your application can write to this directory for persistent storage

## Deployment Steps

1. Initialize Terraform:
   ```
   terraform init
   ```

2. Plan the deployment:
   ```
   terraform plan
   ```

3. Apply the configuration:
   ```
   terraform apply
   ```

4. After deployment, you can find the environment URL in Terraform outputs:
   ```
   terraform output elastic_beanstalk_url
   ```

## Configuration Details

- Uses Apache web server (PHP environment)
- MySQL/MariaDB database (t3.small instance)
- IMDSv1 is enabled
- Dev/Test environment
- Burstable instance types (t3.small)
- EFS for persistent shared storage
- EFS mount point at `/var/app/efs`

## Cleanup

To destroy all created resources:
```
terraform destroy
```