# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-27

### Added
- Initial release of the AWS Certificate Manager (ACM) module
- SSL/TLS certificate creation and management
- Cross-region certificate support
- DNS validation with Route 53 integration
- Email validation support
- Certificate monitoring with CloudWatch alarms
- Comprehensive tagging support
- Enhanced variable validation
- Complete documentation and examples
- Resource map for better understanding

### Changed
- Updated provider versions:
  - Terraform ~> 1.13.0
  - AWS Provider ~> 6.2.0

### Security
- Enhanced input validation for domain names and regions
- Implemented secure default configurations
- Added security scanning integration
- Cross-variable validation for region consistency

### Fixed
- Removed Azure-specific content from documentation
- Fixed provider configuration syntax errors
- Updated test files to use AWS resources
- Enhanced error messages in validation blocks
