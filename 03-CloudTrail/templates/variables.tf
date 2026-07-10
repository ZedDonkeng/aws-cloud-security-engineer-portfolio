variable "aws_region" {
  default = "us-east-1"
}
variable "trail_bucket_name" {
  description = "Must be globally unique"
  type        = string
}
