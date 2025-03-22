terraform {
  backend "s3" {
    bucket = "an-my-terraform-state" # The S3 bucket where the state file will be stored.
    key = "global/s3/terraform.tfstate" # The path within the S3 bucket to store the state file.
    region = "af-south-1"  # The AWS region where the S3 bucket is located (South Africa).
    use_lockfile = true # Enables state locking to prevent simultaneous changes
  }
}