terraform {
  backend "s3" {
    skip_requesting_account_id  = true
    skip_credentials_validation = true
    skip_get_ec2_platforms      = true
    skip_metadata_api_check     = true
    endpoint                    = ""
    region                      = "us-east-1" # Requires any valid AWS region
    bucket                      = "" # Space name
    key                         = "terraform.tfstate"
  }
}
