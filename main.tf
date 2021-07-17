provider aws {
    region = "us-east-1"
    access_key = ""
    secret_key = ""
}


# 1. Create VPC
resource "aws_vpc" "devOps_terraform_vpc" {
  cidr_block       = "10.0.0.0/26"
  tags = {
    Name = "devOps_terraform_vpc"
  }
}
# 2. Create IGW
resource "aws_internet_gateway" "test_igw" {
  vpc_id = aws_vpc.devOps_terraform_vpc.id

  tags = {
    Name = "test_igw"
  }
}
# 3. Create RT
resource "aws_route_table" "test_RT" {
  vpc_id = aws_vpc.devOps_terraform_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test_igw.id
  }
  tags = {
    Name = "test_RT"
  }
}
# 4. Subnet
resource "aws_subnet" "test_sn" {
  vpc_id     = aws_vpc.devOps_terraform_vpc.id
  cidr_block = "10.0.0.0/28"

  tags = {
    Name = "test_sn"
  }
}
# 5. Associate subnet with route table
resource "aws_route_table_association" "test_associate" {
  subnet_id      = aws_subnet.test_sn.id
  route_table_id = aws_route_table.test_RT.id
}
# 6. SG to allow port 22 and 80
resource "aws_security_group" "test_sg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.devOps_terraform_vpc.id

  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "test_sg"
  }
}
# 7. Create Amazon EC2
resource "aws_instance" "test_ins" {
  ami           = "ami-0ab4d1e9cf9a1215a"
  instance_type = "t3.micro"

 subnet_id     = aws_subnet.test_sn.id
  associate_public_ip_address = true
  key_name = "cali"


  user_data     = <<-EOF
			    #!/bin/bash
			    sudo yum update -y
			    sudo yum install httpd -y
			    sudo systemctl enable httpd
			    sudo systemctl start httpd
			    sudo echo "<h1> Coding Dojo! </h1>" > /var/www/html/index.html
			    EOF
  tags = {
    Name = "test_ins"
  }
}

#Create network interface
resource "aws_network_interface_sg_attachment" "test_sg_attachment" {
  security_group_id    = aws_security_group.test_sg.id
  network_interface_id = aws_instance.test_ins.primary_network_interface_id
}

#Create eip

