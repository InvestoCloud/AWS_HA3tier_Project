locals {
  db_port = var.db_engine == "postgres" ? 5432 : 3306
}

# Latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# IAM role for EC2 instances
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2-role"
  }
}

# Allow EC2 app RDS credential secret access
resource "aws_iam_policy" "read_db_secret" {
  name        = "${var.project_name}-${var.environment}-read-db-secret"
  description = "Allow EC2 app instances to read the RDS credential secret"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = var.db_secret_arn
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-read-db-secret"
  }
}

resource "aws_iam_role_policy_attachment" "read_db_secret" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.read_db_secret.arn
}

# Allows Session Manager access
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# Launch Template
resource "aws_launch_template" "app" {
  name_prefix   = "${var.project_name}-${var.environment}-app-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type

  vpc_security_group_ids = [var.app_sg_id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    aws_region    = var.aws_region
    db_engine     = var.db_engine
    db_endpoint   = var.db_endpoint
    db_name       = var.db_name
    db_secret_arn = var.db_secret_arn
    db_port       = local.db_port
  }))

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.project_name}-${var.environment}-app"
      Tier = "private-app"
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name = "${var.project_name}-${var.environment}-app-volume"
    }
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-launch-template"
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "app" {
  name = "${var.project_name}-${var.environment}-asg"

  min_size         = var.asg_min_size
  desired_capacity = var.asg_desired_capacity
  max_size         = var.asg_max_size

  vpc_zone_identifier = var.private_app_subnet_ids

  health_check_type         = "ELB"
  health_check_grace_period = var.health_check_grace_period

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-app"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project_name
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Attach ASG to ALB Target Group
resource "aws_autoscaling_attachment" "app_tg" {
  autoscaling_group_name = aws_autoscaling_group.app.id
  lb_target_group_arn    = var.target_group_arn
}

# Step Scaling Policy - Scale Out
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "${var.project_name}-${var.environment}-scale-out"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type            = "StepScaling"
  adjustment_type        = "ChangeInCapacity"
  /*cooldown               = var.scaling_cooldown*/

  metric_aggregation_type = "Average"

  # CPU 60% to less than 80% = add 1 instance
  step_adjustment {
    metric_interval_lower_bound = 0
    metric_interval_upper_bound = 20
    scaling_adjustment          = 1
  }

  # CPU 80% and above = add 2 instances
  step_adjustment {
    metric_interval_lower_bound = 20
    scaling_adjustment          = 2
  }
}

# Step Scaling Policy - Scale In
resource "aws_autoscaling_policy" "scale_in" {
  name                   = "${var.project_name}-${var.environment}-scale-in"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type            = "StepScaling"
  adjustment_type        = "ChangeInCapacity"
  /*cooldown               = var.scaling_cooldown*/

  metric_aggregation_type = "Average"

  # CPU at or below 30% = remove 1 instance
  step_adjustment {
    metric_interval_upper_bound = 0
    scaling_adjustment          = -3
  }
}

# CloudWatch Alarm - Scale Out at CPU >= 60%
resource "aws_cloudwatch_metric_alarm" "scale_out_cpu" {
  alarm_name          = "${var.project_name}-${var.environment}-scale-out-cpu"
  alarm_description   = "Scale out when average ASG CPU is greater than or equal to ${var.scale_out_cpu_threshold}%"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = var.scale_out_cpu_threshold

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }

  alarm_actions = [
    aws_autoscaling_policy.scale_out.arn
  ]

  treat_missing_data = "notBreaching"

  tags = {
    Name = "${var.project_name}-${var.environment}-scale-out-cpu"
  }
}

# CloudWatch Alarm - Scale In at CPU <= 30%
resource "aws_cloudwatch_metric_alarm" "scale_in_cpu" {
  alarm_name          = "${var.project_name}-${var.environment}-scale-in-cpu"
  alarm_description   = "Scale in when average ASG CPU is less than or equal to ${var.scale_in_cpu_threshold}%"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 3
  datapoints_to_alarm = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = var.scale_in_cpu_threshold

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }

  alarm_actions = [
    aws_autoscaling_policy.scale_in.arn
  ]

  treat_missing_data = "notBreaching"

  tags = {
    Name = "${var.project_name}-${var.environment}-scale-in-cpu"
  }
}
