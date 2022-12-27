output "artifact_input" {
    value = aws_s3_bucket.input.bucket
}

output "artifact_output" {
    value = aws_s3_bucket.output.bucket
}
