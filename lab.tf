#Build VPC
resource "aws_vpc" "labvpc" {
  cidr_block = var.aws_vpc_cidr
}

# Build Internet Gateway
resource "aws_internet_gateway" "lab_gateway" {
  vpc_id = aws_vpc.labvpc.id
}

# Create a subnet
resource "aws_subnet" "external" {
  vpc_id                  = aws_vpc.labvpc.id
  cidr_block              = var.aws_subnet_cidr
  availability_zone       = var.primary_az
 
}

#Create a Route Table
resource "aws_route_table" "lab_route_table" {
  vpc_id = aws_vpc.labvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab_gateway.id
  }
  
  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.lab_gateway.id
  }
  
  }
  
#Associate Route Table to Subnet
resource "aws_route_table_association" "lab_route_association" {
    subnet_id = aws_subnet.external.id
    route_table_id = aws_route_table.lab_route_table.id
}

#Create security groups 

resource "aws_security_group" "lab_sg" {
  name = "lab_sg"
  vpc_id = aws_vpc.labvpc.id
ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  
egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

#Create Network Interface
resource "aws_network_interface" "lab_nic" {
    count = var.instances
    subnet_id = aws_subnet.external.id
    #private_ips = ""
    security_groups = [aws_security_group.lab_sg.id]
}

#Create Elastic IP
resource "aws_eip" "lab_eip" {
  count = var.instances
  vpc                       = true
  network_interface         = aws_network_interface.lab_nic.id[count.index]
  #associate_with_private_ip = ""
  depends_on = [aws_internet_gateway.lab_gateway]
}

resource "aws_instance" "lab_vm" {
  count = var.instances
  availability_zone = var.primary_az
  ami           = var.ubuntu_ami
  instance_type = "t2.micro"
  #key_name = var.key_name
  network_interface {
        device_index = 0
        network_interface_id = aws_network_interface.lab_nic.id[count.index]
  }
 

}

output "public_ip" {
  description = "List of public IP addresses assigned to the instances, if applicable"
  value       = aws_instance.lab_eip.public_ip
}