# 環境別デプロイスクリプト (PowerShell)
# 使用方法: .\deploy-env.ps1 [development|production] [aws-profile]

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("development", "production")]
    [string]$Environment = "development",
    
    [Parameter(Mandatory=$false)]
    [string]$AwsProfile = ""
)

# 色付きメッセージ関数
function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# 環境の確認
Write-Info "環境: $Environment"
if ($AwsProfile) {
    Write-Info "AWS Profile: $AwsProfile"
    $env:AWS_PROFILE = $AwsProfile
}

# スタック名の設定
if ($Environment -eq "production") {
    $StackName = "lambda-framework-prod"
    Write-Info "本番環境にデプロイします"
} else {
    $StackName = "lambda-framework-dev"
    Write-Info "開発環境にデプロイします"
}

Write-Info "スタック名: $StackName"

# SAMビルド
Write-Info "SAMビルドを実行中..."
try {
    sam build
    if ($LASTEXITCODE -eq 0) {
        Write-Success "SAMビルドが完了しました"
    } else {
        throw "SAMビルドに失敗しました"
    }
} catch {
    Write-Error "SAMビルド中にエラーが発生しました: $_"
    exit 1
}

# SAMデプロイ
Write-Info "SAMデプロイを実行中..."
try {
    if ($AwsProfile) {
        sam deploy `
            --config-env $Environment `
            --stack-name $StackName `
            --no-confirm-changeset `
            --no-fail-on-empty-changeset `
            --parameter-overrides "Environment=$Environment" `
            --profile $AwsProfile
    } else {
        sam deploy `
            --config-env $Environment `
            --stack-name $StackName `
            --no-confirm-changeset `
            --no-fail-on-empty-changeset `
            --parameter-overrides "Environment=$Environment"
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "デプロイが完了しました！"
        Write-Info "スタック名: $StackName"
        Write-Info "環境: $Environment"
    } else {
        throw "SAMデプロイに失敗しました"
    }
} catch {
    Write-Error "SAMデプロイ中にエラーが発生しました: $_"
    exit 1
} 