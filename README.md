# Python Lambda Framework

AWS Lambda Layer for Python development with comprehensive schema support.

## Features

- **Multi-Service Support**: Comprehensive AWS service schemas
- **Environment Management**: Multi-account deployment support
- **CI/CD Integration**: GitHub Actions with OIDC authentication
- **Flexible Configuration**: Environment-specific S3 buckets and IAM roles

## Quick Start

1. **Setup IAM Roles and OIDC**:
   ```bash
   ./create_role.sh
   # or
   ./create_role.ps1
   ```

2. **Deploy to AWS**:
   ```bash
   sam build
   sam deploy
   ```

## GitHub Actions

This project includes automated CI/CD pipeline with:
- Multi-branch deployment (`main` → production, `deploy` → development)
- OIDC authentication for secure AWS access
- Environment-specific configurations

## Updated: 2025-07-31

Latest deployment test with OIDC and multi-environment setup.
Fixed IAM role ARN configuration for production environment.
Fixed IAM role ARN format with double colon (::) for correct AWS format.# GitHub Actions Test
# Test GitHub Actions OIDC Fix
