# SIWAPP Deployment Configuration Summary

## Deployment Configuration

| Setting | Value |
|---------|-------|
| **AWS Region** | us-east-1 |
| **Availability Zone** | us-east-1a |
| **Owner Tag** | sujichan |
| **Application** | SIWAPP (Invoicing System) |
| **Instance Type** | t3.micro |
| **Number of Instances** | 8 |
| **Total Storage** | 400 GB (50 GB × 8) |

---

## Infrastructure Components

### Network Configuration
- **VPC CIDR:** 10.255.0.0/16
- **Subnet CIDR:** 10.255.1.0/24
- **DNS Support:** Enabled
- **DNS Hostnames:** Enabled
- **Internet Gateway:** Yes
- **VPC Flow Logs:** Enabled (to S3)

### Security Configuration
- **Security Group:** Custom (allows all traffic - 0.0.0.0/0)
- **SSH Access:** Port 22 (all sources)
- **Egress:** All traffic allowed
- **Key Pair:** siwapp-east-1

⚠️ **Security Note:** Current configuration is wide open for testing. Restrict access in production!

### Compute Resources

#### Database Tier (4 instances)
1. **Database Load Balancer** (siwapp_db_lb)
   - Role: Load balancing for database connections
   - Tags: vm_tag_db_lb

2. **Database Server 1** (siwapp_db1)
   - Role: Primary database server
   - Tags: vm_tag_db, Lead=true

3. **Database Server 2** (siwapp_db2)
   - Role: Database replica
   - Tags: vm_tag_db, Lead=false

4. **Database Server 3** (siwapp_db3)
   - Role: Database replica
   - Tags: vm_tag_db, Lead=false

#### Application Tier (4 instances)
1. **Application Load Balancer** (siwapp_app_lb)
   - Role: Load balancing for application traffic
   - Tags: vm_tag_app_lb

2. **Application Server 1** (siwapp_app1)
   - Role: Application server
   - Tags: vm_tag_app

3. **Application Server 2** (siwapp_app2)
   - Role: Application server
   - Tags: vm_tag_app

4. **Application Server 3** (siwapp_app3)
   - Role: Application server
   - Tags: vm_tag_app

---

## AMI Information

**Image:** CentOS Stream 9
**AMI ID:** ami-0453ec754f44f9a4a (us-east-1)
**Architecture:** x86_64
**Username:** centos

---

## Storage Configuration

**Per Instance:**
- Volume Type: gp3 (General Purpose SSD)
- Volume Size: 50 GB
- Encryption: Not enabled
- Delete on Termination: Yes

**Total Storage:** 400 GB across all instances

---

## Cost Breakdown

### Monthly Costs (24/7 operation)

| Resource | Quantity | Unit Cost | Total |
|----------|----------|-----------|-------|
| t3.micro instances | 8 | ~$7.50 | ~$60 |
| EBS gp3 (50GB) | 8 | ~$5.00 | ~$40 |
| Data Transfer | - | Variable | ~$10 |
| VPC Flow Logs | - | Variable | ~$10 |
| **TOTAL** | | | **~$120/month** |

### Cost Optimization Tips
1. **Stop instances when not in use** - Save ~75% on compute
2. **Use reserved instances** - Save up to 60% for long-term
3. **Reduce instance count** - Remove non-essential servers
4. **Smaller storage** - Reduce EBS size if possible
5. **Set up auto-shutdown** - Schedule off-hours shutdown

---

## Required AWS Resources

### Pre-existing Resources (Must Create Before Deployment)
1. **EC2 Key Pair:** siwapp-east-1
   - Location: us-east-1
   - Type: RSA
   - Private key file required for SSH access

2. **S3 Bucket:** secureworkloadvpcflowbuckets
   - Location: us-east-1
   - Purpose: VPC Flow Logs storage
   - Permissions: VPC Flow Logs write access

---

## Terraform Configuration

### Provider Versions
- **Terraform:** >= 1.1.0
- **AWS Provider:** ~> 5.0

### State Management
- **Backend:** Local (terraform.tfstate)
- **State File Location:** `./terraform/terraform.tfstate`
- ⚠️ **Important:** Back up state file regularly!

