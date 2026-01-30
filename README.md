# SIWAPP AWS Deployment Guide

## Overview
This deployment will create 8 EC2 instances on AWS in the us-east-1 region:
- 1 Database Load Balancer
- 3 Database Servers (with replication)
- 1 Application Load Balancer
- 3 Application Servers

**Instance Type:** t3.micro  
**Region:** us-east-1  
**Availability Zone:** us-east-1a  
**Owner Tag:** sujichan

---

## Prerequisites

### 1. AWS Account Setup
- AWS Account with appropriate permissions
- AWS CLI installed and configured
- Access to create EC2 instances, VPC, Security Groups, and S3

### 2. Required Software
```bash
# Terraform
terraform --version  # Should be >= 1.1.0

# AWS CLI
aws --version
```

### 3. AWS Credentials Configuration
You need to configure AWS credentials using ONE of these methods:

#### Method A: AWS CLI Configuration (Recommended)
```bash
aws configure
# Enter your:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region: us-east-1
# - Default output format: json
```

#### Method B: Environment Variables
```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

### 4. SSH Key Pair
You must have an existing EC2 key pair named **siwapp-east-1** in us-east-1 region.

**To check if it exists:**
```bash
aws ec2 describe-key-pairs --key-names siwapp-east-1 --region us-east-1
```

**If it doesn't exist, create it:**
```bash
aws ec2 create-key-pair \
  --key-name siwapp-east-1 \
  --region us-east-1 \
  --query 'KeyMaterial' \
  --output text > siwapp-east-1.pem

chmod 400 siwapp-east-1.pem
```

### 5. S3 Bucket for VPC Flow Logs
You need an S3 bucket named **secureworkloadvpcflowbuckets** in us-east-1.

**To check if it exists:**
```bash
aws s3 ls s3://secureworkloadvpcflowbuckets --region us-east-1
```

**If it doesn't exist, create it:**
```bash
aws s3 mb s3://secureworkloadvpcflowbuckets --region us-east-1

# Enable versioning (recommended)
aws s3api put-bucket-versioning \
  --bucket secureworkloadvpcflowbuckets \
  --versioning-configuration Status=Enabled
```

---

## Deployment Steps

### Step 1: Verify AWS Credentials
```bash
# Test your AWS credentials
aws sts get-caller-identity

# You should see your account details
```

### Step 2: Navigate to Terraform Directory
```bash
cd siwapp-deployment/terraform
```

### Step 3: Review Variables (Optional)
If you want to customize any settings, edit `variables.tf`:
```bash
nano variables.tf
# You can change: region, instance type, CIDR blocks, etc.
```

### Step 4: Initialize Terraform
```bash
terraform init
```

**Expected output:** "Terraform has been successfully initialized!"

### Step 5: Validate Configuration
```bash
terraform validate
```

**Expected output:** "Success! The configuration is valid."

### Step 6: Plan the Deployment (Dry Run)
```bash
terraform plan
```

This will show you:
- All resources that will be created
- No actual changes will be made
- Review this carefully!

**Expected resources to be created:**
- 1 VPC
- 1 Subnet
- 1 Internet Gateway
- 1 Route Table
- 1 Security Group
- 1 VPC Flow Log
- 8 EC2 Instances

### Step 7: Deploy Infrastructure
```bash
terraform apply
```

- Type `yes` when prompted
- Deployment will take 5-10 minutes

**Watch for:**
- Green checkmarks for successful resource creation
- Any red errors (stop and troubleshoot)

### Step 8: Verify Deployment
After successful deployment, you'll see outputs with all IP addresses:

```bash
# View all outputs
terraform output

# Or specific outputs
terraform output all_instance_ips
```

### Step 9: Test SSH Access
```bash
# Replace <PUBLIC_IP> with any instance IP from outputs
ssh -i ~/.ssh/siwapp-east-1.pem centos@<PUBLIC_IP>

# If permission denied, check:
chmod 400 ~/.ssh/siwapp-east-1.pem
```

---

## Post-Deployment Verification

### Check All Instances in AWS Console
```bash
aws ec2 describe-instances \
  --filters "Name=tag:ApplicationName,Values=siwapp" \
  --query 'Reservations[].Instances[].[InstanceId,Tags[?Key==`Name`].Value|[0],State.Name,PublicIpAddress]' \
  --output table
```

### Check VPC Flow Logs
```bash
aws ec2 describe-flow-logs \
  --filter "Name=resource-type,Values=VPC" \
  --region us-east-1 \
  --output table
