# PowerShellスクリプト: AWS CLIとSAM CLIのアクセス確認、GitHubユーザー情報取得、OIDC用IAMロール作成、GitHub Secrets自動登録

# 色付き出力用の関数
function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

# 1. AWS CLIの確認
Write-Info "AWS CLIの確認中..."
try {
    $awsVersion = aws --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Success "AWS CLIが見つかりました: $awsVersion"
    } else {
        throw "AWS CLIが見つかりません"
    }
} catch {
    Write-Error "AWS CLIがインストールされていません"
    exit 1
}

# 2. SAM CLIの確認
Write-Info "SAM CLIの確認中..."
$SAM_CMD = $null

# Windows環境でのSAM CLI確認
Write-Info "Windows環境を検出しました"
try {
    # sam.cmdを優先して確認
    Write-Info "sam.cmdの確認中..."
    if (Get-Command sam.cmd -ErrorAction SilentlyContinue) {
        try {
            $samVersion = sam.cmd --version 2>$null
            if ($LASTEXITCODE -eq 0) {
                $SAM_CMD = "sam.cmd"
                Write-Success "SAM CLIが見つかりました: sam.cmd ($samVersion)"
            } else {
                Write-Info "sam.cmdは存在しますが実行できません"
            }
        } catch {
            Write-Info "sam.cmdの実行中にエラーが発生しました: $_"
        }
    } else {
        Write-Info "sam.cmdが見つかりません"
    }
    
    # sam.exeを確認
    if (-not $SAM_CMD) {
        Write-Info "sam.exeの確認中..."
        if (Get-Command sam.exe -ErrorAction SilentlyContinue) {
            try {
                $samVersion = sam.exe --version 2>$null
                if ($LASTEXITCODE -eq 0) {
                    $SAM_CMD = "sam.exe"
                    Write-Success "SAM CLIが見つかりました: sam.exe ($samVersion)"
                } else {
                    Write-Info "sam.exeは存在しますが実行できません"
                }
            } catch {
                Write-Info "sam.exeの実行中にエラーが発生しました: $_"
            }
        } else {
            Write-Info "sam.exeが見つかりません"
        }
    }
    
    # 通常のsamコマンドを確認
    if (-not $SAM_CMD) {
        Write-Info "samの確認中..."
        if (Get-Command sam -ErrorAction SilentlyContinue) {
            try {
                $samVersion = sam --version 2>$null
                if ($LASTEXITCODE -eq 0) {
                    $SAM_CMD = "sam"
                    Write-Success "SAM CLIが見つかりました: sam ($samVersion)"
                } else {
                    Write-Info "samは存在しますが実行できません"
                }
            } catch {
                Write-Info "samの実行中にエラーが発生しました: $_"
            }
        } else {
            Write-Info "samが見つかりません"
        }
    }
    
    if (-not $SAM_CMD) {
        throw "SAM CLIが見つかりません"

    }
} catch {
    Write-Warning "SAM CLIがインストールされていません"
    $response = Read-Host "SAM CLIをインストールしますか？ (y/N)"
    if ($response -eq "y" -or $response -eq "Y") {
        Write-Info "SAM CLIのインストール中..."
        
        # Windows用のインストール方法
        Write-Info "Windows環境でSAM CLIをインストール中..."
        
        $INSTALL_SUCCESS = $false
        
        # 方法1: wingetを使用
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            Write-Info "wingetを使用してインストールを試行中..."
            try {
                $result = winget install Amazon.AWSSAMCLI --accept-source-agreements --accept-package-agreements 2>&1
                if ($LASTEXITCODE -eq 0) {
                    $INSTALL_SUCCESS = $true
                    Write-Success "wingetでSAM CLIのインストールに成功しました"
                } else {
                    Write-Warning "wingetでのインストールに失敗しました: $result"
                }
            } catch {
                Write-Warning "wingetでのインストール中にエラーが発生しました: $_"
            }
        } else {
            Write-Info "wingetが見つかりません"
        }
        

        
        # 方法3: Scoopを使用
        if (-not $INSTALL_SUCCESS -and (Get-Command scoop -ErrorAction SilentlyContinue)) {
            Write-Info "Scoopを使用してインストールを試行中..."
            try {
                $result = scoop install aws-sam-cli 2>&1
                if ($LASTEXITCODE -eq 0) {
                    $INSTALL_SUCCESS = $true
                    Write-Success "ScoopでSAM CLIのインストールに成功しました"
                } else {
                    Write-Warning "Scoopでのインストールに失敗しました: $result"
                }
            } catch {
                Write-Warning "Scoopでのインストール中にエラーが発生しました: $_"
            }
        } else {
            Write-Info "Scoopが見つかりません"
        }
        
        # 方法4: 直接ダウンロード
        if (-not $INSTALL_SUCCESS) {
            Write-Info "直接ダウンロードでインストールを試行中..."
            try {
                # 最新バージョンを取得
                $latestVersion = Invoke-RestMethod -Uri "https://api.github.com/repos/aws/aws-sam-cli/releases/latest" | Select-Object -ExpandProperty tag_name
                $version = $latestVersion.TrimStart('v')
                
                # ダウンロードURL
                $downloadUrl = "https://github.com/aws/aws-sam-cli/releases/download/$latestVersion/AWS_SAM_CLI_64_PY3.msi"
                $installerPath = "$env:TEMP\AWS_SAM_CLI_64_PY3.msi"
                
                Write-Info "SAM CLI v$version をダウンロード中..."
                Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath
                
                Write-Info "インストーラーを実行中..."
                Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$installerPath`" /quiet" -Wait
                
                # インストール確認
                Start-Sleep -Seconds 3
                if (Get-Command sam -ErrorAction SilentlyContinue) {
                    $INSTALL_SUCCESS = $true
                    Write-Success "直接ダウンロードでSAM CLIのインストールに成功しました"
                } else {
                    Write-Warning "直接ダウンロードでのインストールに失敗しました"
                }
                
                # 一時ファイルを削除
                if (Test-Path $installerPath) {
                    Remove-Item $installerPath -Force -ErrorAction SilentlyContinue
                }
            } catch {
                Write-Warning "直接ダウンロードでのインストール中にエラーが発生しました: $_"
            }
        }
        
        if (-not $INSTALL_SUCCESS) {
            Write-Error "すべてのインストール方法が失敗しました"
            Write-Info "手動でSAM CLIをインストールしてください: https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html"
            exit 1
        }
        
        # インストール確認
        Write-Info "インストール確認中..."
        Start-Sleep -Seconds 3
        
        # PATHを再読み込み
        $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")
        
        # Windows環境でのSAM CLI確認
        Write-Info "インストール後のSAM CLI確認中..."
        $samFound = $false
        
        # sam.exeを確認
        Write-Info "sam.exeの確認中..."
        if (Get-Command sam.exe -ErrorAction SilentlyContinue) {
            try {
                $version = sam.exe --version 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "SAM CLIがインストールされました: sam.exe ($version)"
                    $samFound = $true
                } else {
                    Write-Info "sam.exeは存在しますが実行できません"
                }
            } catch {
                Write-Info "sam.exeの実行中にエラーが発生しました: $_"
            }
        } else {
            Write-Info "sam.exeが見つかりません"
        }
        
        # sam.cmdを確認
        if (-not $samFound) {
            Write-Info "sam.cmdの確認中..."
            if (Get-Command sam.cmd -ErrorAction SilentlyContinue) {
                try {
                    $version = sam.cmd --version 2>&1
                    if ($LASTEXITCODE -eq 0) {
                        Write-Success "SAM CLIがインストールされました: sam.cmd ($version)"
                        $samFound = $true
                    } else {
                        Write-Info "sam.cmdは存在しますが実行できません"
                    }
                } catch {
                    Write-Info "sam.cmdの実行中にエラーが発生しました: $_"
                }
            } else {
                Write-Info "sam.cmdが見つかりません"
            }
        }
        
        # 通常のsamコマンドを確認
        if (-not $samFound) {
            Write-Info "samの確認中..."
            if (Get-Command sam -ErrorAction SilentlyContinue) {
                try {
                    $version = sam --version 2>&1
                    if ($LASTEXITCODE -eq 0) {
                        Write-Success "SAM CLIがインストールされました: sam ($version)"
                        $samFound = $true
                    } else {
                        Write-Info "samは存在しますが実行できません"
                    }
                } catch {
                    Write-Info "samの実行中にエラーが発生しました: $_"
                }
            } else {
                Write-Info "samが見つかりません"
            }
        }
        
        if (-not $samFound) {
            Write-Error "SAM CLIのインストール確認に失敗しました"
            Write-Info "手動でインストールしてください: https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html"
            exit 1
        }
    } else {
        Write-Error "SAM CLIのインストールをスキップしました。手動でインストールしてください"
        exit 1
    }
}

# 3. GitHub CLIの確認
Write-Info "GitHub CLIの確認中..."
$GITHUB_CLI_FOUND = $false

# 複数の方法でGitHub CLIを検索
try {
    $ghVersion = gh --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Success "GitHub CLIがインストールされています: $ghVersion"
        $GITHUB_CLI_FOUND = $true
    }
} catch {
    # エラーが発生した場合は無視して続行
}

# Windows環境での追加検索
if (-not $GITHUB_CLI_FOUND) {
    # Windows Git Bashでの検索
    $ghPaths = @(
        "C:\Program Files\GitHub CLI\gh.exe",
        "$env:USERPROFILE\AppData\Local\Microsoft\WinGet\Packages\GitHub.cli_Microsoft.Winget.Source_8wekyb3d8bbwe\LocalState\links\gh.exe",
        "$env:USERPROFILE\AppData\Local\GitHubCLI\gh.exe",
        "$env:USERPROFILE\scoop\apps\gh\current\gh.exe"
    )
    
    foreach ($path in $ghPaths) {
        if (Test-Path $path) {
            try {
                $ghVersion = & $path --version 2>$null
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "GitHub CLIがインストールされています: $ghVersion"
                    Write-Info "パス: $path"
                    $GITHUB_CLI_FOUND = $true
                    # PATHに追加
                    $env:PATH = "$(Split-Path $path);$env:PATH"
                    break
                }
            } catch {
                # エラーが発生した場合は無視して続行
            }
        }
    }
    
    # wingetでインストールされた場合の確認
    if (-not $GITHUB_CLI_FOUND -and (Get-Command winget -ErrorAction SilentlyContinue)) {
        try {
            $wingetGh = winget list GitHub.cli 2>$null | Select-String -Pattern "GitHub.cli"
            if ($wingetGh) {
                Write-Info "wingetでGitHub CLIがインストールされていることを確認しました"
                # パスを再検索
                foreach ($path in $ghPaths) {
                    if (Test-Path $path) {
                        try {
                            $ghVersion = & $path --version 2>$null
                            if ($LASTEXITCODE -eq 0) {
                                Write-Success "GitHub CLIがインストールされています: $ghVersion"
                                Write-Info "パス: $path"
                                $GITHUB_CLI_FOUND = $true
                                $env:PATH = "$(Split-Path $path);$env:PATH"
                                break
                            }
                        } catch {
                            # エラーが発生した場合は無視して続行
                        }
                    }
                }
            }
        } catch {
            # エラーが発生した場合は無視して続行
        }
    }
    
    # Scoopでインストールされた場合の確認
    if (-not $GITHUB_CLI_FOUND -and (Get-Command scoop -ErrorAction SilentlyContinue)) {
        try {
            $scoopGh = scoop list 2>$null | Select-String -Pattern "gh"
            if ($scoopGh) {
                Write-Info "scoopでGitHub CLIがインストールされていることを確認しました"
                $scoopPath = "$env:USERPROFILE\scoop\apps\gh\current\gh.exe"
                if (Test-Path $scoopPath) {
                    try {
                        $ghVersion = & $scoopPath --version 2>$null
                        if ($LASTEXITCODE -eq 0) {
                            Write-Success "GitHub CLIがインストールされています: $ghVersion"
                            Write-Info "パス: $scoopPath"
                            $GITHUB_CLI_FOUND = $true
                            $env:PATH = "$(Split-Path $scoopPath);$env:PATH"
                        }
                    } catch {
                        # エラーが発生した場合は無視して続行
                    }
                }
            }
        } catch {
            # エラーが発生した場合は無視して続行
        }
    }
}

if (-not $GITHUB_CLI_FOUND) {
    Write-Warning "GitHub CLIがインストールされていません"
    $response = Read-Host "GitHub CLIをインストールしますか？ (y/N)"
    if ($response -eq "y" -or $response -eq "Y") {
        $GITHUB_CLI_AVAILABLE = $false
        Write-Info "GitHub CLIのインストール中..."
        
        # Windows用のインストール方法
        Write-Info "Windows環境でGitHub CLIをインストール中..."
        
        $INSTALL_SUCCESS = $false
        
        # 方法1: wingetを使用
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            Write-Info "wingetを使用してインストールを試行中..."
            try {
                $result = winget install GitHub.cli --accept-source-agreements --accept-package-agreements 2>&1
                if ($LASTEXITCODE -eq 0) {
                    $INSTALL_SUCCESS = $true
                    Write-Success "wingetでGitHub CLIのインストールに成功しました"
                } else {
                    Write-Warning "wingetでのインストールに失敗しました: $result"
                }
            } catch {
                Write-Warning "wingetでのインストール中にエラーが発生しました: $_"
            }
        } else {
            Write-Info "wingetが見つかりません"
        }
        

        
        # 方法3: Scoopを使用
        if (-not $INSTALL_SUCCESS -and (Get-Command scoop -ErrorAction SilentlyContinue)) {
            Write-Info "Scoopを使用してインストールを試行中..."
            try {
                $result = scoop install gh 2>&1
                if ($LASTEXITCODE -eq 0) {
                    $INSTALL_SUCCESS = $true
                    Write-Success "ScoopでGitHub CLIのインストールに成功しました"
                } else {
                    Write-Warning "Scoopでのインストールに失敗しました: $result"
                }
            } catch {
                Write-Warning "Scoopでのインストール中にエラーが発生しました: $_"
            }
        } else {
            Write-Info "Scoopが見つからないか、既にインストール済みです"
        }
        
        # 方法4: 直接ダウンロード
        if (-not $INSTALL_SUCCESS) {
            Write-Info "直接ダウンロードでインストールを試行中..."
            try {
                # アーキテクチャ判定
                $ARCH = if ([Environment]::Is64BitOperatingSystem) { "amd64" } else { "386" }
                Write-Info "アーキテクチャ: $ARCH"
                
                # 最新バージョンの取得
                $LATEST_VERSION = (Invoke-RestMethod -Uri "https://api.github.com/repos/cli/cli/releases/latest" -UseBasicParsing).tag_name
                $LATEST_VERSION = $LATEST_VERSION.TrimStart('v')
                Write-Info "最新バージョン: $LATEST_VERSION"
                
                $DOWNLOAD_URL = "https://github.com/cli/cli/releases/download/v${LATEST_VERSION}/gh_${LATEST_VERSION}_windows_${ARCH}.zip"
                $TEMP_DIR = "$env:TEMP\gh-install"
                $ZIP_FILE = "$TEMP_DIR\gh.zip"
                $INSTALL_DIR = "$env:ProgramFiles\GitHub CLI"
                
                Write-Info "ダウンロードURL: $DOWNLOAD_URL"
                
                # 一時ディレクトリを作成
                if (Test-Path $TEMP_DIR) { 
                    Remove-Item $TEMP_DIR -Recurse -Force -ErrorAction SilentlyContinue 
                }
                New-Item -ItemType Directory -Path $TEMP_DIR -Force | Out-Null
                
                # インストールディレクトリを作成
                if (-not (Test-Path $INSTALL_DIR)) {
                    New-Item -ItemType Directory -Path $INSTALL_DIR -Force | Out-Null
                }
                
                # ダウンロード
                Write-Info "ファイルをダウンロード中..."
                Invoke-WebRequest -Uri $DOWNLOAD_URL -OutFile $ZIP_FILE -UseBasicParsing
                
                # 解凍
                Write-Info "ファイルを解凍中..."
                Expand-Archive -Path $ZIP_FILE -DestinationPath $TEMP_DIR -Force
                
                # インストール
                Write-Info "ファイルをインストール中..."
                $GH_BIN = Get-ChildItem -Path $TEMP_DIR -Recurse -Name "gh.exe" | Select-Object -First 1
                if ($GH_BIN) {
                    $GH_PATH = Join-Path $TEMP_DIR $GH_BIN
                    $TARGET_PATH = Join-Path $INSTALL_DIR "gh.exe"
                    
                    Copy-Item -Path $GH_PATH -Destination $TARGET_PATH -Force
                    Write-Info "GitHub CLIを $TARGET_PATH にコピーしました"
                    
                    # PATHに追加
                    $CURRENT_PATH = [Environment]::GetEnvironmentVariable("PATH", "Machine")
                    if ($CURRENT_PATH -notlike "*$INSTALL_DIR*") {
                        $NEW_PATH = "$CURRENT_PATH;$INSTALL_DIR"
                        [Environment]::SetEnvironmentVariable("PATH", $NEW_PATH, "Machine")
                        $env:PATH = "$env:PATH;$INSTALL_DIR"
                        Write-Info "PATH環境変数を更新しました"
                    }
                    
                    $INSTALL_SUCCESS = $true
                    Write-Success "直接ダウンロードでGitHub CLIのインストールに成功しました"
                } else {
                    Write-Error "gh.exeが見つかりませんでした"
                }
                
                # クリーンアップ
                if (Test-Path $TEMP_DIR) {
                    Remove-Item $TEMP_DIR -Recurse -Force -ErrorAction SilentlyContinue
                }
                
            } catch {
                Write-Warning "直接ダウンロードでのインストールに失敗しました: $_"
            }
        }
        
        # インストール確認
        if ($INSTALL_SUCCESS) {
            Write-Info "インストール確認中..."
            Start-Sleep -Seconds 3
            
            # PATHを再読み込み
            $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")
            
            if (Get-Command gh -ErrorAction SilentlyContinue) {
                $version = gh --version 2>&1
                Write-Success "GitHub CLIがインストールされました: $version"
                $GITHUB_CLI_AVAILABLE = $true
            } else {
                Write-Error "GitHub CLIのインストール確認に失敗しました"
                Write-Info "手動でインストールしてください: https://cli.github.com/"
                $GITHUB_CLI_AVAILABLE = $false
            }
        } else {
            Write-Error "すべてのインストール方法が失敗しました"
            Write-Info "手動でGitHub CLIをインストールしてください: https://cli.github.com/"
            $GITHUB_CLI_AVAILABLE = $false
        }
    } else {
        Write-Warning "GitHub CLIのインストールをスキップしました。手動でGitHub Secretsを設定してください"
        $GITHUB_CLI_AVAILABLE = $false
    }
}

# GitHub CLIの利用可能性を最終確認
if ($GITHUB_CLI_FOUND) {
    $GITHUB_CLI_AVAILABLE = $true
    Write-Info "GitHub CLIが利用可能です"
}

# 4. 現在のGitブランチの確認
Write-Info "現在のGitブランチの確認中..."
$CURRENT_BRANCH = git branch --show-current 2>$null
if (-not $CURRENT_BRANCH) {
    $CURRENT_BRANCH = git rev-parse --abbrev-ref HEAD 2>$null
}

if (-not $CURRENT_BRANCH) {
    Write-Warning "Gitブランチを取得できませんでした。手動でブランチを選択してください"
    Write-Host ""
    Write-Host "=== ブランチの選択 ===" -ForegroundColor Cyan
    Write-Host "1. main (本番環境用)"
    Write-Host "2. deploy (開発環境用)"
    Write-Host "3. その他"
    Write-Host ""
    
    do {
        $branchChoice = Read-Host "ブランチを選択してください (1-3)"
    } while ($branchChoice -notmatch '^[1-3]$')
    
    switch ($branchChoice) {
        "1" {
            $CURRENT_BRANCH = "main"
            Write-Info "本番環境用の設定を行います"
        }
        "2" {
            $CURRENT_BRANCH = "deploy"
            Write-Info "開発環境用の設定を行います"
        }
        "3" {
            $CURRENT_BRANCH = Read-Host "ブランチ名を入力してください"
            Write-Info "カスタムブランチ '$CURRENT_BRANCH' の設定を行います"
        }
    }
} else {
    Write-Success "現在のブランチ: $CURRENT_BRANCH"
    
    if ($CURRENT_BRANCH -eq "main") {
        Write-Info "本番環境用の設定を行います"
    } elseif ($CURRENT_BRANCH -eq "deploy") {
        Write-Info "開発環境用の設定を行います"
    } else {
        Write-Info "カスタムブランチ '$CURRENT_BRANCH' の設定を行います"
    }
}

# 環境設定の決定
Write-Info "ブランチ '$CURRENT_BRANCH' に基づいて環境を設定中..."

if ($CURRENT_BRANCH -eq "main") {
    $ENVIRONMENT = "production"
    $STACK_NAME = "lambda-framework-prod"
    $SECRET_NAME = "AWS_ROLE_ARN_PROD"
    Write-Info "mainブランチ → production環境 (本番環境)"
} elseif ($CURRENT_BRANCH -eq "deploy") {
    $ENVIRONMENT = "development"
    $STACK_NAME = "lambda-framework-dev"
    $SECRET_NAME = "AWS_ROLE_ARN_DEV"
    Write-Info "deployブランチ → development環境 (開発環境)"
} else {
    $ENVIRONMENT = "development"
    $STACK_NAME = "lambda-framework-dev"
    $SECRET_NAME = "AWS_ROLE_ARN_DEV"
    Write-Info "カスタムブランチ '$CURRENT_BRANCH' → development環境 (開発環境)"
}

Write-Info "環境: $ENVIRONMENT"
Write-Info "スタック名: $STACK_NAME"
Write-Info "GitHub Secret名: $SECRET_NAME"

# 5. AWS認証情報の確認
Write-Info "AWS認証情報の確認中..."
try {
    $callerIdentity = aws sts get-caller-identity 2>$null | ConvertFrom-Json
    if ($LASTEXITCODE -eq 0) {
        Write-Success "AWS認証情報が設定されています"
        $CURRENT_ACCOUNT = $callerIdentity.Account
        Write-Host "Account: $CURRENT_ACCOUNT"
        Write-Host "User ID: $($callerIdentity.UserId)"
        Write-Host "ARN: $($callerIdentity.Arn)"
        
        # AWSアカウントの選択
        Write-Host ""
        Write-Host "=== AWSアカウントの選択 ===" -ForegroundColor Cyan
        Write-Host "1. 現在のアカウントを使用 ($CURRENT_ACCOUNT)"
        Write-Host "2. 別のAWSアカウントを設定"
        Write-Host ""
        
        do {
            $accountChoice = Read-Host "AWSアカウントを選択してください (1-2)"
        } while ($accountChoice -notmatch '^[1-2]$')
        
        if ($accountChoice -eq "2") {
            Write-Info "別のAWSアカウントを設定します"
            Write-Host ""
            Write-Host "=== AWS認証方法の選択 ===" -ForegroundColor Cyan
            Write-Host "1. AWS CLI configure (アクセスキー/シークレットキー)"
            Write-Host "2. AWS SSO (Single Sign-On)"
            Write-Host "3. AWS IAM Identity Center (旧AWS SSO)"
            Write-Host "4. AWS Profile (既存のプロファイル)"
            Write-Host ""
            
            do {
                $authChoice = Read-Host "認証方法を選択してください (1-4)"
            } while ($authChoice -notmatch '^[1-4]$')
            
            switch ($authChoice) {
                "1" {
                    Write-Info "AWS CLI configureを実行します"
                    Write-Host "アクセスキーID、シークレットアクセスキー、リージョンを入力してください"
                    aws configure
                }
                "2" {
                    Write-Info "AWS SSOを設定します"
                    $ssoStartUrl = Read-Host "SSO Start URLを入力してください (例: https://your-sso-portal.awsapps.com/start)"
                    $ssoRegion = Read-Host "SSO Regionを入力してください (例: us-east-1)"
                    $accountId = Read-Host "AWS Account IDを入力してください"
                    $roleName = Read-Host "SSO Role Nameを入力してください"
                    
                    aws configure sso-session --profile default
                    aws configure sso --profile default --sso-start-url $ssoStartUrl --sso-region $ssoRegion --account-id $accountId --role-name $roleName
                }
                "3" {
                    Write-Info "AWS IAM Identity Centerを設定します"
                    $ssoStartUrl = Read-Host "Identity Center Start URLを入力してください (例: https://your-portal.awsapps.com/start)"
                    $ssoRegion = Read-Host "Identity Center Regionを入力してください (例: us-east-1)"
                    $accountId = Read-Host "AWS Account IDを入力してください"
                    $roleName = Read-Host "Role Nameを入力してください"
                    
                    aws configure sso-session --profile default
                    aws configure sso --profile default --sso-start-url $ssoStartUrl --sso-region $ssoRegion --account-id $accountId --role-name $roleName
                }
                "4" {
                    Write-Info "既存のAWS Profileを選択します"
                    $profiles = aws configure list-profiles 2>$null
                    if ($profiles) {
                        Write-Host "利用可能なプロファイル:"
                        $profileArray = $profiles -split "`n"
                        for ($i = 0; $i -lt $profileArray.Count; $i++) {
                            Write-Host "$($i+1). $($profileArray[$i])"
                        }
                        Write-Host ""
                        $profileChoice = Read-Host "プロファイル番号を選択してください (1-$($profileArray.Count))"
                        if ($profileChoice -match '^\d+$' -and [int]$profileChoice -ge 1 -and [int]$profileChoice -le $profileArray.Count) {
                            $selectedProfile = $profileArray[[int]$profileChoice - 1]
                            $env:AWS_PROFILE = $selectedProfile
                            Write-Success "プロファイル '$selectedProfile' が選択されました"
                        } else {
                            Write-Error "無効な選択です。デフォルトプロファイルを使用します"
                        }
                    } else {
                        Write-Warning "利用可能なプロファイルが見つかりません。AWS CLI configureを実行します"
                        aws configure
                    }
                }
            }
            
            # 認証情報の再確認
            Write-Info "認証情報の確認中..."
            try {
                $newCallerIdentity = aws sts get-caller-identity 2>$null | ConvertFrom-Json
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "AWS認証情報が正常に設定されました"
                    Write-Host "Account: $($newCallerIdentity.Account)"
                    Write-Host "User ID: $($newCallerIdentity.UserId)"
                    Write-Host "ARN: $($newCallerIdentity.Arn)"
                    $callerIdentity = $newCallerIdentity
                } else {
                    throw "AWS認証情報の設定に失敗しました"
                }
            } catch {
                Write-Error "AWS認証情報の設定に失敗しました"
                exit 1
            }
        } else {
            Write-Info "現在のAWSアカウントを使用します"
        }
    } else {
        throw "AWS認証情報が設定されていません"
    }
} catch {
    Write-Warning "AWS認証情報が設定されていません。AWS認証方法を選択してください"
    Write-Host ""
    Write-Host "=== AWS認証方法の選択 ===" -ForegroundColor Cyan
    Write-Host "1. AWS CLI configure (アクセスキー/シークレットキー)"
    Write-Host "2. AWS SSO (Single Sign-On)"
    Write-Host "3. AWS IAM Identity Center (旧AWS SSO)"
    Write-Host "4. AWS Profile (既存のプロファイル)"
    Write-Host ""
    
    do {
        $authChoice = Read-Host "認証方法を選択してください (1-4)"
    } while ($authChoice -notmatch '^[1-4]$')
    
    switch ($authChoice) {
        "1" {
            Write-Info "AWS CLI configureを実行します"
            Write-Host "アクセスキーID、シークレットアクセスキー、リージョンを入力してください"
            aws configure
        }
        "2" {
            Write-Info "AWS SSOを設定します"
            $ssoStartUrl = Read-Host "SSO Start URLを入力してください (例: https://your-sso-portal.awsapps.com/start)"
            $ssoRegion = Read-Host "SSO Regionを入力してください (例: us-east-1)"
            $accountId = Read-Host "AWS Account IDを入力してください"
            $roleName = Read-Host "SSO Role Nameを入力してください"
            
            aws configure sso-session --profile default
            aws configure sso --profile default --sso-start-url $ssoStartUrl --sso-region $ssoRegion --account-id $accountId --role-name $roleName
        }
        "3" {
            Write-Info "AWS IAM Identity Centerを設定します"
            $ssoStartUrl = Read-Host "Identity Center Start URLを入力してください (例: https://your-portal.awsapps.com/start)"
            $ssoRegion = Read-Host "Identity Center Regionを入力してください (例: us-east-1)"
            $accountId = Read-Host "AWS Account IDを入力してください"
            $roleName = Read-Host "Role Nameを入力してください"
            
            aws configure sso-session --profile default
            aws configure sso --profile default --sso-start-url $ssoStartUrl --sso-region $ssoRegion --account-id $accountId --role-name $roleName
        }
        "4" {
            Write-Info "既存のAWS Profileを選択します"
            $profiles = aws configure list-profiles 2>$null
            if ($profiles) {
                Write-Host "利用可能なプロファイル:"
                $profileArray = $profiles -split "`n"
                for ($i = 0; $i -lt $profileArray.Count; $i++) {
                    Write-Host "$($i+1). $($profileArray[$i])"
                }
                Write-Host ""
                $profileChoice = Read-Host "プロファイル番号を選択してください (1-$($profileArray.Count))"
                if ($profileChoice -match '^\d+$' -and [int]$profileChoice -ge 1 -and [int]$profileChoice -le $profileArray.Count) {
                    $selectedProfile = $profileArray[[int]$profileChoice - 1]
                    $env:AWS_PROFILE = $selectedProfile
                    Write-Success "プロファイル '$selectedProfile' が選択されました"
                } else {
                    Write-Error "無効な選択です。デフォルトプロファイルを使用します"
                }
            } else {
                Write-Warning "利用可能なプロファイルが見つかりません。AWS CLI configureを実行します"
                aws configure
            }
        }
    }
    
    # 認証情報の再確認
    Write-Info "認証情報の確認中..."
    $callerIdentity = aws sts get-caller-identity 2>$null | ConvertFrom-Json
    if ($LASTEXITCODE -eq 0) {
        Write-Success "AWS認証情報が正常に設定されました"
        Write-Host "Account: $($callerIdentity.Account)"
        Write-Host "User ID: $($callerIdentity.UserId)"
        Write-Host "ARN: $($callerIdentity.Arn)"
    } else {
        Write-Error "AWS認証情報の設定に失敗しました"
        exit 1
    }
}

