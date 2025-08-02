# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-08-02

### Added
- Initial release of the Azure Certificate Management module
- Key Vault integration for certificate storage
- Self-signed certificate creation
- Certificate import functionality
- Certificate issuer configuration
- Certificate contacts management
- Private endpoint support
- Diagnostic settings
- Comprehensive variable validation
- Complete documentation and examples

### Changed
- Updated provider versions:
  - Terraform ~> 1.13.0
  - AWS Provider ~> 6.2.0
  - Azure Provider ~> 4.38.1

### Security
- Enabled default network ACLs
- Added minimum TLS version requirement
- Implemented secure default configurations
