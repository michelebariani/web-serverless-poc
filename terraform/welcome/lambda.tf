#
# Lambda
#

data "archive_file" "this" {
  type        = "zip"
  source_file = var.app_source_file
  output_path = "local/main.zip"
}

resource "aws_lambda_function" "this" {
  function_name    = "welcome-${var.env_name}"
  role             = aws_iam_role.this.arn
  runtime          = "python3.9"
  handler          = "main.handler"
  filename         = data.archive_file.this.output_path
  source_code_hash = data.archive_file.this.output_base64sha256

  environment {
    variables = {
      dynamodb_table_name = aws_dynamodb_table.this.name
    }
  }
}

resource "aws_lambda_permission" "this" {
  statement_id  = "welcomeInvoke-${var.env_name}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/*/*"
}