# 5. GitHubユーザー情報の取得
Write-Info "GitHubユーザー情報の取得中..."

# GitHub CLIの利用可能性を再確認
$GITHUB_CLI_WORKING = $false
$GITHUB_USERNAME = $null
$GITHUB_REPO_NAME = $null

if ($GITHUB_CLI_AVAILABLE) {
    Write-Info "GitHub CLIの認証状態を確認中..."
    
    # GitHub CLIの認証状態を確認
    try {
        $ghStatus = gh auth status 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Success "GitHub CLIにログイン済みです"
            $GITHUB_CLI_WORKING = $true
        } else {
            Write-Warning "GitHub CLIにログインしていません"
            Write-Host ""
            Write-Host "=== GitHub CLIログイン ===" -ForegroundColor Cyan
            Write-Host "GitHub CLIにログインする必要があります"
            Write-Host "1. ブラウザでログイン"
            Write-Host "2. トークンでログイン"
            Write-Host "3. 手動でユーザー情報を入力"
            Write-Host ""
            
            do {
                $loginChoice = Read-Host "ログイン方法を選択してください (1-3)"
            } while ($loginChoice -notmatch '^[1-3]$')
            
            switch ($loginChoice) {
                "1" {
                    Write-Info "ブラウザでログインを開始します..."
                    try {
                        gh auth login --web
                        if ($LASTEXITCODE -eq 0) {
                            Write-Success "GitHub CLIログインに成功しました"
                            $GITHUB_CLI_WORKING = $true
                        } else {
                            Write-Error "GitHub CLIログインに失敗しました"
                        }
                    } catch {
                        Write-Error "GitHub CLIログインに失敗しました: $_"
                    }
                }
                "2" {
                    Write-Info "トークンでログインします..."
                    $githubToken = Read-Host "GitHub Personal Access Tokenを入力してください"
                    try {
                        $githubToken | gh auth login --with-token
                        if ($LASTEXITCODE -eq 0) {
                            Write-Success "GitHub CLIログインに成功しました"
                            $GITHUB_CLI_WORKING = $true
                        } else {
                            Write-Error "GitHub CLIログインに失敗しました"
                        }
                    } catch {
                        Write-Error "GitHub CLIログインに失敗しました: $_"
                    }
                }
                "3" {
                    Write-Info "手動でユーザー情報を入力します"
                    $GITHUB_CLI_WORKING = $false
                }
            }
        }
    } catch {
        Write-Error "GitHub CLIの認証状態確認に失敗しました: $_"
        $GITHUB_CLI_WORKING = $false
    }
    
    # GitHub CLIが動作する場合、ユーザー情報を取得
    if ($GITHUB_CLI_WORKING) {
        Write-Info "GitHubユーザー情報を取得中..."
        
        # ユーザー情報の取得
        try {
            $userResponse = gh api user 2>$null
            if ($LASTEXITCODE -eq 0 -and $userResponse) {
                $userData = $userResponse | ConvertFrom-Json
                if ($userData.login) {
                    $GITHUB_USERNAME = $userData.login
                    Write-Success "GitHubユーザー名: $GITHUB_USERNAME"
                } else {
                    Write-Error "GitHubユーザー名の取得に失敗しました"
                    $GITHUB_CLI_WORKING = $false
                }
            } else {
                Write-Error "GitHub APIからのユーザー情報取得に失敗しました"
                $GITHUB_CLI_WORKING = $false
            }
        } catch {
            Write-Error "GitHubユーザー情報の取得に失敗しました: $_"
            $GITHUB_CLI_WORKING = $false
        }
        
        # リポジトリ情報の取得
        if ($GITHUB_CLI_WORKING) {
            try {
                $repoUrl = git remote get-url origin 2>$null
                if ($LASTEXITCODE -eq 0 -and $repoUrl) {
                    $GITHUB_REPO_NAME = $repoUrl -replace '.*[:/]([^/]+/[^/]+)\.git$', '$1' -replace '.*/', ''
                    Write-Success "GitHubリポジトリ名: $GITHUB_REPO_NAME"
                } else {
                    Write-Warning "リポジトリ情報の取得に失敗しました。手動で入力してください"
                    $GITHUB_CLI_WORKING = $false
                }
            } catch {
                Write-Warning "リポジトリ情報の取得に失敗しました: $_"
                $GITHUB_CLI_WORKING = $false
            }
        }
    }
}

