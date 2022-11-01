resource "aws_iam_role" "forecast" {
  name_prefix = "forecast_${var.name}-${random_pet.this.id}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = ["forecast.amazonaws.com"]
        }
      },
    ]
  })
  tags = var.tags
  inline_policy {
    name = "${var.name}-${random_pet.this.id}"
    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:Get*",
            "s3:List*",
            "s3:PutObject"
          ],
          "Resource" : [
            "${aws_s3_bucket.this.arn}",
            "${aws_s3_bucket.this.arn}/*"
          ]
        }
      ]
    })
  }
}
