locals {
  name               = "www-jrussell-ie-sec-headers"
  lambda_description = "Edge Lambda to apply security Headers for www.jrussell.ie"
}

resource "aws_lambda_function" "lambda" {
  function_name = local.name
  description   = local.lambda_description
  role          = aws_iam_role.role.arn
  handler       = "index.handler"
  runtime       = "nodejs12.x"
  filename      = "javascript.zip"
  publish       = true

  source_code_hash = filebase64sha256("index.js")

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
