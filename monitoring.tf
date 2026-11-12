resource "aws_cloudwatch_log_group" "security_logs" {
  name              = "/aws/security/cloudtrail"
  retention_in_days = 7

  tags = {
    Project     = "AWS-Security-Monitoring"
    Environment = "Lab"
  }
}

resource "aws_cloudwatch_log_metric_filter" "failed_console_logins" {
  name           = "FailedConsoleLoginAttempts"
  log_group_name = aws_cloudwatch_log_group.security_logs.name

  pattern = "{ ($.eventName = \"ConsoleLogin\") && ($.responseElements.ConsoleLogin = \"Failure\") }"

  metric_transformation {
    name      = "FailedConsoleLoginCount"
    namespace = "SecurityMonitoring"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "failed_console_logins_alarm" {
  alarm_name          = "Failed-Console-Login-Alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "FailedConsoleLoginCount"
  namespace           = "SecurityMonitoring"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Triggers when a failed AWS Console login is detected."

  treat_missing_data = "notBreaching"
  alarm_actions      = [data.aws_sns_topic.security_alerts.arn]
}

data "aws_sns_topic" "security_alerts" {
  name = "SecurityLab-Alerts"
}