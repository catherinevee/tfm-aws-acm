# ==============================================================================
# Provider Configuration
# ==============================================================================

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = merge(
      var.tags,
      {
        ManagedBy = "terraform"
        Module    = "tfm-aws-acm"
      }
    )
  }
}

# Optional secondary region provider for cross-region certificate usage
provider "aws" {
  alias  = "secondary"
  region = var.secondary_region
  
  default_tags {
    tags = merge(
      var.tags,
      {
        ManagedBy = "terraform"
        Module    = "tfm-aws-acm"
      }
    )
  }
}
