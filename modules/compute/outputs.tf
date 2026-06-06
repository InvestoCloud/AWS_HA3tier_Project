output "ami_id" {
  description = "Latest Amazon Linux 2023 AMI ID used by the launch template."
  value       = data.aws_ami.amazon_linux_2023.id
}

output "launch_template_id" {
  description = "Launch template ID."
  value       = aws_launch_template.app.id
}

output "launch_template_latest_version" {
  description = "Latest launch template version."
  value       = aws_launch_template.app.latest_version
}

output "asg_name" {
  description = "Auto Scaling Group name."
  value       = aws_autoscaling_group.app.name
}

output "asg_arn" {
  description = "Auto Scaling Group ARN."
  value       = aws_autoscaling_group.app.arn
}

output "instance_profile_name" {
  description = "IAM instance profile name attached to EC2 instances."
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "scale_out_policy_arn" {
  description = "Scale out policy ARN."
  value       = aws_autoscaling_policy.scale_out.arn
}

output "scale_in_policy_arn" {
  description = "Scale in policy ARN."
  value       = aws_autoscaling_policy.scale_in.arn
}

output "scale_out_alarm_name" {
  description = "Scale out CloudWatch alarm name."
  value       = aws_cloudwatch_metric_alarm.scale_out_cpu.alarm_name
}

output "scale_in_alarm_name" {
  description = "Scale in CloudWatch alarm name."
  value       = aws_cloudwatch_metric_alarm.scale_in_cpu.alarm_name
}