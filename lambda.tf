data "archive_file" "rand" {
  type        = "zip"
  output_path = "lambda/archive.zip"
  source_file = "lambda/index.js"
}

resource "aws_lambda_function" "rand" {
  filename         = "lambda/archive.zip"
  function_name    = "random_${random_pet.this.id}"
  role             = aws_iam_role.lambda.arn
  handler          = "index.handler"
  runtime          = "nodejs16.x"
}