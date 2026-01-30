# create-sg.tf
resource "aws_security_group" "sg" {
  name        = "siwapp-sg"
  description = "Security group for siwapp"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow all inbound traffic"
    protocol    = var.sg_ingress_proto
    from_port   = var.sg_ingress_all
    to_port     = var.sg_ingress_all
    cidr_blocks = [var.sg_all_cidr_block]
  }

  egress {
    description = "Allow all outbound traffic"
    protocol    = var.sg_egress_proto
    from_port   = var.sg_egress_all
    to_port     = var.sg_egress_all
    cidr_blocks = [var.sg_all_cidr_block]
  }

  tags = {
    Name  = "siwapp-sg"
    Owner = var.owner
  }
}
