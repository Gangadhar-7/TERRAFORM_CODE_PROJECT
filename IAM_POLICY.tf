# Create an IAM Role for S3 Access.

resource "aws_iam_role" "EC2-project" {
  name = "EC2-project"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Create an S3 access policy to the above role.

resource "aws_iam_policy" "WebAppS3" {
  name        = "WebAppS3"
  description = "Policy for accessing S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["*"
        ]
        Effect = "Allow"
        Resource = ["*"]
      }
    ]
  })
}

# Attach the policy to the created role.

resource "aws_iam_role_policy_attachment" "s3_access_role_attachment" {
  policy_arn = aws_iam_policy.WebAppS3.arn
  role       = aws_iam_role.EC2-project.name
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.EC2-project.name
}