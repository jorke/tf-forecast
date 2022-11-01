data "archive_file" "rand" {
  type        = "zip"
  output_path = "lambda/archive.zip"
  source_file = "lambda/index.js"
}


resource "aws_s3_bucket_object" "rand" {
  bucket = aws_s3_bucket.this.id
  key    = "code/rand-${filemd5(data.archive_file.rand.source_file)}"
  source = data.archive_file.rand.source_file

  etag = filemd5(data.archive_file.rand.source_file)
}


resource "aws_lambda_function" "rand" {
  filename      = "lambda/archive.zip"
  function_name = "random_${random_pet.this.id}"
  role          = aws_iam_role.rand.arn
  handler       = "index.handler"
  runtime       = "nodejs16.x"
}

resource "aws_iam_role" "rand" {
  name_prefix = "lambda_${var.name}-${random_pet.this.id}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = ["lambda.amazonaws.com"]
        }
      },
    ]
  })
  tags = var.tags
  inline_policy {
    name = "lambda_${var.name}-${random_pet.this.id}"
    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "ec2:CreateNetworkInterface",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DeleteNetworkInterface",
            "ec2:AssignPrivateIpAddresses",
            "ec2:UnassignPrivateIpAddresses"
          ],
          "Resource" : "*"
        }
      ]
    })
  }
}