resource "aws_s3_bucket" "demo_bucket" {
  bucket = "akhil-001" 
}


resource "aws_s3_bucket_public_access_block" "demo_bucket_public_access_block" {
  bucket = aws_s3_bucket.demo_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_object" "demo_object" {
  bucket = aws_s3_bucket.demo_bucket.id
  key          = "lambda_function.zip"
  source        = "lambda_function.zip"
  
}

resource "aws_lambda_function" "demo_lambda" {
  function_name = "demo_lambda"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"

  s3_bucket = aws_s3_bucket.demo_bucket.id
  s3_key    = aws_s3_object.demo_object.key
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_exec_role_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}



