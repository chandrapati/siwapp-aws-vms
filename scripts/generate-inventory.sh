#!/bin/bash
# ==============================================================================
# Generate Ansible Inventory from AWS Terraform Deployment
# ==============================================================================
# This script creates an Ansible inventory file from Terraform outputs
# Usage: ./generate-inventory.sh /path/to/terraform/directory
# ==============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}→ $1${NC}"
}

# Check if terraform directory provided
if [ -z "$1" ]; then
    TERRAFORM_DIR="../terraform"
else
    TERRAFORM_DIR="$1"
fi

if [ ! -d "$TERRAFORM_DIR" ]; then
    print_error "Terraform directory not found: $TERRAFORM_DIR"
    exit 1
fi

print_info "Reading Terraform outputs from: $TERRAFORM_DIR"

cd "$TERRAFORM_DIR"

# Check if terraform state exists
if [ ! -f "terraform.tfstate" ]; then
    print_error "Terraform state file not found. Deploy infrastructure first."
    exit 1
fi

# Get outputs (adjust these based on your Terraform outputs)
print_info "Extracting instance information..."

# Try to get IPs from Terraform outputs
DBLB_IP=$(terraform output -json | jq -r '.dblb_public_ip.value // empty' 2>/dev/null || echo "")
DB1_IP=$(terraform output -json | jq -r '.db1_public_ip.value // empty' 2>/dev/null || echo "")
DB2_IP=$(terraform output -json | jq -r '.db2_public_ip.value // empty' 2>/dev/null || echo "")
DB3_IP=$(terraform output -json | jq -r '.db3_public_ip.value // empty' 2>/dev/null || echo "")
APPLB_IP=$(terraform output -json | jq -r '.applb_public_ip.value // empty' 2>/dev/null || echo "")
APP1_IP=$(terraform output -json | jq -r '.app1_public_ip.value // empty' 2>/dev/null || echo "")
APP2_IP=$(terraform output -json | jq -r '.app2_public_ip.value // empty' 2>/dev/null || echo "")
APP3_IP=$(terraform output -json | jq -r '.app3_public_ip.value // empty' 2>/dev/null || echo "")

# SSH key path (adjust based on your setup)
SSH_KEY="./siwapp-key.pem"

# Go back to original directory
ORIG_DIR=$(pwd)
cd - > /dev/null

# Create inventory directory
mkdir -p ansible/inventory

# Generate inventory file
INVENTORY_FILE="ansible/inventory/aws.ini"

print_info "Generating inventory file: $INVENTORY_FILE"

cat > "$INVENTORY_FILE" << INVENTORY
# ==============================================================================
# Ansible Inventory for Siwapp AWS Deployment
# Generated: $(date)
# ==============================================================================

[all:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file=$SSH_KEY
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
ansible_python_interpreter=/usr/bin/python3

# Database Load Balancer
[vm_tag_db_lb]
dblb ansible_host=$DBLB_IP

# Database Servers
[vm_tag_db]
db1 ansible_host=$DB1_IP lead=true
db2 ansible_host=$DB2_IP lead=false
db3 ansible_host=$DB3_IP lead=false

# Application Load Balancer
[vm_tag_app_lb]
applb ansible_host=$APPLB_IP

# Application Servers
[vm_tag_app]
app1 ansible_host=$APP1_IP
app2 ansible_host=$APP2_IP
app3 ansible_host=$APP3_IP

# Group all database components
[database:children]
vm_tag_db_lb
vm_tag_db

# Group all application components
[application:children]
vm_tag_app_lb
vm_tag_app
INVENTORY

print_success "Inventory file created: $INVENTORY_FILE"
print_success "Inventory generation complete!"

echo ""
print_info "To test connectivity, run:"
echo "  ansible all -i $INVENTORY_FILE -m ping"
