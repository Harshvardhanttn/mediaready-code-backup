resource "aws_iam_role" "EFKRole" {
  name = "${var.project_name}-${var.environment_name}-efk-role"
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

resource "aws_iam_role_policy_attachment" "EFKAmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.EFKRole.name
}

resource "aws_iam_instance_profile" "efk_iam_profile" {
  name = "${var.project_name}-${var.environment_name}-efk-iam_profile"
  role = aws_iam_role.EFKRole.name
}

//security group
resource "aws_security_group" "efk_sg" {
  vpc_id = data.aws_vpc.selected.id
  ingress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }
  egress {
    from_port   = 0
    protocol    = "all"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name          = "${var.project_name}-efk-${var.environment_name}-sg"
    "Project"     = var.project_name
    "Environment" = var.environment_name
    "Owner"       = var.owner
  }
}
data "aws_ami" "amazon_linux_2" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
resource "aws_instance" "elastic_nodes" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id = data.aws_subnets.private.ids[0]
  vpc_security_group_ids = [aws_security_group.efk_sg.id]
  key_name               =  var.key_name  #aws_key_pair.elastic_ssh_key.key_name
  iam_instance_profile         = aws_iam_instance_profile.efk_iam_profile.name
  tags = {
    "Name"        = "${var.project_name}-efk-${var.environment_name}"
    "Project"     = var.project_name
    "Environment" = var.environment_name
    "Owner"       = var.owner
  }
  user_data =  file("./elastic&kibana_userdata.sh")
}