```

### Check Security Group Rules
```bash
terraform output security_group_id
aws ec2 describe-security-groups --group-ids <SG_ID> --region us-east-1
```

---

## Common Issues & Troubleshooting

### Issue 1: "Error: AccessDenied"
**Solution:** Check AWS credentials
```bash
aws sts get-caller-identity
aws configure list
```

### Issue 2: "Error: KeyPair not found"
**Solution:** Create the key pair
```bash
aws ec2 create-key-pair --key-name siwapp-east-1 --region us-east-1 \
  --query 'KeyMaterial' --output text > siwapp-east-1.pem
chmod 400 siwapp-east-1.pem
```

### Issue 3: "Error: S3 bucket does not exist"
**Solution:** Create the bucket
```bash
aws s3 mb s3://secureworkloadvpcflowbuckets --region us-east-1
```

### Issue 4: "Error: Invalid AMI"
**Solution:** Update AMI ID in variables.tf for us-east-1 region
```bash
# Find latest CentOS Stream 9 AMI
aws ec2 describe-images \
  --owners 125523088429 \
  --filters "Name=name,Values=CentOS Stream 9*" \
  --query 'Images | sort_by(@, &CreationDate) | [-1].[ImageId,Name]' \
  --region us-east-1 \
  --output table
```

### Issue 5: "Error: Insufficient capacity"
**Solution:** Try different availability zone
```bash
# Edit variables.tf
variable "aws_region_az" {
  default = "b"  # Change from "a" to "b" or "c"
}
```

---

## Cost Estimation

**Estimated Monthly Cost (if running 24/7):**
- 8 x t3.micro instances: ~$60-80/month
- EBS volumes (8 x 50GB): ~$40/month
- Data transfer: ~$5-20/month (varies)
- VPC Flow Logs storage: ~$5-10/month

**Total: ~$110-150/month**

**To reduce costs:**
- Stop instances when not in use
- Reduce instance count
- Use smaller EBS volumes
- Delete resources after testing

---

## Cleanup / Destroy Infrastructure

**WARNING: This will DELETE ALL resources created by Terraform!**

```bash
cd siwapp-deployment/terraform

# Preview what will be destroyed
terraform plan -destroy

# Destroy all resources
terraform destroy

# Type 'yes' when prompted
```

**Verify cleanup:**
```bash
aws ec2 describe-instances \
  --filters "Name=tag:ApplicationName,Values=siwapp" \
  --query 'Reservations[].Instances[].[InstanceId,State.Name]' \
  --output table
```

---

## Next Steps

After deployment, you may need to:

1. **Configure Application:**
   - SSH into instances
   - Install and configure Siwapp application
   - Set up database replication
   - Configure load balancers

2. **Security Hardening:**
   - Review security group rules (currently wide open - 0.0.0.0/0)
   - Implement least privilege access
   - Enable encryption at rest
   - Set up monitoring and alerts

3. **Backup Strategy:**
   - Configure automated EBS snapshots
   - Set up database backups
   - Test restore procedures

4. **Monitoring:**
   - Set up CloudWatch alarms
   - Configure log aggregation
   - Monitor costs with AWS Cost Explorer

---

## Support & Documentation

**Terraform Documentation:**
- https://www.terraform.io/docs

**AWS Documentation:**
- https://docs.aws.amazon.com/

**AWS CLI Reference:**
- https://docs.aws.amazon.com/cli/latest/reference/

---

## File Structure
```
siwapp-deployment/
├── terraform/
│   ├── main.tf                  # Provider configuration
│   ├── variables.tf             # Variable definitions
│   ├── data.tf                  # Data sources (S3 bucket)
│   ├── create_vpc.tf            # VPC configuration
│   ├── create_subnet.tf         # Subnet configuration
│   ├── create_igw.tf            # Internet Gateway
│   ├── create-route-table.tf    # Route table
│   ├── create-sg.tf             # Security group
│   ├── create_flow_log.tf       # VPC flow logs
│   ├── compute.tf               # EC2 instances
│   └── outputs.tf               # Output values
└── README.md                    # This file
```

---

## Changelog

**Version 1.0** (Current)
- Fixed hardcoded credentials (now uses AWS CLI/env vars)
- Updated to AWS provider v5.0
- Changed instance type to t3.micro
- Fixed region consistency (us-east-1)
- Added comprehensive outputs
- Improved security group configuration
- Updated AMI to CentOS Stream 9

---

## Contact

**Owner:** sujichan  
**Deployment Date:** 2026-01-29  
**Terraform Version:** >= 1.1.0  
**AWS Provider Version:** ~> 5.0
# siwapp-aws-vms
