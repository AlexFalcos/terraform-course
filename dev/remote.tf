provider "aws" {
    region = "us-east-1"
    allowed_account_ids = ["408882703417"]
}

# Secondo step Gli Stati in S3
terraform {
 backend "s3" {
 encrypt = true
 bucket = "terraform-remote-state-storage-s3-for-alex"
 region = "us-east-1"
 key = "youtube/terraform.tfstate"
 dynamodb_table = "terraform-state-lock-dynamo"
 }
}

resource "aws_s3_bucket" "terraform-state-storage-s3" {
    bucket = "terraform-remote-state-storage-s3-for-alex"

    lifecycle {
      prevent_destroy = true
    }

    tags = {
      Name = "S3 Remote Terraform State Store"
    }
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.terraform-state-storage-s3.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name = "terraform-state-lock-dynamo"
  hash_key = "LockID"
  
  # I changed the model because this pay per request is more efficient for this purpose
  billing_mode = "PAY_PER_REQUEST"
  #read_capacity = 20
  #write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "DynamoDB Terraform State Lock Table"
  }
}