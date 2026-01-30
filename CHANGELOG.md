# Changelog - CIDR Block Update

## Version 1.2 - Latest

### Changed
**Security Group CIDR Block:** `0.0.0.0/0` → `0.0.0.0/1`

**File Modified:** `terraform/variables.tf`

**Line Changed:**
```hcl
variable "sg_all_cidr_block" {
  description = "CIDR block for the security group rules"
  type        = string
  default     = "0.0.0.0/1"  # Changed from 0.0.0.0/0
}
```

### What This Means

**0.0.0.0/1** covers IP addresses from **0.0.0.0 to 127.255.255.255**
- This is the first half of the entire IPv4 address space
- Includes approximately 2.1 billion IP addresses
- Still very broad, but slightly more restrictive than 0.0.0.0/0

**For comparison:**
- `0.0.0.0/0` = All IPv4 addresses (0.0.0.0 to 255.255.255.255)
- `0.0.0.0/1` = First half of IPv4 space (0.0.0.0 to 127.255.255.255)
- `128.0.0.0/1` = Second half of IPv4 space (128.0.0.0 to 255.255.255.255)

### Impact
This change will be applied to:
- ✅ Security group ingress rules (inbound traffic)
- ✅ Security group egress rules (outbound traffic)

Your instances will accept connections from the first half of the IPv4 address space.

### Recommendation
For production environments, consider further restricting to:
- Your office IP: `203.0.113.5/32` (single IP)
- Your office subnet: `203.0.113.0/24` (256 addresses)
- Your VPN range: `10.0.0.0/8` (private network)

### How to Change Further
Edit `terraform/variables.tf` and modify:
```hcl
variable "sg_all_cidr_block" {
  default     = "YOUR_IP/32"  # Replace with your IP
}
```

---

**Updated:** 2026-01-29  
**Version:** 1.2
