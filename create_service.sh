#!/bin/bash

# ディレクトリ名を取得（デフォルトはnew_dir）
DIR_NAME=${1:-new_dir}
SERVICE_DIR="services/${DIR_NAME}"

# ディレクトリを作成
mkdir -p "${SERVICE_DIR}"

# providers.tfを作成
cat > "${SERVICE_DIR}/providers.tf" << 'EOF'
provider "aws" {
  region = "ap-northeast-1"
}
EOF

# terraform.tfを作成
cat > "${SERVICE_DIR}/terraform.tf" << EOF
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
EOF

# backend.tfを作成
cat > "${SERVICE_DIR}/backend.tf" << EOF
terraform {
  backend "s3" {
    bucket = "arie-terraform-states"
    region = "ap-northeast-1"
    key    = "${DIR_NAME}/terraform.tfstate"
  }
}
EOF

# locals.tfを作成
cat > "${SERVICE_DIR}/locals.tf" << 'EOF'
locals {
  # ローカル値をここに定義
}
EOF

# variables.tfを作成
cat > "${SERVICE_DIR}/variables.tf" << 'EOF'
# 変数をアルファベット順に定義
EOF

echo "Created service directory: ${SERVICE_DIR}"
echo "Files created:"
echo "  - providers.tf"
echo "  - terraform.tf"
echo "  - backend.tf"
echo "  - locals.tf"
echo "  - variables.tf"

