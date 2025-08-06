# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-27

### Added
- Initial release of AWS Certificate Manager (ACM) module
- SSL/TLS certificate creation and management
- Cross-region certificate support
- DNS validation with Route 53 integration
- Email validation support
- CloudWatch monitoring for certificate expiration
- Standardized tagging support
- Variable validation with error messages
- Documentation and working examples
- Resource mapping for dependencies

### Changed
- Provider versions: Terraform ~> 1.13.0, AWS Provider ~> 6.2.0

### Security
- Input validation for domain names and regions
- Secure default configurations
- Security scanning integration
- Cross-variable validation for consistency

### Fixed
- Corrected Azure references to AWS-specific content
- Fixed provider configuration syntax
- Updated test files for AWS resources
- Improved validation error messages
