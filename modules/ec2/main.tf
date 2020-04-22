data "aws_ami" "ecs" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}


resource "aws_key_pair" "default" {
  key_name   = var.prefix
  public_key = file(var.public_key_path)
}

resource "aws_security_group" "instance" {
  name        = "${var.prefix}-Instance"
  description = "Controls access from/to EC2 instance"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = concat([{ port = 22, cidr_blocks = var.ssh_whitelist }], var.instance_ingress)
    iterator = it
    content {
      from_port   = it.value.port
      to_port     = it.value.port
      protocol    = lookup(it.value, "protocol", "tcp")
      cidr_blocks = lookup(it.value, "cidr_blocks", ["0.0.0.0/0"])
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-Instances"
  }
}

data "aws_iam_policy_document" "instance" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "instance" {
  name               = "${var.prefix}-Instance"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.instance.json
}

resource "aws_iam_role_policy_attachment" "container_service_role_to_instance_policy" {
  role       = aws_iam_role.instance.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "instance" {
  name = "${var.prefix}-Instance"
  path = "/"
  role = aws_iam_role.instance.id

  provisioner "local-exec" {
    command = "sleep 10"
  }
}

resource "aws_launch_configuration" "instance" {
  name_prefix                 = var.prefix
  image_id                    = data.aws_ami.ecs.id
  instance_type               = var.instance_type
  iam_instance_profile        = aws_iam_instance_profile.instance.name
  security_groups             = [aws_security_group.instance.id]
  associate_public_ip_address = length(var.ssh_whitelist) > 0
  key_name                    = aws_key_pair.default.id
  user_data                   = <<EOF
                           #!/bin/bash
                           echo 'ECS_CLUSTER=${var.ecs_cluster}' >> /etc/ecs/ecs.config
                           EOF

  root_block_device {
    volume_size = var.instance_root_volume_size
    volume_type = "gp2"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "default" {
  name = var.prefix

  launch_configuration      = aws_launch_configuration.instance.name
  vpc_zone_identifier       = var.subnet_ids
  max_size                  = var.max_number_of_instances
  min_size                  = var.min_number_of_instances
  desired_capacity          = var.min_number_of_instances
  health_check_grace_period = 300
  health_check_type         = "EC2"

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}
