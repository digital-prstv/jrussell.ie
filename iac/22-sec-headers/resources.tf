locals {
  name               = "www-jrussell-ie-sec-headers"
  lambda_description = "Edge Lambda to apply security Headers for www.jrussell.ie"
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "index.js"
  output_path = "javascript.zip"
}

resource "aws_lambda_function" "lambda" {
  function_name = local.name
  description   = local.lambda_description
  role          = aws_iam_role.role.arn
  handler       = "index.handler"
  runtime       = "nodejs22.x"
  filename      = "javascript.zip"
  publish       = true

  # source_code_hash = filebase64sha256("index.js")
  source_code_hash = data.archive_file.lambda.output_base64sha256

}

resource "aws_iam_role" "role" {
  name = local.name

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": [
            "lambda.amazonaws.com",
            "edgelambda.amazonaws.com"
          ]
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF



}
