resource "aws_sfn_state_machine" "steps" {
  name     = "${var.name}-${random_pet.this.id}"
  role_arn = aws_iam_role.steps.arn

  definition = <<EOF
{
  "Comment": "A Hello World example of the Amazon States Language using an AWS Lambda Function",
  "StartAt": "HelloWorld",
  "States": {
    "HelloWorld": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.rand.arn}",
      "End": true
    }
  }
}
EOF

  #   logging_configuration {
  #     log_destination        = "${aws_cloudwatch_log_group.steps.arn}:*"
  #     include_execution_data = true
  #     level                  = "ERROR"
  #   }
  tags = var.tags
}


resource "aws_cloudwatch_log_group" "steps" {
  name = "${var.name}-${random_pet.this.id}"
  tags = var.tags
}

resource "aws_iam_role" "steps" {
  name_prefix = "forecast_${var.name}-${random_pet.this.id}"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : [
              "states.amazonaws.com"
            ]
          },
          "Action" : "sts:AssumeRole",
          "Condition" : {
            "ArnLike" : {
              "aws:SourceArn" : "arn:aws:states:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:stateMachine:*"
            },
            "StringEquals" : {
              "aws:SourceAccount" : data.aws_caller_identity.current.account_id
            }
          }
        }
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
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "sns:Publish"
          ],
          "Resource" : aws_sns_topic.steps.arn
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogDelivery",
            "logs:GetLogDelivery",
            "logs:UpdateLogDelivery",
            "logs:DeleteLogDelivery",
            "logs:ListLogDeliveries",
            "logs:PutLogEvents",
            "logs:PutResourcePolicy",
            "logs:DescribeResourcePolicies",
            "logs:DescribeLogGroups"
          ],
          "Resource" : "${aws_cloudwatch_log_group.steps.arn}:*"
        }
      ]
    })
  }
}

resource "aws_sns_topic" "steps" {
  name = "${var.name}-${random_pet.this.id}"
  tags = var.tags
}

