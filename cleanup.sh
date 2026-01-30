#!/bin/bash
#
# SIWAPP AWS Cleanup Script
# This script destroys all Terraform-managed resources
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_warning() {
    echo -e "${YELLOW}$1${NC}"
}

print_error() {
    echo -e "${RED}$1${NC}"
}

print_success() {
    echo -e "${GREEN}$1${NC}"
}

echo ""
print_warning "=========================================="
print_warning "  SIWAPP AWS CLEANUP - DESTROY RESOURCES"
print_warning "=========================================="
echo ""
print_error "⚠️  WARNING: This will DELETE ALL resources created by Terraform!"
echo ""
echo "This includes:"
echo "  • 8 EC2 instances"
echo "  • All EBS volumes"
echo "  • VPC and networking components"
echo "  • Security groups"
echo "  • VPC Flow Logs"
echo ""
echo "The following will NOT be deleted:"
echo "  • S3 bucket (secureworkloadvpcflowbuckets)"
echo "  • SSH Key pair (siwapp-east-1)"
echo "  • Any data stored in S3"
echo ""

read -p "Are you ABSOLUTELY sure you want to destroy all resources? (type 'yes' to confirm): " -r
echo ""

if [[ $REPLY != "yes" ]]; then
    print_success "Cleanup cancelled. No resources were destroyed."
    exit 0
fi

echo ""
print_warning "Last chance! Type 'destroy-all' to proceed:"
read -r FINAL_CONFIRM
echo ""

if [[ $FINAL_CONFIRM != "destroy-all" ]]; then
    print_success "Cleanup cancelled. No resources were destroyed."
    exit 0
fi

cd terraform

echo ""
print_warning "Running terraform destroy..."
echo ""

if terraform destroy -auto-approve; then
    echo ""
    print_success "=========================================="
    print_success "  All Resources Destroyed Successfully"
    print_success "=========================================="
    echo ""
    echo "Verification:"
    echo ""
    
    # Verify instances are terminated
    INSTANCE_COUNT=$(aws ec2 describe-instances \
        --filters "Name=tag:ApplicationName,Values=siwapp" "Name=instance-state-name,Values=running,pending,stopping,stopped" \
        --query 'Reservations[].Instances[].InstanceId' \
        --output text \
        --region us-east-1 | wc -w)
    
    if [ "$INSTANCE_COUNT" -eq 0 ]; then
        print_success "✓ No SIWAPP instances found (all terminated)"
    else
        print_warning "! Found $INSTANCE_COUNT instance(s) - may be in 'terminating' state"
        echo "  They will be fully removed in a few minutes"
    fi
    
    echo ""
    echo "Optional: Clean up remaining resources"
    echo ""
    read -p "Do you want to delete the S3 bucket? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        aws s3 rb s3://secureworkloadvpcflowbuckets --force --region us-east-1
        print_success "S3 bucket deleted"
    fi
    
    echo ""
    read -p "Do you want to delete the SSH key pair? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        aws ec2 delete-key-pair --key-name siwapp-east-1 --region us-east-1
        print_success "SSH key pair deleted from AWS"
        print_warning "Don't forget to delete your local .pem file if you don't need it"
    fi
    
else
    echo ""
    print_error "=========================================="
    print_error "  Cleanup Failed"
    print_error "=========================================="
    echo ""
    echo "Some resources may not have been destroyed."
    echo "Please check the AWS console and try again."
    exit 1
fi

echo ""
print_success "Cleanup complete!"
