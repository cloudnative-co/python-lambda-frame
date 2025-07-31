# GitHub Secrets Setup Guide

## 概要
このドキュメントでは、GitHub ActionsでAWS CloudFormationにデプロイするために必要なGitHub SecretsとIAMロールの設定手順を説明します。

## 必要なGitHub Secrets

### 1. AWS_ROLE_ARN_DEV (開発環境用)
- **説明**: 開発環境（deployブランチ）で使用するIAMロールのARN
- **例**: `arn:aws:iam::123456789012:role/LambdaFramework-github-actions-role`

### 2. AWS_ROLE_ARN_PROD (本番環境用)
- **説明**: 本番環境（mainブランチ）で使用するIAMロールのARN
- **例**: `arn:aws:iam::123456789012:role/LambdaFramework-github-actions-role`

## IAMロールとOIDCプロバイダーの設定

### 1. OIDCプロバイダーの作成

#### 開発環境用AWSアカウント
```bash
# OIDCプロバイダーの作成
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1

# 作成されたOIDCプロバイダーのARNを確認
aws iam list-open-id-connect-providers
```

#### 本番環境用AWSアカウント
```bash
# OIDCプロバイダーの作成
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1

# 作成されたOIDCプロバイダーのARNを確認
aws iam list-open-id-connect-providers
```

### 2. IAMロールの作成

#### 開発環境用IAMロール
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR_DEV_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub": "repo:cloudnative-co/python-lambda-frame:ref:refs/heads/deploy"
        }
      }
    }
  ]
}
```

#### 本番環境用IAMロール
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR_PROD_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub": "repo:cloudnative-co/python-lambda-frame:ref:refs/heads/main"
        }
      }
    }
  ]
}
```

### 3. IAMポリシーの作成

#### 開発環境用IAMポリシー
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudformation:*",
        "s3:*",
        "lambda:*",
        "iam:*",
        "logs:*"
      ],
      "Resource": "*"
    }
  ]
}
```

#### 本番環境用IAMポリシー
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudformation:*",
        "s3:*",
        "lambda:*",
        "iam:*",
        "logs:*"
      ],
      "Resource": "*"
    }
  ]
}
```

## トラブルシューティング

### 1. "Request ARN is invalid" エラーの解決

#### A. OIDCプロバイダーの確認
```bash
# OIDCプロバイダーが存在するか確認
aws iam list-open-id-connect-providers

# 特定のOIDCプロバイダーの詳細を確認
aws iam get-open-id-connect-provider --open-id-connect-provider-arn arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com
```

#### B. IAMロールの信頼関係の確認
```bash
# IAMロールの詳細を確認
aws iam get-role --role-name LambdaFramework-github-actions-role

# 信頼関係（Trust Policy）を確認
aws iam get-role-policy --role-name LambdaFramework-github-actions-role --policy-name trust-policy
```

#### C. 正しいロールARNの確認
```bash
# 利用可能なIAMロールを一覧表示
aws iam list-roles --query 'Roles[?contains(RoleName, `LambdaFramework`)].RoleName' --output table
```

### 2. よくある問題と解決方法

#### A. OIDCプロバイダーが存在しない
```bash
# OIDCプロバイダーを作成
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

#### B. 信頼関係が正しくない
- IAMロールの信頼関係で、正しいOIDCプロバイダーARNを指定
- 正しいリポジトリ名とブランチ名を指定

#### C. GitHub Secretsが設定されていない
- GitHubリポジトリのSettings → Secrets and variables → Actions
- `AWS_ROLE_ARN_DEV`と`AWS_ROLE_ARN_PROD`を設定

## 設定手順

### 1. AWS CLIでOIDCプロバイダーを作成
```bash
# 開発環境用
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1

# 本番環境用
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

### 2. IAMロールを作成
```bash
# 開発環境用ロール
aws iam create-role --role-name LambdaFramework-github-actions-role --assume-role-policy-document file://trust-policy-dev.json

# 本番環境用ロール
aws iam create-role --role-name LambdaFramework-github-actions-role --assume-role-policy-document file://trust-policy-prod.json
```

### 3. IAMポリシーをアタッチ
```bash
# 開発環境用ポリシー
aws iam put-role-policy --role-name LambdaFramework-github-actions-role --policy-name LambdaFramework-github-actions-policy --policy-document file://policy-dev.json

# 本番環境用ポリシー
aws iam put-role-policy --role-name LambdaFramework-github-actions-role --policy-name LambdaFramework-github-actions-policy --policy-document file://policy-prod.json
```

### 4. GitHub Secretsを設定
1. GitHubリポジトリにアクセス
2. Settings → Secrets and variables → Actions
3. New repository secretをクリック
4. `AWS_ROLE_ARN_DEV`と`AWS_ROLE_ARN_PROD`を設定

## デプロイ環境マッピング

| ブランチ | 環境 | AWSロール | GitHub Secret |
|---------|------|-----------|---------------|
| main | production | LambdaFramework-github-actions-role | AWS_ROLE_ARN_PROD |
| deploy | development | LambdaFramework-github-actions-role | AWS_ROLE_ARN_DEV |

## ローカルデプロイコマンド

### 開発環境
```bash
./deploy-env.sh development
```

### 本番環境
```bash
./deploy-env.sh production
```

### PowerShell版
```powershell
.\deploy-env.ps1 development
.\deploy-env.ps1 production
``` 