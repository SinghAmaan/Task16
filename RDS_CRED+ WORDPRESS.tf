# -------------------------------
# Define Variables for DB LOGIN
# -------------------------------
variable "db_name" {
  default = "amaan_wp_db"
}

variable "db_username" {
  description = "MySQL username for WordPress"
  default     = "Singh"
}

variable "db_password" {
  description = "MySQL password for WordPress"
  default     = "singh123"
}

# -------------------------------
# Jump_Server EC2 Launch
# -------------------------------
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # official AWS account ID of Canonical, the company behind Ubuntu Linux.

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}
# Launching EC2 With WordPress Userdata.
resource "aws_instance" "jump_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.jump_public.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jump_sg.id]
  key_name                    = "AWS-FINAL-PROJECT"

  user_data = templatefile("${path.module}/wordpress_userdata.sh", {
    db_name     = var.db_name
    db_username = var.db_username
    db_password = var.db_password
    db_host     = aws_db_instance.mysql.address
  })

  tags = {
    Name = "JumpServer-WordPress"
  }
}

# -------------------------------
# Automatic AMI from Jump Server
# -------------------------------
resource "aws_ami_from_instance" "jumpserver_ami" {
  name               = "JumpServer-AMI-Auto-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  source_instance_id = aws_instance.jump_server.id
  depends_on         = [aws_instance.jump_server] # ✅ EC2 must finish first

  tags = {
    Name = "AMI of Jump Server with WordPress & RDS Config"
  }
}

