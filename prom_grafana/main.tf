resource "aws_iam_role" "grafana_Role" {
  name = "${var.project_name}-${var.environment_name}-grafana-role"
  assume_role_policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
  }
  POLICY
}

resource "aws_iam_role_policy_attachment" "grafanaAmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.grafana_Role.name
}

resource "aws_iam_instance_profile" "grafana_iam_profile" {
  name = "${var.project_name}-${var.environment_name}-grafana-iam_profile"
  role = aws_iam_role.grafana_Role.name
}

resource "aws_security_group" "prom_grafana_sg" {
  vpc_id = data.aws_vpc.selected.id
  name        = "prometheus_grafana_sg"
  description = "Allow TLS inbound traffic"
  ingress {
    
      from_port   = 9090
      to_port     = 9090
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
    
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
   ingress {
    
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
  tags = {
    "Name"        = "${var.project_name}-prom_grafana-${var.environment_name}-sg"
    "Project"     = var.project_name
    "Environment" = var.environment_name
    "Owner"       = var.owner
  }
}

data "aws_ami" "amazon-linux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  owners = ["amazon"]
}

data "template_file" "promscript" {
template = file("${path.module}/script.sh")
}

resource "aws_instance" "prometheus" {
  ami           = data.aws_ami.amazon-linux.id
  instance_type = var.instance_type
  subnet_id = data.aws_subnets.private.ids[0]
  vpc_security_group_ids = ["${aws_security_group.prom_grafana_sg.id}"]
  
  tags = {
    "Name"        = "${var.project_name}-prom_grafana-${var.environment_name}"
    "Project"     = var.project_name
    "Environment" = var.environment_name
    "Owner"       = var.owner
  }
#    user_data = "${file("init.sh")}"
    user_data = "${data.template_file.promscript.rendered}"
}
