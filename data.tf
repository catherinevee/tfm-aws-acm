# Data Sources

# Current AWS caller identity for account info
data "aws_caller_identity" "current" {}

# Current AWS region
data "aws_region" "current" {}
