# SIWAPP Deployment - Quick Reference Card

## Essential Commands

### Deploy Infrastructure
```bash
cd siwapp-deployment
./deploy.sh
```

### Manual Deployment
```bash
cd siwapp-deployment/terraform
terraform init
terraform plan
terraform apply
```

### View Outputs
```bash
terraform output                    # All outputs
terraform output all_instance_ips  # Just IP addresses
```

### SSH into Instance
```bash
ssh -i siwapp-east-1.pem centos@<PUBLIC_IP>
```

### Destroy Everything
```bash
cd siwapp-deployment
./cleanup.sh
```
OR
```bash
cd terraform
terraform destroy
```

---

## AWS CLI Quick Commands

### Check Instances
```bash
aws ec2 describe-instances \
  --filters "Name=tag:ApplicationName,Values=siwapp" \
  --query 'Reservations[].Instances[].[Tags[?Key==`Name`].Value|[0],State.Name,PublicIpAddress]' \
  --output table
```

### Stop All Instances (Save Money)
```bash
aws ec2 stop-instances \
  --instance-ids $(aws ec2 describe-instances \
    --filters "Name=tag:ApplicationName,Values=siwapp" "Name=instance-state-name,Values=running" \
    --query 'Reservations[].Instances[].InstanceId' \
    --output text)
```

### Start All Instances
```bash
aws ec2 start-instances \
  --instance-ids $(aws ec2 describe-instances \
    --filters "Name=tag:ApplicationName,Values=siwapp" "Name=instance-state-name,Values=stopped" \
    --query 'Reservations[].Instances[].InstanceId' \
    --output text)
```

### Get Current Costs
```bash
aws ce get-cost-and-usage \
  --time-period Start=2026-01-01,End=2026-01-30 \
  --granularity MONTHLY \
  --metrics UnblendedCost \
  --output table
```

---

## Terraform Commands

| Command | Description |
|---------|-------------|
| `terraform init` | Initialize Terraform |
| `terraform validate` | Validate configuration |
| `terraform plan` | Preview changes |
| `terraform apply` | Apply changes |
| `terraform destroy` | Destroy all resources |
| `terraform output` | Show outputs |
| `terraform show` | Show current state |
| `terraform refresh` | Update state |

---

## Configuration Details

| Setting | Value |
|---------|-------|
| Region | us-east-1 |
| AZ | us-east-1a |
| Instance Type | t3.micro |
| Instance Count | 8 |
| Key Pair | siwapp-east-1 |
| S3 Bucket | secureworkloadvpcflowbuckets |
| Owner | sujichan |

---

## Troubleshooting

### Problem: "Error: InvalidKeyPair.NotFound"
```bash
aws ec2 create-key-pair \
  --key-name siwapp-east-1 \
  --region us-east-1 \
  --query 'KeyMaterial' \
  --output text > siwapp-east-1.pem
chmod 400 siwapp-east-1.pem
```

### Problem: "Error: InvalidBucketName"
```bash
aws s3 mb s3://secureworkloadvpcflowbuckets --region us-east-1
```

### Problem: Can't SSH
```bash
# Check key permissions
chmod 400 siwapp-east-1.pem

# Verify instance is running
aws ec2 describe-instances --instance-ids <INSTANCE_ID>

# Check security group allows SSH
aws ec2 describe-security-groups --group-ids <SG_ID>
```

### Problem: Access Denied
```bash
# Verify AWS credentials
aws sts get-caller-identity

# Reconfigure if needed
aws configure
```

---

## Cost Management

### Stop Instances at Night (Cron Job)
```bash
# Stop at 6 PM
0 18 * * * aws ec2 stop-instances --instance-ids <IDS>

# Start at 8 AM
0 8 * * * aws ec2 start-instances --instance-ids <IDS>
```

### Check Current Spend
```bash
aws ce get-cost-and-usage \
  --time-period Start=$(date -d "1 day ago" +%Y-%m-%d),End=$(date +%Y-%m-%d) \
  --granularity DAILY \
  --metrics UnblendedCost
```

---

## Files & Documentation

| File | Purpose |
|------|---------|
| `README.md` | Complete deployment guide |
| `CHECKLIST.md` | Pre-deployment checklist |
| `CONFIGURATION.md` | Configuration summary |
| `deploy.sh` | Automated deployment script |
| `cleanup.sh` | Resource cleanup script |

---

## Emergency Procedures

### Terminate All Instances Immediately
```bash
aws ec2 terminate-instances \
  --instance-ids $(aws ec2 describe-instances \
    --filters "Name=tag:ApplicationName,Values=siwapp" \
    --query 'Reservations[].Instances[].InstanceId' \
    --output text)
```

### Remove Everything (Nuclear Option)
```bash
cd terraform
terraform destroy -auto-approve
```

---

## Support Resources

- **Terraform Docs:** https://www.terraform.io/docs
- **AWS CLI Reference:** https://docs.aws.amazon.com/cli/
- **EC2 Documentation:** https://docs.aws.amazon.com/ec2/
- **Cost Calculator:** https://calculator.aws/

---

## Notes

- **Monthly Cost:** ~$120 if running 24/7
- **Deployment Time:** 12-21 minutes
- **SSH Username:** centos
- **Default Region:** us-east-1

**Remember to destroy resources when done testing to avoid charges!**
