# Coffee Shop Website Deployment

## Static Website Deployment to S3

Your Coffee Shop website has been successfully deployed as a static website using Amazon S3.

### Access Information

- **S3 Bucket Name**: coffee-shop-website-static-1743400726
- **Website URL**: http://coffee-shop-website-static-1743400726.s3-website-us-east-1.amazonaws.com

### Features of this Implementation

- ✅ **Public Access**: The website is publicly accessible
- ✅ **Content Delivery**: All website files are properly uploaded
- ✅ **Index Document**: Configured to use index.html as the main page
- ✅ **Error Handling**: Configured to use index.html for error pages

### How to Access the Website

Simply visit the following URL in your web browser:
http://coffee-shop-website-static-1743400726.s3-website-us-east-1.amazonaws.com

### AWS Console Access

To check or modify your website in the AWS Console:

1. Log in to AWS Console at https://console.aws.amazon.com/
2. Navigate to S3 service
3. Click on the bucket named "coffee-shop-website-static-1743400726"
4. Under the "Properties" tab, scroll down to "Static website hosting"
5. You'll see your website endpoint and configuration

### Deployment Note

This deployment uses S3 static website hosting, which provides HTTP access but not HTTPS.
For a full Elastic Beanstalk deployment with HTTPS, additional IAM role configurations would be needed.

---

Deployed: Sun Mar 30 22:58:57 PDT 2025