### Configuration Files
```
terraform/
├── main.tf              # Provider & Terraform config
├── variables.tf         # Variable definitions
├── data.tf             # Data sources (S3 bucket)
├── create_vpc.tf       # VPC resource
├── create_subnet.tf    # Subnet resource
├── create_igw.tf       # Internet Gateway
├── create-route-table.tf  # Route table & associations
├── create-sg.tf        # Security group
├── create_flow_log.tf  # VPC flow logs
├── compute.tf          # EC2 instances
└── outputs.tf          # Output definitions
```

---

## Network Architecture

```
Internet
    |
    v
Internet Gateway
    |
    v
VPC (10.255.0.0/16)
    |
    v
Subnet (10.255.1.0/24) - us-east-1a
    |
    +-- Security Group (all traffic)
    |
    +-- DB Load Balancer (public IP)
    +-- DB Server 1 (public IP)
    +-- DB Server 2 (public IP)
    +-- DB Server 3 (public IP)
    +-- App Load Balancer (public IP)
    +-- App Server 1 (public IP)
    +-- App Server 2 (public IP)
    +-- App Server 3 (public IP)
```

---

## Tags Applied to All Resources

| Tag | Value |
|-----|-------|
| Owner | sujichan |
| ApplicationName | siwapp |
| Scope | prod |
| KeepInstanceRunning | false |

---

## Outputs After Deployment

Terraform will output the following information:

- VPC ID
- Subnet ID
- Security Group ID
- Public IP addresses for all 8 instances
- Complete instance mapping

**To view outputs:**
```bash
cd terraform
terraform output
```

---

## Security Recommendations

### Immediate Actions (Before Production)
1. ✅ **Restrict Security Group Rules**
   - Limit SSH to your IP only
   - Close unused ports
   - Implement least privilege

2. ✅ **Enable Encryption**
   - EBS volume encryption
   - Data in transit (SSL/TLS)

3. ✅ **Set Up Monitoring**
   - CloudWatch alarms
   - Log aggregation
   - Cost alerts

4. ✅ **Implement Backup**
   - Automated EBS snapshots
   - Database backups
   - Test restore procedures

5. ✅ **Use Private Subnets**
   - Move databases to private subnet
   - Use NAT Gateway for outbound
   - Bastion host for SSH access

---

## Deployment Timeline

| Phase | Duration | Description |
|-------|----------|-------------|
| Prerequisites | 5-10 min | Configure AWS, create key pair, S3 bucket |
| Terraform Init | 1-2 min | Download providers, initialize |
| Terraform Plan | 1 min | Generate execution plan |
| Terraform Apply | 5-8 min | Create all resources |
| **Total** | **12-21 min** | **Complete deployment** |

---

## Maintenance Tasks

### Daily
- Monitor instance health
- Check application logs
- Review CloudWatch metrics

### Weekly
- Review security group rules
- Check for security updates
- Monitor costs

### Monthly
- Create EBS snapshots
- Review and optimize costs
- Update AMIs if needed
- Patch systems

---

## Troubleshooting Quick Reference

| Issue | Solution |
|-------|----------|
| Can't SSH | Check security group, verify key pair, confirm public IP |
| High costs | Stop unused instances, reduce count, check data transfer |
| Deployment fails | Verify credentials, check quotas, review error logs |
| Instances terminated | Check "KeepInstanceRunning" tag, review termination protection |
| Network issues | Verify route table, check security group, confirm IGW attached |

---

## Contact & Support

**Deployment Owner:** sujichan  
**Deployment Date:** 2026-01-29  
**Last Updated:** 2026-01-29  

**Resources:**
- Terraform Docs: https://www.terraform.io/docs
- AWS EC2 Docs: https://docs.aws.amazon.com/ec2/
- SIWAPP: https://siwapp.org/

---

## Version History

**v1.0** - Initial deployment configuration
- Fixed security issues from original template
- Updated to t3.micro instances
- Standardized on us-east-1 region
- Removed hardcoded credentials
- Added comprehensive documentation
