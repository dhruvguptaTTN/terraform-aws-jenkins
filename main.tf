data "aws_ami" "amazon-linux-2" {
  most_recent = true
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
  owners = ["amazon"]
}

data "aws_vpc" "jenkins_vpc" {
  id = var.vpc_id
}

data "cloudinit_config" "server_config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.jenkins_version.rendered
  }
}

data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}


data "template_file" "jenkins_version" {
  template = "${file("${path.module}/user_data.tpl")}"
  vars = {
    jenkins_version = "${var.jenkins_version}"
  }
}


resource "aws_iam_role" "jenkins-role" {
  count              = var.iam_instance_profile == "" ? 1 : 0
  name               = "${var.project_name_prefix}-jenkins-role"
  tags               = merge(var.common_tags, tomap({ "Name" : "${var.project_name_prefix}-jenkins-role" }))
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
}

resource "aws_iam_instance_profile" "jenkins-profile" {
  count = var.iam_instance_profile == "" ? 1 : 0
  name  = "${var.project_name_prefix}-jenkins-profile"
  role  = aws_iam_role.jenkins-role[0].name
  tags  = merge(var.common_tags, tomap({ "Name" : "${var.project_name_prefix}-jenkins-profile" }))
}

data "aws_iam_policy" "jenkins_ssm_mananged_instance_core" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "jenkins_AmazonSSMManagedInstanceCore" {
  count      = var.iam_instance_profile == "" ? 1 : 0
  policy_arn = data.aws_iam_policy.jenkins_ssm_mananged_instance_core.arn
  role       = aws_iam_role.jenkins-role[0].name
}

resource "aws_security_group" "jenkins_sg" {
  name        = "${var.project_name_prefix}-jenkins-sg"
  vpc_id      = var.vpc_id
  tags        = merge(var.common_tags, tomap({ "Name" : "${var.project_name_prefix}-jenkins-sg" }))
  description = "Jenkins security group"
  
  ingress {
    description = "Allow SSM into the server"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${data.aws_vpc.jenkins_vpc.cidr_block}"]
  }

  ingress {
    description = "Allow access to Jenkins server"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${data.aws_vpc.jenkins_vpc.cidr_block}"]
  }

  egress {
    description = "Allow traffic to internet for Package installation"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Allow traffic to internet for Package installation"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2" {
  ami                     = data.aws_ami.amazon-linux-2.id
  instance_type           = var.instance_type
  subnet_id               = var.subnet_ids[0]
  vpc_security_group_ids  = length(var.security_group_ids) == 0 ? [aws_security_group.jenkins_sg.id] : concat([aws_security_group.jenkins_sg.id], var.security_group_ids)
  iam_instance_profile    = var.iam_instance_profile == "" ? aws_iam_instance_profile.jenkins-profile[0].name : var.iam_instance_profile
  ebs_optimized           = var.ebs_optimized
  disable_api_termination = var.disable_api_termination
  associate_public_ip_address = var.assign_public_ip
  #disable_api_stop       = var.disable_api_stop
  user_data               = data.cloudinit_config.server_config.rendered
  source_dest_check       = var.source_dest_check
  volume_tags             = merge(var.common_tags, tomap({ "Name" : "${var.project_name_prefix}-jenkins" }))
  tags                    = merge(var.common_tags, tomap({ "Name" : "${var.project_name_prefix}-jenkins" }))

  root_block_device {
    delete_on_termination = var.delete_on_termination
    encrypted             = var.encrypted
    volume_size           = var.root_volume_size
    volume_type           = var.volume_type
  }
}
