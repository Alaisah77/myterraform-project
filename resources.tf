resource "aws_vpc" "extra-vpc" {
  cidr_block = var.my_cidr_block

  tags = {
    Name = "extramile-vpc"
  }
}

resource "aws_subnet" "my_extra_subnet" {
  count = 3
  cidr_block = "10.0.${count.index + 1}.0/24"
  vpc_id     = aws_vpc.extra-vpc.id

  tags = {
    Name = "extra-subnet-${count.index + 1}"
  }
}

resource "aws_instance" "extraserver" {
  count = 4
  ami = "ami-0aa7d40eeae50c9a9"
  subnet_id = aws_subnet.my_extra_subnet[count.index % 3].id
  instance_type = "t2.micro"

  tags = {
    Name =  "extraserver-${count.index + 1}"
  }
}

resource "aws_elb" "extraelb" {
  name            = "extra-elb"
  security_groups = [aws_security_group.elb.id]
  subnets         = aws_subnet.my_extra_subnet.*.id

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }
}

resource "aws_security_group" "elb" {
  name        = "extra-elb-sg"
  description = "Security group for ELB"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

