# SNS Topic for alarm notifications
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-${var.environment}-alerts"

  tags = {
    Name = "${var.project_name}-${var.environment}-alerts"
  }
}

# Email subscription
# Important: The email recipient must confirm the subscription before alerts are delivered.
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# EC2 CPU Alarm
resource "aws_cloudwatch_metric_alarm" "ec2_high_cpu" {
  alarm_name          = "${var.project_name}-${var.environment}-ec2-high-cpu"
  alarm_description   = "Triggers when average EC2 CPU across the Auto Scaling Group is above ${var.ec2_cpu_alarm_threshold}%."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  datapoints_to_alarm  = 2
  metric_name          = "CPUUtilization"
  namespace            = "AWS/EC2"
  period               = 60
  statistic            = "Average"
  threshold            = var.ec2_cpu_alarm_threshold
  treat_missing_data   = "missing"

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2-high-cpu"
  }
}

# ALB 5XX Alarm - load balancer generated errors
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${var.project_name}-${var.environment}-alb-5xx"
  alarm_description   = "Triggers when the ALB generates 5XX errors."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  datapoints_to_alarm  = 1
  metric_name          = "HTTPCode_ELB_5XX_Count"
  namespace            = "AWS/ApplicationELB"
  period               = 60
  statistic            = "Sum"
  threshold            = var.alb_5xx_alarm_threshold
  treat_missing_data   = "notBreaching"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = {
    Name = "${var.project_name}-${var.environment}-alb-5xx"
  }
}

# Target Health Alarm
resource "aws_cloudwatch_metric_alarm" "unhealthy_targets" {
  alarm_name          = "${var.project_name}-${var.environment}-unhealthy-targets"
  alarm_description   = "Triggers when one or more ALB targets are unhealthy."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  datapoints_to_alarm  = 2
  metric_name          = "UnHealthyHostCount"
  namespace            = "AWS/ApplicationELB"
  period               = 60
  statistic            = "Maximum"
  threshold            = var.unhealthy_host_threshold
  treat_missing_data   = "notBreaching"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = {
    Name = "${var.project_name}-${var.environment}-unhealthy-targets"
  }
}

# RDS CPU Alarm
resource "aws_cloudwatch_metric_alarm" "rds_high_cpu" {
  alarm_name          = "${var.project_name}-${var.environment}-rds-high-cpu"
  alarm_description   = "Triggers when RDS CPU utilization is above ${var.rds_cpu_alarm_threshold}%."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  datapoints_to_alarm  = 2
  metric_name          = "CPUUtilization"
  namespace            = "AWS/RDS"
  period               = 300
  statistic            = "Average"
  threshold            = var.rds_cpu_alarm_threshold
  treat_missing_data   = "missing"

  dimensions = {
    DBInstanceIdentifier = var.db_identifier
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = {
    Name = "${var.project_name}-${var.environment}-rds-high-cpu"
  }
}

# RDS Storage Alarm
resource "aws_cloudwatch_metric_alarm" "rds_low_storage" {
  alarm_name          = "${var.project_name}-${var.environment}-rds-low-storage"
  alarm_description   = "Triggers when RDS free storage drops below the configured threshold."
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  datapoints_to_alarm  = 1
  metric_name          = "FreeStorageSpace"
  namespace            = "AWS/RDS"
  period               = 300
  statistic            = "Average"
  threshold            = var.rds_free_storage_threshold_bytes
  treat_missing_data   = "missing"

  dimensions = {
    DBInstanceIdentifier = var.db_identifier
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = {
    Name = "${var.project_name}-${var.environment}-rds-low-storage"
  }
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "this" {
  dashboard_name = "${var.project_name}-${var.environment}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "text"
        x      = 0
        y      = 0
        width  = 24
        height = 2
        properties = {
          markdown = "# ${var.project_name} ${var.environment} Monitoring Dashboard\nCloudOps portfolio dashboard for ALB, EC2 Auto Scaling, Target Health, and RDS."
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 2
        width  = 12
        height = 6
        properties = {
          title  = "ALB Request Count - Traffic"
          view   = "timeSeries"
          region = data.aws_region.current.region
          period = 60
          stat   = "Sum"
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 2
        width  = 12
        height = 6
        properties = {
          title  = "ALB Target Response Time - Latency"
          view   = "timeSeries"
          region = data.aws_region.current.region
          period = 60
          stat   = "Average"
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.alb_arn_suffix]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 8
        width  = 12
        height = 6
        properties = {
          title  = "ALB 5XX Errors"
          view   = "timeSeries"
          region = data.aws_region.current.region
          period = 60
          stat   = "Sum"
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count", "LoadBalancer", var.alb_arn_suffix]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 8
        width  = 12
        height = 6
        properties = {
          title  = "Target Group Health"
          view   = "timeSeries"
          region = data.aws_region.current.region
          period = 60
          metrics = [
            ["AWS/ApplicationELB", "HealthyHostCount", "LoadBalancer", var.alb_arn_suffix, "TargetGroup", var.target_group_arn_suffix, { stat = "Minimum" }],
            [".", "UnHealthyHostCount", ".", ".", ".", ".", { stat = "Maximum" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 14
        width  = 12
        height = 6
        properties = {
          title  = "EC2 CPU Utilization - App Tier"
          view   = "timeSeries"
          region = data.aws_region.current.region
          period = 60
          stat   = "Average"
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.asg_name]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 14
        width  = 12
        height = 6
        properties = {
          title  = "RDS CPU Utilization"
          view   = "timeSeries"
          region = data.aws_region.current.region
          period = 300
          stat   = "Average"
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.db_identifier]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 20
        width  = 12
        height = 6
        properties = {
          title  = "RDS Free Storage Space"
          view   = "timeSeries"
          region = data.aws_region.current.region
          period = 300
          stat   = "Average"
          metrics = [
            ["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", var.db_identifier]
          ]
        }
      },
      {
        type   = "alarm"
        x      = 12
        y      = 20
        width  = 12
        height = 6
        properties = {
          title = "Alarm Status"
          alarms = [
            aws_cloudwatch_metric_alarm.ec2_high_cpu.arn,
            aws_cloudwatch_metric_alarm.alb_5xx.arn,
            aws_cloudwatch_metric_alarm.unhealthy_targets.arn,
            aws_cloudwatch_metric_alarm.rds_high_cpu.arn,
            aws_cloudwatch_metric_alarm.rds_low_storage.arn
          ]
        }
      }
    ]
  })
}

data "aws_region" "current" {}