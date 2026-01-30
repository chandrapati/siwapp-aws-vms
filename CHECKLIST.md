# Pre-Deployment Checklist

## Before You Deploy - Complete This Checklist

### 1. AWS Credentials ✓
- [ ] AWS Access Key ID available
- [ ] AWS Secret Access Key available
- [ ] AWS CLI configured: `aws configure`
- [ ] Test credentials: `aws sts get-caller-identity`

### 2. Required AWS Resources ✓
- [ ] EC2 Key Pair exists: **siwapp-east-1** (in us-east-1)
  ```bash
  aws ec2 describe-key-pairs --key-names siwapp-east-1 --region us-east-1
  ```
- [ ] S3 Bucket exists: **secureworkloadvpcflowbuckets**
  ```bash
  aws s3 ls s3://secureworkloadvpcflowbuckets --region us-east-1
  ```
- [ ] Private key file (.pem) saved securely
- [ ] Private key permissions set: `chmod 400 siwapp-east-1.pem`

### 3. Software Requirements ✓
- [ ] Terraform installed (>= 1.1.0)
  ```bash
  terraform --version
  ```
- [ ] AWS CLI installed
  ```bash
  aws --version
  ```

### 4. Cost Awareness ✓
- [ ] Understand monthly cost: ~$110-150 if running 24/7
- [ ] 8 EC2 t3.micro instances will be created
- [ ] 400GB EBS storage will be provisioned
- [ ] Plan to destroy resources after testing (if applicable)

### 5. Region & Settings ✓
- [ ] Deploying to: **us-east-1**
- [ ] Availability Zone: **us-east-1a**
- [ ] Instance Type: **t3.micro**
- [ ] Owner Tag: **sujichan**

### 6. Security Considerations ⚠️
- [ ] Security group allows all traffic (0.0.0.0/0) - good for testing, NOT for production
- [ ] Plan to harden security after deployment
- [ ] SSH access will be available on port 22
- [ ] All instances will have public IPs

### 7. Deployment Method
Choose ONE:

#### Option A: Quick Automated Deployment
```bash
cd siwapp-deployment
./deploy.sh
```

#### Option B: Manual Step-by-Step
```bash
cd siwapp-deployment/terraform
terraform init
terraform plan
terraform apply
```

---

## Quick Start Commands

### Fastest Path to Deployment:
```bash
# 1. Configure AWS
aws configure

# 2. Navigate to deployment directory
cd siwapp-deployment

# 3. Run automated deployment script
./deploy.sh
```

### Manual Deployment:
```bash
# 1. Configure AWS
aws configure

# 2. Create key pair (if needed)
aws ec2 create-key-pair \
  --key-name siwapp-east-1 \
  --region us-east-1 \
  --query 'KeyMaterial' \
  --output text > siwapp-east-1.pem
chmod 400 siwapp-east-1.pem

# 3. Create S3 bucket (if needed)
aws s3 mb s3://secureworkloadvpcflowbuckets --region us-east-1

# 4. Deploy with Terraform
cd siwapp-deployment/terraform
terraform init
terraform plan
terraform apply
```

---

## After Deployment

### Get IP Addresses:
```bash
cd terraform
terraform output all_instance_ips
```

### SSH into an instance:
```bash
ssh -i siwapp-east-1.pem centos@<PUBLIC_IP>
```

### Destroy when done:
```bash
cd terraform
terraform destroy
```

---

## Need Help?

- Detailed documentation: `README.md`
- Terraform issues: Check `terraform.log`
- AWS issues: `aws ec2 describe-instances --region us-east-1`
