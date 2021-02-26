
#Build VPC
resource "aws_vpc" "labvpc" {
  for_each = var.vpc_map
  cidr_block = [each.value]

}

/*

# Build Internet Gateway
resource "aws_internet_gateway" "waap_demo_gateway" {
  vpc_id = aws_vpc.waapdemovpc.id
}


# Create a subnet
resource "aws_subnet" "external" {
  vpc_id                  = aws_vpc.waapdemovpc.id
  cidr_block              = var.aws_subnet_cidr
  availability_zone       = var.primary_az
 
}

#Create a Route Table
resource "aws_route_table" "waap_route_table" {
  vpc_id = aws_vpc.waapdemovpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.waap_demo_gateway.id
  }
  
  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.waap_demo_gateway.id
  }
  
  }

#Associate Route Table to Subnet
resource "aws_route_table_association" "waap_route_association" {
    subnet_id = aws_subnet.external.id
    route_table_id = aws_route_table.waap_route_table.id
}


#Create security groups 

resource "aws_security_group" "waap_sg" {
  name = "${var.victim_company}-ssh-sg"
  vpc_id = aws_vpc.waapdemovpc.id
ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.source_ip]
  }
ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [var.source_ip]
  }
  
egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.source_ip]
  }

}

#Create Network Interface
resource "aws_network_interface" "waap-nic" {
    subnet_id = aws_subnet.external.id
    private_ips = [var.waap_private]
    security_groups = [aws_security_group.waap_sg.id]
}


#Create Elastic IP
resource "aws_eip" "waap_eip" {
  vpc                       = true
  network_interface         = aws_network_interface.waap-nic.id
  associate_with_private_ip = var.waap_private
  depends_on = [aws_internet_gateway.waap_demo_gateway]
}

#Variable Processing
# Setup the userdata that will be used for the instance
data "template_file" "userdata_setup" {
  template = file("userdata_setup.template")

  vars  = {
    token     = var.token
    logic = file("vuln_bootstrap.sh")
  }
}


resource "aws_instance" "vuln_vm" {
  availability_zone = var.primary_az
  ami           = var.ubuntu_ami
  instance_type = "t2.micro"
  key_name = var.key_name
  network_interface {
        device_index = 0
        network_interface_id = aws_network_interface.waap-nic.id
  }
  
  user_data = data.template_file.userdata_setup.rendered
 
}

output "public_ip" {
  description = "List of public IP addresses assigned to the instances, if applicable"
  value       = aws_instance.vuln_vm.public_ip
}

*/