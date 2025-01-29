terraform {
  backend "s3" {
    bucket         = "jeff-directive-tf-state-0128"
    key            = "myproject/dev/network/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}


# ========================
# Backend Setup (S3 & DynamoDB)
# ========================

resource "aws_s3_bucket" "terraform_state" {
  bucket        = "jeff-directive-tf-state-0128"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "terraform_bucket_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_crypto_conf" {
  bucket        = aws_s3_bucket.terraform_state.bucket 
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-state-locking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

# ========================
# IAM User Configuration
# ========================

resource "aws_iam_group" "terraform_demo" {
  name = "Terraform-demo"
}

resource "aws_iam_group_policy_attachment" "dynamodb_access" {
  group      = aws_iam_group.terraform_demo.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_group_policy_attachment" "ec2_access" {
  group      = aws_iam_group.terraform_demo.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_group_policy_attachment" "rds_access" {
  group      = aws_iam_group.terraform_demo.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

resource "aws_iam_group_policy_attachment" "route53_access" {
  group      = aws_iam_group.terraform_demo.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
}

resource "aws_iam_group_policy_attachment" "s3_access" {
  group      = aws_iam_group.terraform_demo.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_group_policy_attachment" "iam_access" {
  group      = aws_iam_group.terraform_demo.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

# SNS
resource "aws_iam_group_policy_attachment" "sns_access" {
  group      = aws_iam_group.terraform_demo.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}

# SQS
resource "aws_iam_group_policy_attachment" "sqs_access" {
  group      = aws_iam_group.terraform_demo.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}