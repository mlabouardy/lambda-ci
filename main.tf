// Provider configuration
provider "aws" {
  region = "${var.region}"
}

// S3 bucket
resource "aws_s3_bucket" "bucket" {
  bucket = "${var.bucket}"
  acl    = "private"
}

// Jenkins slave instance profile
resource "aws_iam_instance_profile" "worker_profile" {
  name = "JenkinsWorkerProfile"
  role = "${aws_iam_role.worker_role.name}"
}

resource "aws_iam_role" "worker_role" {
  name = "JenkinsBuildRole"
  path = "/"

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
        }
    ]
}
EOF
}

resource "aws_iam_policy" "s3_policy" {
  name = "PushToS3Policy"
  path = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject",
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.bucket.arn}/*"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_policy" {
  name = "DeployLambdaPolicy"
  path = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "lambda:UpdateFunctionCode",
        "lambda:PublishVersion",
        "lambda:UpdateAlias"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "worker_s3_attachment" {
  role       = "${aws_iam_role.worker_role.name}"
  policy_arn = "${aws_iam_policy.s3_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "worker_lambda_attachment" {
  role       = "${aws_iam_role.worker_role.name}"
  policy_arn = "${aws_iam_policy.lambda_policy.arn}"
}

// Lambda IAM role
resource "aws_iam_role" "lambda_role" {
  name = "FibonacciFunctionRole"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "lambda.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

// Lambda function
resource "aws_lambda_function" "function" {
  filename      = "deployment.zip"
  function_name = "Fibonacci"
  role          = "${aws_iam_role.lambda_role.arn}"
  handler       = "main"
  runtime       = "go1.x"
}
