terraform {
  backend "s3" {
    bucket         = "batch3-s3-state"
    key            = "TASK15_STATES_FILES/terraform.tfstate"  # You can customize path per environment/project
    region         = "us-east-1"                   # Change if your bucket is in another region
    encrypt        = true
  }
}