# GitHub CLIが利用できない場合、手動で入力
if (-not $GITHUB_CLI_WORKING) {
    Write-Warning "GitHub CLIが利用できません。手動でGitHubユーザー名とリポジトリ名を入力してください"
    $GITHUB_USERNAME = Read-Host "GitHubユーザー名を入力してください"
    $GITHUB_REPO_NAME = Read-Host "GitHubリポジトリ名を入力してください"
}

# 6. AWSアカウントIDの取得
Write-Info "AWSアカウントIDの取得中..."
$AWS_ACCOUNT_ID = aws sts get-caller-identity --query Account --output text 2>$null
if (-not $AWS_ACCOUNT_ID -or $AWS_ACCOUNT_ID -eq "None") {
    Write-Error "AWSアカウントIDの取得に失敗しました"
    Write-Info "AWS認証情報を確認してください"
    aws sts get-caller-identity
    exit 1
}
Write-Success "AWSアカウントID: $AWS_ACCOUNT_ID"

# AWSリージョンの確認
Write-Info "AWSリージョンの確認"
$AWS_REGION_INPUT = Read-Host "AWSリージョンを入力してください (デフォルト: ap-northeast-1)"
$AWS_REGION = if ($AWS_REGION_INPUT) { $AWS_REGION_INPUT } else { "ap-northeast-1" }
Write-Success "AWSリージョン: $AWS_REGION"

