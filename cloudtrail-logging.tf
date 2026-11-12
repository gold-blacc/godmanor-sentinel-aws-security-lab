
resource "aws_iam_role" "cloudtrail_cloudwatch_role" {
  name = "SecurityLab-CloudTrail-CloudWatch-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "cloudtrail_cloudwatch_policy" {
  name = "SecurityLab-CloudTrail-CloudWatch-Policy"
  role = aws_iam_role.cloudtrail_cloudwatch_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.security_logs.arn}:*"
      }
    ]
  })
}

resource "aws_cloudtrail" "security_audit" {
  name                          = "Security-Audit-Trail"
  s3_bucket_name                = "aws-security-audit-logs-sandra"
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true
  enable_log_file_validation    = true

  cloud_watch_logs_group_arn = "arn:aws:logs:us-east-1:878581768642:log-group:/aws/security/cloudtrail:*"

  cloud_watch_logs_role_arn = aws_iam_role.cloudtrail_cloudwatch_role.arn
  advanced_event_selector {
    name = "Management events selector"

    field_selector {
      field  = "eventCategory"
      equals = ["Management"]
    }
  }
}