## [1.1.0](https://github.com/islamelkadi/terraform-aws-secrets-manager/compare/v1.0.2...v1.1.0) (2026-03-15)


### Features

* add manual triggering to release workflow ([fc59bc3](https://github.com/islamelkadi/terraform-aws-secrets-manager/commit/fc59bc32daf892010b136af7a334e20537554ecf))


### Documentation

* add GitHub Actions workflow status badges ([045b77c](https://github.com/islamelkadi/terraform-aws-secrets-manager/commit/045b77cb22da07a0549fff45e8d2dd1dd59cade1))
* add security scan suppressions section to README ([3f876c5](https://github.com/islamelkadi/terraform-aws-secrets-manager/commit/3f876c5f0d5ac94d1f2c1d67b0d295ed8bc48b3f))

## [1.0.2](https://github.com/islamelkadi/terraform-aws-secrets-manager/compare/v1.0.1...v1.0.2) (2026-03-08)


### Bug Fixes

* add CKV_TF_1 suppression for external module metadata ([f479a20](https://github.com/islamelkadi/terraform-aws-secrets-manager/commit/f479a200f770eb0b386d940d2e056bdd9dfa9c19))
* add skip-path for .external_modules in Checkov config ([d5e205f](https://github.com/islamelkadi/terraform-aws-secrets-manager/commit/d5e205f91b1b20025f7bafc3ea2aaed022693da8))
* address Checkov security findings ([199bf57](https://github.com/islamelkadi/terraform-aws-secrets-manager/commit/199bf57e8c6378676c7a277a89b47bdc65d8121d))
* correct .checkov.yaml format to use simple list instead of id/comment dict ([cf86846](https://github.com/islamelkadi/terraform-aws-secrets-manager/commit/cf868466efab4746fd2a8e0ead2cdc7c4136faa1))
* remove skip-path from .checkov.yaml, rely on workflow-level skip_path ([b86c0df](https://github.com/islamelkadi/terraform-aws-secrets-manager/commit/b86c0df96ea428ef37d194a2ca6f15ae6d2b9050))
* update workflow path reference to terraform-security.yaml ([8233134](https://github.com/islamelkadi/terraform-aws-secrets-manager/commit/8233134e3bcb26c76c07ec518165ca2456f87492))

## [1.0.1](https://github.com/islamelkadi/terraform-aws-secrets-manager/compare/v1.0.0...v1.0.1) (2026-03-08)


### Code Refactoring

* enhance examples with real infrastructure and improve code quality ([323a7b3](https://github.com/islamelkadi/terraform-aws-secrets-manager/commit/323a7b3dfb266d4d63db3877db7dda931b3d1b9c))

## 1.0.0 (2026-03-07)


### ⚠ BREAKING CHANGES

* First publish - Secrets Manager Terraform module

### Features

* First publish - Secrets Manager Terraform module ([48377e5](https://github.com/islamelkadi/terraform-aws-secrets-manager/commit/48377e51c561ce4d1f2a3c1eaefea45e52411353))
