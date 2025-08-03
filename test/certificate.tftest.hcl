variables {
  aws_region = "us-east-1"
  certificates = {
    "test-example-com" = {
      domain_name               = "test.example.com"
      subject_alternative_names = ["*.test.example.com"]
      validation_method        = "DNS"
    }
  }
  tags = {
    Environment = "test"
    Project     = "test-project"
  }
}

provider "aws" {
  region = "us-east-1"
}

run "setup" {
  command = plan

  assert {
    condition     = length(aws_acm_certificate.certificates) > 0
    error_message = "At least one certificate should be created"
  }

  assert {
    condition     = aws_acm_certificate.certificates["test-example-com"].domain_name == "test.example.com"
    error_message = "Certificate domain name does not match input"
  }

  assert {
    condition     = aws_acm_certificate.certificates["test-example-com"].validation_method == "DNS"
    error_message = "Certificate validation method should be DNS"
  }
}
