# IAM Policies for Certificate Management
# Optional IAM policies for automated certificate management

# IAM policy for ACM certificate management
data "aws_iam_policy_document" "acm_management" {
  count = var.create_iam_policy ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "acm:DescribeCertificate",
      "acm:ListCertificates",
      "acm:GetCertificate"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "acm:RequestCertificate",
      "acm:DeleteCertificate",
      "acm:AddTagsToCertificate",
      "acm:RemoveTagsFromCertificate"
    ]
    resources = [
      for cert in aws_acm_certificate.certificates : cert.arn
    ]
  }
}

# IAM policy for Route 53 DNS validation
data "aws_iam_policy_document" "route53_validation" {
  count = var.create_iam_policy && var.create_route53_records ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:GetChange",
      "route53:ListResourceRecordSets"
    ]
    resources = ["*"]
  }
}