# プロジェクト名の確認
Write-Info "プロジェクト名の確認"
$PROJECT_NAME_INPUT = Read-Host "プロジェクト名を入力してください (デフォルト: LambdaFramework)"
$PROJECT_NAME = if ($PROJECT_NAME_INPUT) { $PROJECT_NAME_INPUT } else { "LambdaFramework" }
Write-Success "プロジェクト名: $PROJECT_NAME"

# S3バケット名の確認
Write-Info "S3バケット名の確認"
$S3_BUCKET_INPUT = Read-Host "S3バケット名を入力してください (デフォルト: cn-seba-aws-sam-cli-managed-default-samclisourcebucket)"
$S3_BUCKET = if ($S3_BUCKET_INPUT) { $S3_BUCKET_INPUT } else { "cn-seba-aws-sam-cli-managed-default-samclisourcebucket" }
Write-Success "S3バケット名: $S3_BUCKET"

# 7. OIDCプロバイダーの選択
Write-Info "OIDCプロバイダーの選択中..."

# 既存のOIDCプロバイダー一覧を取得
Write-Info "既存のOIDCプロバイダーを取得中..."
$OIDC_PROVIDERS = aws iam list-open-id-connect-providers --query 'OpenIDConnectProviderList[].Arn' --output text 2>$null

