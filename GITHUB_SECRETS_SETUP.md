# GitHub Secrets設定ガイド

## 必要なGitHub Secrets

### 開発環境用
- **`AWS_ROLE_ARN_DEV`**: 開発環境用のIAMロールARN
  - 例: `arn:aws:iam::123456789012:role/LambdaFramework-github-actions-role-dev`

### 本番環境用
- **`AWS_ROLE_ARN_PROD`**: 本番環境用のIAMロールARN
  - 例: `arn:aws:iam::987654321098:role/LambdaFramework-github-actions-role-prod`

## 設定手順

### 1. GitHub Secretsの設定

1. GitHubリポジトリの **Settings** → **Secrets and variables** → **Actions** に移動
2. **New repository secret** をクリック
3. 以下のSecretsを追加:

```
Name: AWS_ROLE_ARN_DEV
Value: arn:aws:iam::<DEV_ACCOUNT_ID>:role/<DEV_ROLE_NAME>

Name: AWS_ROLE_ARN_PROD
Value: arn:aws:iam::<PROD_ACCOUNT_ID>:role/<PROD_ROLE_NAME>
```

### 2. IAMロールの作成

各AWSアカウントで以下のIAMロールを作成:

#### 開発環境用IAMロール
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudformation:*",
        "lambda:*",
        "s3:*",
        "iam:*",
        "logs:*"
      ],
      "Resource": "*"
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
      "Action": [
        "cloudformation:*",
        "lambda:*",
        "s3:*",
        "iam:*",
        "logs:*"
      ],
      "Resource": "*"
    }
  ]
}
```

### 3. OIDCプロバイダーの設定

各AWSアカウントでGitHub Actions用のOIDCプロバイダーを設定:

```bash
# 開発環境
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1

# 本番環境
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

## デプロイ先の確認

| ブランチ | AWSアカウント | スタック名 | 環境 |
|---------|-------------|-----------|------|
| `main` | 本番アカウント | `lambda-framework-prod` | production |
| `deploy` | 開発アカウント | `lambda-framework-dev` | development |

## ローカルデプロイ

### Bash版
```bash
# 開発環境（デフォルトAWS Profile）
./deploy-env.sh development

# 開発環境（指定AWS Profile）
./deploy-env.sh development dev-profile

# 本番環境（指定AWS Profile）
./deploy-env.sh production prod-profile
```

### PowerShell版
```powershell
# 開発環境（デフォルトAWS Profile）
.\deploy-env.ps1 development

# 開発環境（指定AWS Profile）
.\deploy-env.ps1 development dev-profile

# 本番環境（指定AWS Profile）
.\deploy-env.ps1 production prod-profile
``` 