# This is the ECS policy required so that agent has access to ECS service
resource "aws_iam_policy" "demoECSPolicy" {
  name = "demoECSPolicy"
  description = "ECS Policy for the Demo"
  path = "/"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "ec2:*",
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": "ecs:*",
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "elasticloadbalancing:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "cloudwatch:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "autoscaling:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ecr:BatchGetImage",
                "ecr:GetDownloadUrlForLayer",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage",
                "ecr:GetAuthorizationToken",
                "ecr:CreateRegistry"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

# AWS role for ECS
resource "aws_iam_role" "demoECSRole" {
  name = "demoECSRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    },
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Attaching the role to the policy
resource "aws_iam_policy_attachment" "demoRolePolicyAttach" {
  name = "demoRolePolicyAttach"
  roles = [
    "${aws_iam_role.demoECSRole.name}"]
  policy_arn = "${aws_iam_policy.demoECSPolicy.arn}"
}

# creating an instance profile so that container instances have right role
resource "aws_iam_instance_profile" "demoECSInstProf" {
  name = "demoECSInstProf"
  roles = [
    "${aws_iam_role.demoECSRole.name}"]
}