# GitHub Actions用のOIDCプロバイダーARN
$GITHUB_OIDC_ARN = "arn:aws:iam:$($AWS_ACCOUNT_ID):oidc-provider/token.actions.githubusercontent.com"

# 選択肢を準備
Write-Host ""
Write-Host "=== 利用可能なOIDCプロバイダー ===" -ForegroundColor Cyan
Write-Host "0. 新規作成: GitHub Actions用OIDCプロバイダー"
Write-Host "   ($GITHUB_OIDC_ARN)"

# 既存のプロバイダーを表示
if ($OIDC_PROVIDERS) {
    $PROVIDER_ARRAY = $OIDC_PROVIDERS -split "`t"
    for ($i = 0; $i -lt $PROVIDER_ARRAY.Count; $i++) {
        $PROVIDER_ARN = $PROVIDER_ARRAY[$i]
        $PROVIDER_URL = aws iam get-open-id-connect-provider --open-id-connect-provider-arn $PROVIDER_ARN --query 'Url' --output text 2>$null
        Write-Host "$($i+1). $PROVIDER_ARN"
        Write-Host "   URL: $PROVIDER_URL"
    }
} else {
    Write-Host "既存のOIDCプロバイダーが見つかりません"
}

Write-Host ""
$OIDC_CHOICE = Read-Host "OIDCプロバイダーを選択してください (0-$($PROVIDER_ARRAY.Count))"

