provider "aws" {
  region = "us-east-1"  
  profile = "default"   
}
terraform {
  backend "s3" {
    bucket  = "phdata-terraform-state--use1-az4--x-s3"
    key     = "terraform/phdata-terraform-state/terraform.tfstate"
    profile = "default"
    region  = "us-east-1"
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "MainVPC"
    Owner = "Abdul"
    CreatedBy = "Terraform"
    Environment = "Test"
  }
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "MainSubnet"
    Owner = "Abdul"
    CreatedBy = "Terraform"
    Environment = "Test"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Owner = "Abdul"
    CreatedBy = "Terraform"
    Environment = "Test"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

resource "aws_security_group" "allow_custom" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["152.58.32.247/32"]
  }

  ingress {
    from_port   = 3307
    to_port     = 3307
    protocol    = "tcp"
    cidr_blocks = ["152.58.32.247/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Owner = "Abdul"
    CreatedBy = "Terraform"
    Environment = "Test"
  }
}
resource "aws_secretsmanager_secret" "mysql_credentials" {
  name = "mysql_credentials"
}

resource "aws_secretsmanager_secret_version" "mysql_credentials" {
  secret_id     = aws_secretsmanager_secret.mysql_credentials.id
  secret_string = jsonencode({
    username = var.mysql_admin_username,
    password = var.mysql_admin_password,
    port     = var.port
  })
}
variable "mysql_admin_username" {
  description = "MySQL username"
  type        = string
  default     = "admin"
}
variable "mysql_admin_password" {
  description = "valid password for MySQL"
  type        = string
}
variable "port" {
  description = "MySQL port"
  type        = number
  default     = 3307
}
resource "aws_instance" "web" {
  ami           = "ami-084568db4383264d4" # Ubuntu AMI, update it as per region
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.allow_custom.id]
  key_name      = "aws-ssh-key" # Replace with your key pair name

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y mysql-server
              echo "port = 3307" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
              sudo sed -i 's/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
              sudo sed -i 's/mysqlx-bind-address\s*=\s*127.0.0.1/mysqlx-bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
              sudo systemctl restart mysql
              sudo ufw allow 3307/tcp
              sudo ufw reload
              sudo mysql -e "CREATE USER 'admin'@'%' IDENTIFIED BY '${var.mysql_admin_password}';"
              sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION;"
              sudo mysql -e "FLUSH PRIVILEGES;" 
              EOF

  tags = {
    Owner = "Abdul"
    CreatedBy = "Terraform"
    Environment = "Test"
  }
}
