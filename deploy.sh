#!/bin/bash
#
# SIWAPP AWS Deployment - Quick Start Script
# This script helps you deploy SIWAPP infrastructure to AWS
#

set -e  # Exit on any error

echo "=========================================="
echo "  SIWAPP AWS Deployment - Quick Start"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}! $1${NC}"
}

print_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

# Check prerequisites
echo "Step 1: Checking prerequisites..."
echo ""

# Check if terraform is installed
if command -v terraform &> /dev/null; then
    TERRAFORM_VERSION=$(terraform version | head -n 1)
    print_success "Terraform installed: $TERRAFORM_VERSION"
else
    print_error "Terraform is not installed"
    echo "Please install Terraform: https://www.terraform.io/downloads"
    exit 1
fi

# Check if AWS CLI is installed
if command -v aws &> /dev/null; then
    AWS_VERSION=$(aws --version)
    print_success "AWS CLI installed: $AWS_VERSION"
else
    print_error "AWS CLI is not installed"
    echo "Please install AWS CLI: https://aws.amazon.com/cli/"
    exit 1
fi

echo ""
echo "Step 2: Verifying AWS credentials..."
echo ""

# Check AWS credentials
if aws sts get-caller-identity &> /dev/null; then
    AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
    AWS_USER=$(aws sts get-caller-identity --query Arn --output text)
    print_success "AWS credentials configured"
    print_info "Account: $AWS_ACCOUNT"
    print_info "User: $AWS_USER"
else
    print_error "AWS credentials not configured"
    echo "Please run: aws configure"
    exit 1
fi

echo ""
echo "Step 3: Checking AWS resources..."
echo ""

# Check for SSH key pair
if aws ec2 describe-key-pairs --key-names siwapp-east-1 --region us-east-1 &> /dev/null; then
    print_success "SSH Key pair 'siwapp-east-1' exists"
else
    print_warning "SSH Key pair 'siwapp-east-1' not found"
    echo ""
    read -p "Would you like to create it now? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        aws ec2 create-key-pair \
            --key-name siwapp-east-1 \
            --region us-east-1 \
            --query 'KeyMaterial' \
            --output text > siwapp-east-1.pem
        chmod 400 siwapp-east-1.pem
        print_success "Key pair created and saved to siwapp-east-1.pem"
    else
        print_error "Cannot proceed without SSH key pair"
        exit 1
    fi
fi

# Check for S3 bucket
if aws s3 ls s3://secureworkloadvpcflowbuckets --region us-east-1 &> /dev/null; then
    print_success "S3 bucket 'secureworkloadvpcflowbuckets' exists"
else
    print_warning "S3 bucket 'secureworkloadvpcflowbuckets' not found"
    echo ""
    read -p "Would you like to create it now? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        aws s3 mb s3://secureworkloadvpcflowbuckets --region us-east-1
        print_success "S3 bucket created"
    else
        print_error "Cannot proceed without S3 bucket"
        exit 1
    fi
fi

echo ""
echo "Step 4: Preparing Terraform..."
echo ""

cd terraform

# Initialize Terraform
print_info "Running terraform init..."
if terraform init; then
    print_success "Terraform initialized"
else
    print_error "Terraform initialization failed"
    exit 1
fi

# Validate configuration
print_info "Running terraform validate..."
if terraform validate; then
    print_success "Configuration is valid"
else
    print_error "Configuration validation failed"
    exit 1
fi

echo ""
echo "Step 5: Planning deployment..."
echo ""

# Run terraform plan
print_info "Running terraform plan..."
terraform plan -out=tfplan

echo ""
echo "=========================================="
echo "  Ready to Deploy!"
echo "=========================================="
echo ""
echo "Review the plan above. This will create:"
echo "  • 1 VPC with subnet and routing"
echo "  • 1 Security Group"
echo "  • 1 VPC Flow Log"
echo "  • 8 EC2 t3.micro instances"
echo ""
echo "Estimated monthly cost: ~$110-150 (if running 24/7)"
echo ""
read -p "Do you want to proceed with deployment? (yes/no): " -r
echo ""

if [[ $REPLY == "yes" ]]; then
    echo ""
    print_info "Starting deployment..."
    echo ""
    
    if terraform apply tfplan; then
        echo ""
        print_success "Deployment completed successfully!"
        echo ""
        echo "=========================================="
        echo "  Deployment Summary"
        echo "=========================================="
        echo ""
        terraform output
        echo ""
        echo "Next steps:"
        echo "1. SSH into instances: ssh -i siwapp-east-1.pem centos@<IP>"
        echo "2. Configure your application"
        echo "3. Set up monitoring"
        echo ""
        print_warning "Don't forget to destroy resources when done to avoid charges:"
        echo "   cd terraform && terraform destroy"
    else
        print_error "Deployment failed"
        exit 1
    fi
else
    print_warning "Deployment cancelled"
    echo "To deploy later, run:"
    echo "  cd terraform"
    echo "  terraform apply"
fi

echo ""
print_success "Script completed!"
