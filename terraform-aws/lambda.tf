// Creates the lambda function
resource "aws_lambda_function" "lambda_server" {
  function_name = "PromiseProtocolServer"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_package.key

  runtime = "nodejs20.x"
  handler = "server.app"

  source_code_hash = data.archive_file.lambda_package.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "lambda_server" {
  name = "/aws/lambda/${aws_lambda_function.lambda_server.function_name}"

  retention_in_days = 30
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


// Packages server into a zip file to be stored on S3
data "archive_file" "lambda_package" {
  type = "zip"

  source_dir  = "${path.module}/server"
  output_path = "${path.module}/server.zip"
}

resource "aws_s3_object" "lambda_package" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "server.zip"
  source = data.archive_file.lambda_package.output_path

  etag = filemd5(data.archive_file.lambda_package.output_path)
}
