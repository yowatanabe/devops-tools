provider "aws" {
  region = "ap-northeast-1"

  default_tags {
    tags = {
      ManagedBy     = "Terraform"
      TerraformRepo = "https://github.com/yowatanabe/devops-tools"
      TerraformPath = "terraform/rds-auto-scheduler"
    }
  }
}

provider "archive" {
  # Configuration options
}
