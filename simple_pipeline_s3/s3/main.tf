resource "aws_s3_bucket" "input" {
    bucket  = "sandbox-cicd-bucket-input"
}


resource "aws_s3_bucket" "output" {
    bucket  = "sandbox-cicd-bucket-output"
}
