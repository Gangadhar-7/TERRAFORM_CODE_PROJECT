#Get the latest AMI.

data "aws_ami" "custom_ami" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20231207"]
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

# data "aws_ami" "custom_ami" {
#    most_recent = true
#   owners = [ "amazon" ]
#   filter {
#     name = "name"
#     values = [ "amzn2-ami-hvm-*-gp2" ]
#   }
#   filter {
#     name = "root-device-type"
#     values = [ "ebs" ]
#   }
#   filter {
#     name = "virtualization-type"
#     values = [ "hvm" ]
#   }
#   filter {
#     name = "architecture"
#     values = [ "x86_64" ]
#   }
# }


data "aws_acm_certificate" "ssl_certificate" {
  domain   = var.aws_profile == "dev" ? "${var.dev_domain}" : "${var.prod_domain}"
  statuses = ["ISSUED"]
}

resource "aws_lb_listener" "webapp_listener" {
  load_balancer_arn = aws_lb.app-lb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = data.aws_acm_certificate.ssl_certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webapp_tg.arn
  }
}

data "aws_caller_identity" "current" {}   #to get the account details.

#key management service
resource "aws_kms_key" "ebs_kms_key" {
  description             = "Symmetric KMS key for EBS"
  deletion_window_in_days = 10
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Sid" : "Enable IAM User Permissions",
      "Effect" : "Allow",
      "Principal" : {
        "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      },
      "Action" : "kms:*",
      "Resource" : "*"
      },
      {
        "Sid" : "Allow service-linked role use of the customer managed key",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
          ]
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "Allow attachment of persistent resources",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
          ]
        },
        "Action" : [
          "kms:CreateGrant"
        ],
        "Resource" : "*",
        "Condition" : {
          "Bool" : {
            "kms:GrantIsForAWSResource" : true
          }
        }
      }
    ]
  })
}


resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name          = "high-cpu-usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 5
  alarm_description   = "This metric checks if CPU usage is higher than 5% in the past 2 min"
  alarm_actions       = [aws_autoscaling_policy.scale_up_policy.arn]
  actions_enabled     = true
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp_asg.name
  }
}

resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name          = "low-cpu-usage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 3
  alarm_description   = "This metric checks if CPU usage is lower than 3% for the past 2 min"
  alarm_actions       = [aws_autoscaling_policy.scale_down_policy.arn]
  actions_enabled     = true
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp_asg.name
  }
}


resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.EC2-project.name
}

# Create access key pair.

# resource "aws_key_pair" "ec2keypair" {
#   key_name   = "ec2.pub"
#   public_key = file("~/.ssh/ec2.pub")
# }

# Select the DNS zone.
resource "aws_cloudwatch_log_group" "webapp_log_group" {
  name = "project"
}