# 選択に基づいてOIDCプロバイダーARNを設定
if ($OIDC_CHOICE -eq "0") {
    Write-Info "新規OIDCプロバイダーを作成中..."
    $OIDC_PROVIDER_ARN = $GITHUB_OIDC_ARN
    
    # OIDCプロバイダーが既に存在するかチェック
    try {
        aws iam get-open-id-connect-provider --open-id-connect-provider-arn $OIDC_PROVIDER_ARN 2>$null | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Success "OIDCプロバイダーは既に存在します"
        } else {
            throw "OIDCプロバイダーが存在しません"
        }
    } catch {
        aws iam create-open-id-connect-provider `
            --url https://token.actions.githubusercontent.com `
            --client-id-list sts.amazonaws.com `
            --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Success "OIDCプロバイダーが作成されました"
        } else {
            Write-Error "OIDCプロバイダーの作成に失敗しました"
            exit 1
        }
    }
} else {
    # 既存のプロバイダーを選択
    if ($OIDC_PROVIDERS -and [int]$OIDC_CHOICE -ge 1 -and [int]$OIDC_CHOICE -le $PROVIDER_ARRAY.Count) {
        $SELECTED_INDEX = [int]$OIDC_CHOICE - 1
        $OIDC_PROVIDER_ARN = $PROVIDER_ARRAY[$SELECTED_INDEX]
        Write-Success "選択されたOIDCプロバイダー: $OIDC_PROVIDER_ARN"
    } else {
        Write-Error "無効な選択です。デフォルトで新規作成します"
        $OIDC_PROVIDER_ARN = $GITHUB_OIDC_ARN
        
        try {
            aws iam get-open-id-connect-provider --open-id-connect-provider-arn $OIDC_PROVIDER_ARN 2>$null | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-Success "OIDCプロバイダーは既に存在します"
            } else {
                throw "OIDCプロバイダーが存在しません"
            }
        } catch {
            aws iam create-open-id-connect-provider `
                --url https://token.actions.githubusercontent.com `
                --client-id-list sts.amazonaws.com `
                --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Success "OIDCプロバイダーが作成されました"
            } else {
                Write-Error "OIDCプロバイダーの作成に失敗しました"
                exit 1
            }
        }
    }
}

# 8. IAMロールの作成
Write-Info "IAMロールの作成について確認します"
$DEFAULT_ROLE_NAME = "$PROJECT_NAME-github-actions-role"
$ROLE_NAME_INPUT = Read-Host "IAMロール名を入力してください (デフォルト: $DEFAULT_ROLE_NAME)"
$ROLE_NAME = if ($ROLE_NAME_INPUT) { $ROLE_NAME_INPUT } else { $DEFAULT_ROLE_NAME }
Write-Info "IAMロールの作成中... ($ROLE_NAME)"

$TRUST_POLICY = @"
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "$OIDC_PROVIDER_ARN"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
                    "token.actions.githubusercontent.com:sub": "repo:$GITHUB_USERNAME/$GITHUB_REPO_NAME:ref:refs/heads/deploy"
                }
            }
        }
    ]
}
"@

# ロールが存在するかチェック
try {
    $result = aws iam get-role --role-name $ROLE_NAME 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Success "IAMロールは既に存在します: $ROLE_NAME"
    } else {
        throw "IAMロールが存在しません"
    }
} catch {
    Write-Info "IAMロールを作成中..."
    
    # 一時ファイルを作成してポリシードキュメントを保存
    $TEMP_POLICY_FILE = "$env:TEMP\trust-policy.json"
    $TRUST_POLICY | Out-File -FilePath $TEMP_POLICY_FILE -Encoding UTF8
    
    try {
        $result = aws iam create-role --role-name $ROLE_NAME --assume-role-policy-document file://$TEMP_POLICY_FILE 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "IAMロールが作成されました: $ROLE_NAME"
        } else {
            Write-Error "IAMロールの作成に失敗しました: $result"
            exit 1
        }
    } finally {
        # 一時ファイルを削除
        if (Test-Path $TEMP_POLICY_FILE) {
            Remove-Item $TEMP_POLICY_FILE -Force -ErrorAction SilentlyContinue
        }
    }
}

# 9. ポリシーの作成とアタッチ
Write-Info "IAMポリシーの作成について確認します"
$DEFAULT_POLICY_NAME = "$PROJECT_NAME-github-actions-policy"
$POLICY_NAME_INPUT = Read-Host "IAMポリシー名を入力してください (デフォルト: $DEFAULT_POLICY_NAME)"
$POLICY_NAME = if ($POLICY_NAME_INPUT) { $POLICY_NAME_INPUT } else { $DEFAULT_POLICY_NAME }
Write-Info "IAMポリシーの作成中... ($POLICY_NAME)"

$POLICY_DOCUMENT = @"
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
"@

# ポリシーが存在するかチェック
Write-Info "IAMポリシーの存在を確認中: $POLICY_NAME"
$policyExists = $false

# より確実な存在確認方法
$checkResult = aws iam list-policies --scope Local --query "Policies[?PolicyName=='$POLICY_NAME'].Arn" --output text 2>&1
if ($LASTEXITCODE -eq 0 -and $checkResult -and $checkResult -ne "None") {
    Write-Success "IAMポリシーは既に存在します: $POLICY_NAME"
    $policyExists = $true
} else {
    Write-Info "IAMポリシーが見つかりません。作成を試行します..."
}

if (-not $policyExists) {
    Write-Info "IAMポリシーを作成中..."
    
    # 一時ファイルを作成してポリシードキュメントを保存
    $TEMP_POLICY_FILE = "$env:TEMP\policy-document.json"
    $POLICY_DOCUMENT | Out-File -FilePath $TEMP_POLICY_FILE -Encoding UTF8
    
    try {
        $result = aws iam create-policy --policy-name $POLICY_NAME --policy-document file://$TEMP_POLICY_FILE 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "IAMポリシーが作成されました: $POLICY_NAME"
        } else {
            # 作成に失敗した場合、既に存在する可能性があるので再確認
            $recheckResult = aws iam list-policies --scope Local --query "Policies[?PolicyName=='$POLICY_NAME'].Arn" --output text 2>&1
            if ($LASTEXITCODE -eq 0 -and $recheckResult -and $recheckResult -ne "None") {
                Write-Success "IAMポリシーは既に存在します: $POLICY_NAME"
            } else {
                Write-Error "IAMポリシーの作成に失敗しました: $result"
                exit 1
            }
        }
    } finally {
        # 一時ファイルを削除
        if (Test-Path $TEMP_POLICY_FILE) {
            Remove-Item $TEMP_POLICY_FILE -Force -ErrorAction SilentlyContinue
        }
    }
}

# ポリシーをロールにアタッチ
Write-Info "ポリシーをロールにアタッチ中..."
aws iam attach-role-policy --role-name $ROLE_NAME --policy-arn "arn:aws:iam:$AWS_ACCOUNT_ID:policy/$POLICY_NAME" 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Success "ポリシーがロールにアタッチされました"
} else {
    Write-Warning "ポリシーのアタッチに失敗しました（既にアタッチされている可能性があります）"
}

# 10. GitHub Secretsの自動登録
if ($GITHUB_CLI_AVAILABLE) {
    Write-Info "GitHub Secretsの自動登録について確認します"
    
    # GitHub CLIの認証状況を確認
    Write-Info "GitHub CLIの認証状況を確認中..."
    $authStatus = gh auth status 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "GitHub CLIにログインしていません。ログインしてください"
        gh auth login
        $authStatus = gh auth status 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Error "GitHub CLIの認証に失敗しました"
            $GITHUB_CLI_AVAILABLE = $false
        }
    }
    
    if ($GITHUB_CLI_AVAILABLE) {
        $response = Read-Host "GitHub Secretsを自動登録しますか？ (y/N)"
        if ($response -eq "y" -or $response -eq "Y") {
            Write-Info "GitHub Secretsの自動登録中..."
            
            # 現在のリポジトリを確認
            Write-Info "現在のリポジトリを確認中..."
            $currentRepo = (gh repo view --json nameWithOwner 2>&1 | ConvertFrom-Json).nameWithOwner
            if ($LASTEXITCODE -eq 0) {
                Write-Success "リポジトリ: $currentRepo"
            } else {
                Write-Warning "リポジトリの確認に失敗しました: $currentRepo"
            }
            
            # Repository Secretsの登録（機密情報）
            Write-Info "=== Repository Secretsの登録 ==="
            
            # 環境別AWS_ROLE_ARNの登録
            Write-Info "AWSアカウントID: $AWS_ACCOUNT_ID"
            Write-Info "IAMロール名: $ROLE_NAME"
            
            # PowerShellの文字列展開を確実にする
            $AWS_ROLE_ARN = "arn:aws:iam:$($AWS_ACCOUNT_ID):role/$($ROLE_NAME)"
            Write-Info "生成されるARN: $AWS_ROLE_ARN"
            Write-Info "$SECRET_NAMEをRepository Secretsに登録中: $AWS_ROLE_ARN"
            $result = gh secret set $SECRET_NAME --body $AWS_ROLE_ARN 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Success "$SECRET_NAME がRepository Secretsに登録されました"
            } else {
                Write-Warning "$SECRET_NAME の登録に失敗しました: $result"
            }
            
            # S3_BUCKETの登録
            Write-Info "S3_BUCKETをRepository Secretsに登録中: $S3_BUCKET"
            $result = gh secret set S3_BUCKET --body $S3_BUCKET 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Success "S3_BUCKET がRepository Secretsに登録されました"
            } else {
                Write-Warning "S3_BUCKET の登録に失敗しました: $result"
            }
            
            # Repository Variablesの登録（非機密情報）
            Write-Info "=== Repository Variablesの登録 ==="
            
            # AWS_REGIONの登録
            Write-Info "AWS_REGIONをRepository Variablesに登録中: $AWS_REGION"
            $result = gh variable set AWS_REGION --body $AWS_REGION 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Success "AWS_REGION がRepository Variablesに登録されました"
            } else {
                Write-Warning "AWS_REGION の登録に失敗しました: $result"
            }
            
            # PROJECT_NAMEの登録
            Write-Info "PROJECT_NAMEをRepository Variablesに登録中: $PROJECT_NAME"
            $result = gh variable set PROJECT_NAME --body $PROJECT_NAME 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Success "PROJECT_NAME がRepository Variablesに登録されました"
            } else {
                Write-Warning "PROJECT_NAME の登録に失敗しました: $result"
            }
        } else {
            Write-Info "GitHub Secretsの自動登録をスキップしました"
        }
    }
} else {
    Write-Warning "GitHub CLIが利用できないため、手動でGitHub Secretsを設定してください"
}

# 11. 結果の表示
Write-Success "設定が完了しました！"
Write-Host ""
Write-Host "=== 設定情報 ===" -ForegroundColor Cyan
Write-Host "AWSアカウントID: $AWS_ACCOUNT_ID"
Write-Host "GitHubユーザー名: $GITHUB_USERNAME"
Write-Host "GitHubリポジトリ名: $GITHUB_REPO_NAME"
Write-Host "IAMロール名: $ROLE_NAME"
Write-Host "IAMロールARN: arn:aws:iam:$($AWS_ACCOUNT_ID):role/$($ROLE_NAME)"
Write-Host ""

if ($GITHUB_CLI_AVAILABLE) {
    Write-Success "GitHub SecretsとVariablesが自動登録されました"
    Write-Host "登録されたRepository Secrets:" -ForegroundColor Yellow
    Write-Host "- $SECRET_NAME"
    Write-Host "- S3_BUCKET"
    Write-Host "登録されたRepository Variables:" -ForegroundColor Yellow
    Write-Host "- AWS_REGION"
    Write-Host "- PROJECT_NAME"
} else {
    Write-Host "手動でGitHubに以下を設定してください:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Repository Secrets:" -ForegroundColor Cyan
    Write-Host "Name: $SECRET_NAME"
    Write-Host "Value: arn:aws:iam:$($AWS_ACCOUNT_ID):role/$($ROLE_NAME)"
    Write-Host "Name: S3_BUCKET"
    Write-Host "Value: $S3_BUCKET"
    Write-Host ""
    Write-Host "Repository Variables:" -ForegroundColor Cyan
    Write-Host "Name: AWS_REGION"
    Write-Host "Value: $AWS_REGION"
    Write-Host "Name: PROJECT_NAME"
    Write-Host "Value: $PROJECT_NAME"
} 