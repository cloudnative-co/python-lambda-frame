#!/bin/bash

# 色付き出力用の関数
print_info() {
    echo -e "\033[34m[INFO]\033[0m $1"
}

print_success() {
    echo -e "\033[32m[SUCCESS]\033[0m $1"
}

print_error() {
    echo -e "\033[31m[ERROR]\033[0m $1"
}

print_warning() {
    echo -e "\033[33m[WARNING]\033[0m $1"
}

# 1. AWS CLIの確認
print_info "AWS CLIの確認中..."
if ! command -v aws &> /dev/null; then
    print_error "AWS CLIがインストールされていません"
    exit 1
fi

print_success "AWS CLIが見つかりました: $(aws --version)"

# 2. SAM CLIの確認
print_info "SAM CLIの確認中..."
SAM_CMD="sam"

# Windows環境でのSAM CLI確認
if [[ "$OSTYPE" == "msys"* ]] || [[ "$OSTYPE" == "cygwin"* ]] || [[ "$(uname)" == "MINGW"* ]] || [[ "$(uname)" == "MSYS"* ]]; then
    print_info "Windows環境を検出しました: $OSTYPE ($(uname))"
    # Windows環境ではsam.cmdを優先して確認
    print_info "sam.cmdの確認中..."
    if command -v sam.cmd &> /dev/null; then
        # 実際にバージョン確認を試行
        if sam.cmd --version &> /dev/null; then
            SAM_CMD="sam.cmd"
            print_success "SAM CLIが見つかりました: sam.cmd ($(sam.cmd --version 2>/dev/null | head -n1))"
        else
            print_info "sam.cmdは存在しますが実行できません"
        fi
    else
        print_info "sam.cmdが見つかりません"
    fi
    
    if [[ -z "$SAM_CMD" ]]; then
        print_info "sam.exeの確認中..."
        if command -v sam.exe &> /dev/null; then
            # 実際にバージョン確認を試行
            if sam.exe --version &> /dev/null; then
                SAM_CMD="sam.exe"
                print_success "SAM CLIが見つかりました: sam.exe ($(sam.exe --version 2>/dev/null | head -n1))"
            else
                print_info "sam.exeは存在しますが実行できません"
            fi
        else
            print_info "sam.exeが見つかりません"
        fi
    fi
    
    if [[ -z "$SAM_CMD" ]]; then
        print_info "samの確認中..."
        if command -v sam &> /dev/null; then
            # 実際にバージョン確認を試行
            if sam --version &> /dev/null; then
                SAM_CMD="sam"
                print_success "SAM CLIが見つかりました: sam ($(sam --version 2>/dev/null | head -n1))"
            else
                print_info "samは存在しますが実行できません"
            fi
        else
            print_info "samが見つかりません"
        fi
    fi
else
    print_info "非Windows環境を検出しました: $OSTYPE"
    # 非Windows環境では通常のsamコマンドを確認
    if command -v sam &> /dev/null; then
        SAM_CMD="sam"
    else
        SAM_CMD=""
    fi
fi

if [[ -z "$SAM_CMD" ]]; then
    print_warning "SAM CLIがインストールされていません"
    read -p "SAM CLIをインストールしますか？ (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "SAM CLIのインストール中..."
        
        # OS判定とインストール
        if [[ "$OSTYPE" == "linux-gnu"* ]] || [[ "$OSTYPE" == "msys"* ]] || [[ "$OSTYPE" == "cygwin"* ]]; then
            # Linux または Windows Git Bash
            if [[ "$OSTYPE" == "msys"* ]] || [[ "$OSTYPE" == "cygwin"* ]]; then
                print_info "Windows Git Bash環境でSAM CLIをインストール中..."
            else
                print_info "Linux環境でSAM CLIをインストール中..."
            fi
            
            INSTALL_SUCCESS=false
            
            # 方法1: pipを使用
            if command -v pip3 &> /dev/null && ! $INSTALL_SUCCESS; then
                print_info "pip3を使用してインストールを試行中..."
                if pip3 install aws-sam-cli >/dev/null 2>&1; then
                    INSTALL_SUCCESS=true
                    print_success "pip3でSAM CLIのインストールに成功しました"
                fi
            fi
            
            # 方法2: apt-get (Debian/Ubuntu)
            if command -v apt-get &> /dev/null && ! $INSTALL_SUCCESS; then
                print_info "apt-getを使用してインストールを試行中..."
                if wget https://github.com/aws/aws-sam-cli/releases/latest/download/install-sam-cli.sh -O /tmp/install-sam-cli.sh 2>/dev/null; then
                    if chmod +x /tmp/install-sam-cli.sh 2>/dev/null; then
                        if sudo /tmp/install-sam-cli.sh >/dev/null 2>&1; then
                            INSTALL_SUCCESS=true
                            print_success "apt-getでSAM CLIのインストールに成功しました"
                        fi
                    fi
                    rm -f /tmp/install-sam-cli.sh
                fi
            fi
            
            # 方法3: yum (RHEL/CentOS)
            if command -v yum &> /dev/null && ! $INSTALL_SUCCESS; then
                print_info "yumを使用してインストールを試行中..."
                if wget https://github.com/aws/aws-sam-cli/releases/latest/download/install-sam-cli.sh -O /tmp/install-sam-cli.sh 2>/dev/null; then
                    if chmod +x /tmp/install-sam-cli.sh 2>/dev/null; then
                        if sudo /tmp/install-sam-cli.sh >/dev/null 2>&1; then
                            INSTALL_SUCCESS=true
                            print_success "yumでSAM CLIのインストールに成功しました"
                        fi
                    fi
                    rm -f /tmp/install-sam-cli.sh
                fi
            fi
            
            # 方法4: pip (Windows Git Bash用)
            if command -v pip3 &> /dev/null && ! $INSTALL_SUCCESS; then
                print_info "pip3を使用してインストールを試行中..."
                if pip3 install aws-sam-cli >/dev/null 2>&1; then
                    INSTALL_SUCCESS=true
                    print_success "pip3でSAM CLIのインストールに成功しました"
                fi
            fi
            
            # 方法5: 直接ダウンロード
            if ! $INSTALL_SUCCESS; then
                print_info "直接ダウンロードでインストールを試行中..."
                ARCH=$(uname -m)
                if [[ "$ARCH" == "x86_64" ]]; then
                    ARCH="x86_64"
                elif [[ "$ARCH" == "aarch64" ]]; then
                    ARCH="arm64"
                fi
                
                # 最新バージョンを取得
                LATEST_VERSION=$(curl -s https://api.github.com/repos/aws/aws-sam-cli/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
                VERSION=${LATEST_VERSION#v}
                
                if curl -L "https://github.com/aws/aws-sam-cli/releases/download/$LATEST_VERSION/aws-sam-cli-linux-$ARCH.zip" -o /tmp/sam-cli.zip 2>/dev/null; then
                    if unzip -q /tmp/sam-cli.zip -d /tmp 2>/dev/null; then
                        # Windows Git Bashの場合はsudoを使わずにコピー
                        if [[ "$OSTYPE" == "msys"* ]] || [[ "$OSTYPE" == "cygwin"* ]]; then
                            if cp /tmp/sam-installation/sam /usr/local/bin/ 2>/dev/null || cp /tmp/sam-installation/sam ~/.local/bin/ 2>/dev/null; then
                                INSTALL_SUCCESS=true
                                print_success "直接ダウンロードでSAM CLIのインストールに成功しました"
                            fi
                        else
                            if sudo cp /tmp/sam-installation/sam /usr/local/bin/ 2>/dev/null; then
                                INSTALL_SUCCESS=true
                                print_success "直接ダウンロードでSAM CLIのインストールに成功しました"
                            fi
                        fi
                    fi
                    rm -f /tmp/sam-cli.zip
                    rm -rf /tmp/sam-installation
                fi
            fi
            
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            print_info "macOS環境でSAM CLIをインストール中..."
            
            INSTALL_SUCCESS=false
            
            # 方法1: Homebrew
            if command -v brew &> /dev/null && ! $INSTALL_SUCCESS; then
                print_info "Homebrewを使用してインストールを試行中..."
                if brew install aws-sam-cli >/dev/null 2>&1; then
                    INSTALL_SUCCESS=true
                    print_success "HomebrewでSAM CLIのインストールに成功しました"
                fi
            fi
            
            # 方法2: pip
            if command -v pip3 &> /dev/null && ! $INSTALL_SUCCESS; then
                print_info "pip3を使用してインストールを試行中..."
                if pip3 install aws-sam-cli >/dev/null 2>&1; then
                    INSTALL_SUCCESS=true
                    print_success "pip3でSAM CLIのインストールに成功しました"
                fi
            fi
            
            # 方法3: 直接ダウンロード
            if ! $INSTALL_SUCCESS; then
                print_info "直接ダウンロードでインストールを試行中..."
                ARCH=$(uname -m)
                if [[ "$ARCH" == "x86_64" ]]; then
                    ARCH="x86_64"
                elif [[ "$ARCH" == "arm64" ]]; then
                    ARCH="arm64"
                fi
                
                # 最新バージョンを取得
                LATEST_VERSION=$(curl -s https://api.github.com/repos/aws/aws-sam-cli/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
                VERSION=${LATEST_VERSION#v}
                
                if curl -L "https://github.com/aws/aws-sam-cli/releases/download/$LATEST_VERSION/aws-sam-cli-mac-$ARCH.zip" -o /tmp/sam-cli.zip 2>/dev/null; then
                    if unzip -q /tmp/sam-cli.zip -d /tmp 2>/dev/null; then
                        if sudo cp /tmp/sam-installation/sam /usr/local/bin/ 2>/dev/null; then
                            INSTALL_SUCCESS=true
                            print_success "直接ダウンロードでSAM CLIのインストールに成功しました"
                        fi
                    fi
                    rm -f /tmp/sam-cli.zip
                    rm -rf /tmp/sam-installation
                fi
            fi
            
        else
            print_error "サポートされていないOSです。手動でSAM CLIをインストールしてください"
            print_info "インストール方法: https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html"
            exit 1
        fi
        
        if ! $INSTALL_SUCCESS; then
            print_error "すべてのインストール方法が失敗しました"
            print_info "手動でSAM CLIをインストールしてください: https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html"
            exit 1
        fi
        
        # インストール確認
        print_info "インストール確認中..."
        sleep 3
        
        # Windows環境でのSAM CLI確認
        if [[ "$OSTYPE" == "msys"* ]] || [[ "$OSTYPE" == "cygwin"* ]] || [[ "$(uname)" == "MINGW"* ]] || [[ "$(uname)" == "MSYS"* ]]; then
            if command -v sam.exe &> /dev/null; then
                print_success "SAM CLIがインストールされました: $(sam.exe --version)"
            elif command -v sam.cmd &> /dev/null; then
                print_success "SAM CLIがインストールされました: $(sam.cmd --version)"
            elif command -v sam &> /dev/null; then
                print_success "SAM CLIがインストールされました: $(sam --version)"
            else
                print_error "SAM CLIのインストール確認に失敗しました"
                print_info "手動でインストールしてください: https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html"
                exit 1
            fi
        else
            if command -v sam &> /dev/null; then
                print_success "SAM CLIがインストールされました: $(sam --version)"
            else
                print_error "SAM CLIのインストール確認に失敗しました"
                print_info "手動でインストールしてください: https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html"
                exit 1
            fi
        fi
    else
        print_error "SAM CLIのインストールをスキップしました。手動でインストールしてください"
        exit 1
    fi
else
    # Windows環境でのSAM CLI確認
    if [[ "$OSTYPE" == "msys"* ]] || [[ "$OSTYPE" == "cygwin"* ]] || [[ "$(uname)" == "MINGW"* ]] || [[ "$(uname)" == "MSYS"* ]]; then
        if command -v sam.exe &> /dev/null; then
            print_success "SAM CLIが見つかりました: $(sam.exe --version)"
        elif command -v sam.cmd &> /dev/null; then
            print_success "SAM CLIが見つかりました: $(sam.cmd --version)"
        elif command -v sam &> /dev/null; then
            print_success "SAM CLIが見つかりました: $(sam --version)"
        fi
    else
        print_success "SAM CLIが見つかりました: $(sam --version)"
    fi
fi

# 3. GitHub CLIの確認
print_info "GitHub CLIの確認中..."
GITHUB_CLI_FOUND=false

# 複数の方法でGitHub CLIを検索
if command -v gh &> /dev/null; then
    GH_VERSION=$(gh --version 2>/dev/null | head -n1)
    if [ $? -eq 0 ]; then
        print_success "GitHub CLIがインストールされています: $GH_VERSION"
        GITHUB_CLI_FOUND=true
    fi
fi

# Windows環境での追加検索
if [ "$GITHUB_CLI_FOUND" = false ] && [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "cygwin"* || "$OSTYPE" == "MINGW"* || "$OSTYPE" == "MSYS"* ]]; then
    # Windows Git Bashでの検索
    if [ -f "/c/Program Files/GitHub CLI/gh.exe" ]; then
        GH_VERSION=$("/c/Program Files/GitHub CLI/gh.exe" --version 2>/dev/null | head -n1)
        if [ $? -eq 0 ]; then
            print_success "GitHub CLIがインストールされています: $GH_VERSION"
            GITHUB_CLI_FOUND=true
            # PATHに追加
            export PATH="/c/Program Files/GitHub CLI:$PATH"
        fi
    fi
    
    # wingetでインストールされた場合
    if [ "$GITHUB_CLI_FOUND" = false ] && command -v winget &> /dev/null; then
        WINGET_GH=$(winget list GitHub.cli 2>/dev/null | grep -i "github.cli")
        if [ -n "$WINGET_GH" ]; then
            print_info "wingetでGitHub CLIがインストールされていることを確認しました"
            # パスを再検索
            for path in "/c/Users/$USER/AppData/Local/Microsoft/WinGet/Packages/GitHub.cli_Microsoft.Winget.Source_8wekyb3d8bbwe/LocalState/links" \
                         "/c/Program Files/GitHub CLI" \
                         "/c/Users/$USER/AppData/Local/GitHubCLI"; do
                if [ -f "$path/gh.exe" ]; then
                    GH_VERSION=$("$path/gh.exe" --version 2>/dev/null | head -n1)
                    if [ $? -eq 0 ]; then
                        print_success "GitHub CLIがインストールされています: $GH_VERSION"
                        GITHUB_CLI_FOUND=true
                        export PATH="$path:$PATH"
                        break
                    fi
                fi
            done
        fi
    fi
    
    # Scoopでインストールされた場合
    if [ "$GITHUB_CLI_FOUND" = false ] && command -v scoop &> /dev/null; then
        SCOOP_GH=$(scoop list 2>/dev/null | grep -i "gh")
        if [ -n "$SCOOP_GH" ]; then
            print_info "scoopでGitHub CLIがインストールされていることを確認しました"
            if [ -f "/c/Users/$USER/scoop/apps/gh/current/gh.exe" ]; then
                GH_VERSION=$("/c/Users/$USER/scoop/apps/gh/current/gh.exe" --version 2>/dev/null | head -n1)
                if [ $? -eq 0 ]; then
                    print_success "GitHub CLIがインストールされています: $GH_VERSION"
                    GITHUB_CLI_FOUND=true
                    export PATH="/c/Users/$USER/scoop/apps/gh/current:$PATH"
                fi
            fi
        fi
    fi
fi

if [ "$GITHUB_CLI_FOUND" = false ]; then
    print_warning "GitHub CLIがインストールされていません"
    read -p "GitHub CLIをインストールしますか？ (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        GITHUB_CLI_AVAILABLE=false
        print_info "GitHub CLIのインストール中..."
        
        # OS判定とインストール
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # Linux
            print_info "Linux環境でGitHub CLIをインストール中..."
            
            # 複数のインストール方法を試行
            INSTALL_SUCCESS=false
            
            # 方法1: apt-get (Debian/Ubuntu)
            if command -v apt-get &> /dev/null && ! $INSTALL_SUCCESS; then
                print_info "apt-getを使用してインストールを試行中..."
                if curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null; then
                    if echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null; then
                        if sudo apt-get update >/dev/null 2>&1 && sudo apt-get install gh -y >/dev/null 2>&1; then
                            INSTALL_SUCCESS=true
                            print_success "apt-getでGitHub CLIのインストールに成功しました"
                        fi
                    fi
                fi
            fi
            
            # 方法2: yum (RHEL/CentOS)
            if command -v yum &> /dev/null && ! $INSTALL_SUCCESS; then
                print_info "yumを使用してインストールを試行中..."
                if sudo yum install gh -y >/dev/null 2>&1; then
                    INSTALL_SUCCESS=true
                    print_success "yumでGitHub CLIのインストールに成功しました"
                fi
            fi
            
            # 方法3: dnf (Fedora)
            if command -v dnf &> /dev/null && ! $INSTALL_SUCCESS; then
                print_info "dnfを使用してインストールを試行中..."
                if sudo dnf install gh -y >/dev/null 2>&1; then
                    INSTALL_SUCCESS=true
                    print_success "dnfでGitHub CLIのインストールに成功しました"
                fi
            fi
            
            # 方法4: 直接ダウンロード
            if ! $INSTALL_SUCCESS; then
                print_info "直接ダウンロードでインストールを試行中..."
                ARCH=$(uname -m)
                if [[ "$ARCH" == "x86_64" ]]; then
                    ARCH="amd64"
                elif [[ "$ARCH" == "aarch64" ]]; then
                    ARCH="arm64"
                fi
                
                if curl -L "https://github.com/cli/cli/releases/latest/download/gh_linux_${ARCH}.tar.gz" -o /tmp/gh.tar.gz 2>/dev/null; then
                    if tar -xzf /tmp/gh.tar.gz -C /tmp 2>/dev/null; then
                        if sudo cp /tmp/gh_*/bin/gh /usr/local/bin/ 2>/dev/null; then
                            INSTALL_SUCCESS=true
                            print_success "直接ダウンロードでGitHub CLIのインストールに成功しました"
                        fi
                    fi
                    rm -f /tmp/gh.tar.gz
                    rm -rf /tmp/gh_*
                fi
            fi
            
            if ! $INSTALL_SUCCESS; then
                print_error "すべてのインストール方法が失敗しました"
                print_info "手動でGitHub CLIをインストールしてください: https://cli.github.com/"
                GITHUB_CLI_AVAILABLE=false
            fi
            
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            print_info "macOS環境でGitHub CLIをインストール中..."
            
            INSTALL_SUCCESS=false
            
            # 方法1: Homebrew
            if command -v brew &> /dev/null && ! $INSTALL_SUCCESS; then
                print_info "Homebrewを使用してインストールを試行中..."
                if brew install gh >/dev/null 2>&1; then
                    INSTALL_SUCCESS=true
                    print_success "HomebrewでGitHub CLIのインストールに成功しました"
                fi
            fi
            
            # 方法2: 直接ダウンロード
            if ! $INSTALL_SUCCESS; then
                print_info "直接ダウンロードでインストールを試行中..."
                ARCH=$(uname -m)
                if [[ "$ARCH" == "x86_64" ]]; then
                    ARCH="amd64"
                elif [[ "$ARCH" == "arm64" ]]; then
                    ARCH="arm64"
                fi
                
                if curl -L "https://github.com/cli/cli/releases/latest/download/gh_macOS_${ARCH}.tar.gz" -o /tmp/gh.tar.gz 2>/dev/null; then
                    if tar -xzf /tmp/gh.tar.gz -C /tmp 2>/dev/null; then
                        if sudo cp /tmp/gh_*/bin/gh /usr/local/bin/ 2>/dev/null; then
                            INSTALL_SUCCESS=true
                            print_success "直接ダウンロードでGitHub CLIのインストールに成功しました"
                        fi
                    fi
                    rm -f /tmp/gh.tar.gz
                    rm -rf /tmp/gh_*
                fi
            fi
            
            if ! $INSTALL_SUCCESS; then
                print_error "すべてのインストール方法が失敗しました"
                print_info "手動でGitHub CLIをインストールしてください: https://cli.github.com/"
                GITHUB_CLI_AVAILABLE=false
            fi
            
        elif [[ "$OSTYPE" == "msys"* ]] || [[ "$OSTYPE" == "cygwin"* ]] || [[ "$(uname)" == "MINGW"* ]] || [[ "$(uname)" == "MSYS"* ]]; then
            # Windows Git Bash / MSYS2 / Cygwin
            print_info "Windows環境でGitHub CLIをインストール中..."
            
            INSTALL_SUCCESS=false
            
            # 方法1: winget (Windows Package Manager)
            if command -v winget &> /dev/null && ! $INSTALL_SUCCESS; then
                print_info "wingetを使用してインストールを試行中..."
                if winget install GitHub.cli >/dev/null 2>&1; then
                    INSTALL_SUCCESS=true
                    print_success "wingetでGitHub CLIのインストールに成功しました"
                fi
            fi
            
            # 方法2: Scoop
            if command -v scoop &> /dev/null && ! $INSTALL_SUCCESS; then
                print_info "Scoopを使用してインストールを試行中..."
                if scoop install gh >/dev/null 2>&1; then
                    INSTALL_SUCCESS=true
                    print_success "ScoopでGitHub CLIのインストールに成功しました"
                fi
            fi
            
            # 方法3: pip3 (Python経由)
            if command -v pip3 &> /dev/null && ! $INSTALL_SUCCESS; then
                print_info "pip3を使用してインストールを試行中..."
                if pip3 install gh 2>/dev/null; then
                    INSTALL_SUCCESS=true
                    print_success "pip3でGitHub CLIのインストールに成功しました"
                fi
            fi
            
            # 方法4: 直接ダウンロード
            if ! $INSTALL_SUCCESS; then
                print_info "直接ダウンロードでインストールを試行中..."
                ARCH=$(uname -m)
                if [[ "$ARCH" == "x86_64" ]]; then
                    ARCH="amd64"
                elif [[ "$ARCH" == "aarch64" ]]; then
                    ARCH="arm64"
                fi
                
                # Windows用のダウンロードURL
                if curl -L "https://github.com/cli/cli/releases/latest/download/gh_windows_${ARCH}.zip" -o /tmp/gh.zip 2>/dev/null; then
                    if unzip -q /tmp/gh.zip -d /tmp 2>/dev/null; then
                        # 実行可能ファイルをPATHに追加
                        if [[ -d "$HOME/bin" ]]; then
                            cp /tmp/gh_*/bin/gh.exe "$HOME/bin/" 2>/dev/null
                            export PATH="$HOME/bin:$PATH"
                        elif [[ -d "/usr/local/bin" ]]; then
                            cp /tmp/gh_*/bin/gh.exe /usr/local/bin/ 2>/dev/null
                        else
                            # カレントディレクトリにコピー
                            cp /tmp/gh_*/bin/gh.exe ./ 2>/dev/null
                            export PATH="$(pwd):$PATH"
                        fi
                        INSTALL_SUCCESS=true
                        print_success "直接ダウンロードでGitHub CLIのインストールに成功しました"
                    fi
                    rm -f /tmp/gh.zip
                    rm -rf /tmp/gh_*
                fi
            fi
            
            if ! $INSTALL_SUCCESS; then
                print_error "すべてのインストール方法が失敗しました"
                print_info "手動でGitHub CLIをインストールしてください: https://cli.github.com/"
                print_info "Windows環境では以下を試してください:"
                print_info "1. winget install GitHub.cli"
                print_info "2. scoop install gh"
                print_info "3. https://cli.github.com/ から直接ダウンロード"
                GITHUB_CLI_AVAILABLE=false
            fi
            
        else
            print_error "サポートされていないOSです。手動でGitHub CLIをインストールしてください"
            print_info "インストール方法: https://cli.github.com/"
            GITHUB_CLI_AVAILABLE=false
        fi
        
        # インストール確認
        if command -v gh &> /dev/null; then
            print_success "GitHub CLIがインストールされました: $(gh --version)"
            GITHUB_CLI_AVAILABLE=true
        else
            print_error "GitHub CLIのインストールに失敗しました"
            GITHUB_CLI_AVAILABLE=false
        fi
    else
        print_warning "GitHub CLIのインストールをスキップしました。手動でGitHub Secretsを設定してください"
        GITHUB_CLI_AVAILABLE=false
    fi
else
    print_success "GitHub CLIが見つかりました: $(gh --version)"
    GITHUB_CLI_AVAILABLE=true
fi

# GitHub CLIの利用可能性を最終確認
if [ "$GITHUB_CLI_FOUND" = true ]; then
    GITHUB_CLI_AVAILABLE=true
    print_info "GitHub CLIが利用可能です"
fi

# 4. 現在のGitブランチの確認
print_info "現在のGitブランチの確認中..."
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || git rev-parse --abbrev-ref HEAD 2>/dev/null)

if [[ -z "$CURRENT_BRANCH" ]]; then
    print_warning "Gitブランチを取得できませんでした。手動でブランチを選択してください"
    echo ""
    echo "=== ブランチの選択 ==="
    echo "1. main (本番環境用)"
    echo "2. deploy (開発環境用)"
    echo "3. その他"
    echo ""
    
    while true; do
        read -p "ブランチを選択してください (1-3): " branch_choice
        if [[ "$branch_choice" =~ ^[1-3]$ ]]; then
            break
        fi
        echo "無効な選択です。1-3の数字を入力してください。"
    done
    
    case $branch_choice in
        1)
            CURRENT_BRANCH="main"
            print_info "本番環境用の設定を行います"
            ;;
        2)
            CURRENT_BRANCH="deploy"
            print_info "開発環境用の設定を行います"
            ;;
        3)
            read -p "ブランチ名を入力してください: " CURRENT_BRANCH
            print_info "カスタムブランチ '$CURRENT_BRANCH' の設定を行います"
            ;;
    esac
else
    print_success "現在のブランチ: $CURRENT_BRANCH"
    
    if [[ "$CURRENT_BRANCH" == "main" ]]; then
        print_info "本番環境用の設定を行います"
    elif [[ "$CURRENT_BRANCH" == "deploy" ]]; then
        print_info "開発環境用の設定を行います"
    else
        print_info "カスタムブランチ '$CURRENT_BRANCH' の設定を行います"
    fi
fi

# 環境設定の決定
print_info "ブランチ '$CURRENT_BRANCH' に基づいて環境を設定中..."

if [[ "$CURRENT_BRANCH" == "main" ]]; then
    ENVIRONMENT="production"
    STACK_NAME="lambda-framework-prod"
    SECRET_NAME="AWS_ROLE_ARN_PROD"
    print_info "mainブランチ → production環境 (本番環境)"
elif [[ "$CURRENT_BRANCH" == "deploy" ]]; then
    ENVIRONMENT="development"
    STACK_NAME="lambda-framework-dev"
    SECRET_NAME="AWS_ROLE_ARN_DEV"
    print_info "deployブランチ → development環境 (開発環境)"
else
    ENVIRONMENT="development"
    STACK_NAME="lambda-framework-dev"
    SECRET_NAME="AWS_ROLE_ARN_DEV"
    print_info "カスタムブランチ '$CURRENT_BRANCH' → development環境 (開発環境)"
fi

print_info "環境: $ENVIRONMENT"
print_info "スタック名: $STACK_NAME"
print_info "GitHub Secret名: $SECRET_NAME"

# 5. AWS認証情報の確認
print_info "AWS認証情報の確認中..."
if aws sts get-caller-identity &> /dev/null; then
    print_success "AWS認証情報が設定されています"
    CALLER_IDENTITY=$(aws sts get-caller-identity)
    CURRENT_ACCOUNT=$(echo "$CALLER_IDENTITY" | grep -o '"Account": "[^"]*"' | sed 's/"Account": "//;s/"//')
    echo "Account: $CURRENT_ACCOUNT"
    echo "User ID: $(echo "$CALLER_IDENTITY" | grep -o '"UserId": "[^"]*"' | sed 's/"UserId": "//;s/"//')"
    echo "ARN: $(echo "$CALLER_IDENTITY" | grep -o '"Arn": "[^"]*"' | sed 's/"Arn": "//;s/"//')"
    
    # AWSアカウントの選択
    echo ""
    echo "=== AWSアカウントの選択 ==="
    echo "1. 現在のアカウントを使用 ($CURRENT_ACCOUNT)"
    echo "2. 別のAWSアカウントを設定"
    echo ""
    
    while true; do
        read -p "AWSアカウントを選択してください (1-2): " account_choice
        if [[ "$account_choice" =~ ^[1-2]$ ]]; then
            break
        fi
        echo "無効な選択です。1-2の数字を入力してください。"
    done
    
    if [[ "$account_choice" == "2" ]]; then
        print_info "別のAWSアカウントを設定します"
        echo ""
        echo "=== AWS認証方法の選択 ==="
        echo "1. AWS CLI configure (アクセスキー/シークレットキー)"
        echo "2. AWS SSO (Single Sign-On)"
        echo "3. AWS IAM Identity Center (旧AWS SSO)"
        echo "4. AWS Profile (既存のプロファイル)"
        echo ""
        
        while true; do
            read -p "認証方法を選択してください (1-4): " auth_choice
            if [[ "$auth_choice" =~ ^[1-4]$ ]]; then
                break
            fi
            echo "無効な選択です。1-4の数字を入力してください。"
        done
        
        case $auth_choice in
            1)
                print_info "AWS CLI configureを実行します"
                echo "アクセスキーID、シークレットアクセスキー、リージョンを入力してください"
                aws configure
                ;;
            2)
                print_info "AWS SSOを設定します"
                read -p "SSO Start URLを入力してください (例: https://your-sso-portal.awsapps.com/start): " sso_start_url
                read -p "SSO Regionを入力してください (例: us-east-1): " sso_region
                read -p "AWS Account IDを入力してください: " account_id
                read -p "SSO Role Nameを入力してください: " role_name
                
                aws configure sso-session --profile default
                aws configure sso --profile default --sso-start-url "$sso_start_url" --sso-region "$sso_region" --account-id "$account_id" --role-name "$role_name"
                ;;
            3)
                print_info "AWS IAM Identity Centerを設定します"
                read -p "Identity Center Start URLを入力してください (例: https://your-portal.awsapps.com/start): " sso_start_url
                read -p "Identity Center Regionを入力してください (例: us-east-1): " sso_region
                read -p "AWS Account IDを入力してください: " account_id
                read -p "Role Nameを入力してください: " role_name
                
                aws configure sso-session --profile default
                aws configure sso --profile default --sso-start-url "$sso_start_url" --sso-region "$sso_region" --account-id "$account_id" --role-name "$role_name"
                ;;
            4)
                print_info "既存のAWS Profileを選択します"
                profiles=$(aws configure list-profiles 2>/dev/null)
                if [ -n "$profiles" ]; then
                    echo "利用可能なプロファイル:"
                    profile_array=($profiles)
                    for i in "${!profile_array[@]}"; do
                        echo "$((i+1)). ${profile_array[$i]}"
                    done
                    echo ""
                    read -p "プロファイル番号を選択してください (1-${#profile_array[@]}): " profile_choice
                    if [[ "$profile_choice" =~ ^[0-9]+$ ]] && [ "$profile_choice" -ge 1 ] && [ "$profile_choice" -le "${#profile_array[@]}" ]; then
                        selected_profile="${profile_array[$((profile_choice-1))]}"
                        export AWS_PROFILE="$selected_profile"
                        print_success "プロファイル '$selected_profile' が選択されました"
                    else
                        print_error "無効な選択です。デフォルトプロファイルを使用します"
                    fi
                else
                    print_warning "利用可能なプロファイルが見つかりません。AWS CLI configureを実行します"
                    aws configure
                fi
                ;;
        esac
        
        # 認証情報の再確認
        print_info "認証情報の確認中..."
        if aws sts get-caller-identity &> /dev/null; then
            print_success "AWS認証情報が正常に設定されました"
            CALLER_IDENTITY=$(aws sts get-caller-identity)
            echo "Account: $(echo "$CALLER_IDENTITY" | grep -o '"Account": "[^"]*"' | sed 's/"Account": "//;s/"//')"
            echo "User ID: $(echo "$CALLER_IDENTITY" | grep -o '"UserId": "[^"]*"' | sed 's/"UserId": "//;s/"//')"
            echo "ARN: $(echo "$CALLER_IDENTITY" | grep -o '"Arn": "[^"]*"' | sed 's/"Arn": "//;s/"//')"
        else
            print_error "AWS認証情報の設定に失敗しました"
            exit 1
        fi
    else
        print_info "現在のAWSアカウントを使用します"
    fi
else
    print_warning "AWS認証情報が設定されていません。AWS認証方法を選択してください"
    echo ""
    echo "=== AWS認証方法の選択 ==="
    echo "1. AWS CLI configure (アクセスキー/シークレットキー)"
    echo "2. AWS SSO (Single Sign-On)"
    echo "3. AWS IAM Identity Center (旧AWS SSO)"
    echo "4. AWS Profile (既存のプロファイル)"
    echo ""
    
    while true; do
        read -p "認証方法を選択してください (1-4): " auth_choice
        if [[ "$auth_choice" =~ ^[1-4]$ ]]; then
            break
        fi
        echo "無効な選択です。1-4の数字を入力してください。"
    done
    
    case $auth_choice in
        1)
            print_info "AWS CLI configureを実行します"
            echo "アクセスキーID、シークレットアクセスキー、リージョンを入力してください"
            aws configure
            ;;
        2)
            print_info "AWS SSOを設定します"
            read -p "SSO Start URLを入力してください (例: https://your-sso-portal.awsapps.com/start): " sso_start_url
            read -p "SSO Regionを入力してください (例: us-east-1): " sso_region
            read -p "AWS Account IDを入力してください: " account_id
            read -p "SSO Role Nameを入力してください: " role_name
            
            aws configure sso-session --profile default
            aws configure sso --profile default --sso-start-url "$sso_start_url" --sso-region "$sso_region" --account-id "$account_id" --role-name "$role_name"
            ;;
        3)
            print_info "AWS IAM Identity Centerを設定します"
            read -p "Identity Center Start URLを入力してください (例: https://your-portal.awsapps.com/start): " sso_start_url
            read -p "Identity Center Regionを入力してください (例: us-east-1): " sso_region
            read -p "AWS Account IDを入力してください: " account_id
            read -p "Role Nameを入力してください: " role_name
            
            aws configure sso-session --profile default
            aws configure sso --profile default --sso-start-url "$sso_start_url" --sso-region "$sso_region" --account-id "$account_id" --role-name "$role_name"
            ;;
        4)
            print_info "既存のAWS Profileを選択します"
            profiles=$(aws configure list-profiles 2>/dev/null)
            if [ -n "$profiles" ]; then
                echo "利用可能なプロファイル:"
                profile_array=($profiles)
                for i in "${!profile_array[@]}"; do
                    echo "$((i+1)). ${profile_array[$i]}"
                done
                echo ""
                read -p "プロファイル番号を選択してください (1-${#profile_array[@]}): " profile_choice
                if [[ "$profile_choice" =~ ^[0-9]+$ ]] && [ "$profile_choice" -ge 1 ] && [ "$profile_choice" -le "${#profile_array[@]}" ]; then
                    selected_profile="${profile_array[$((profile_choice-1))]}"
                    export AWS_PROFILE="$selected_profile"
                    print_success "プロファイル '$selected_profile' が選択されました"
                else
                    print_error "無効な選択です。デフォルトプロファイルを使用します"
                fi
            else
                print_warning "利用可能なプロファイルが見つかりません。AWS CLI configureを実行します"
                aws configure
            fi
            ;;
    esac
    
    # 認証情報の再確認
    print_info "認証情報の確認中..."
    if aws sts get-caller-identity &> /dev/null; then
        print_success "AWS認証情報が正常に設定されました"
        CALLER_IDENTITY=$(aws sts get-caller-identity)
        echo "Account: $(echo "$CALLER_IDENTITY" | grep -o '"Account": "[^"]*"' | sed 's/"Account": "//;s/"//')"
        echo "User ID: $(echo "$CALLER_IDENTITY" | grep -o '"UserId": "[^"]*"' | sed 's/"UserId": "//;s/"//')"
        echo "ARN: $(echo "$CALLER_IDENTITY" | grep -o '"Arn": "[^"]*"' | sed 's/"Arn": "//;s/"//')"
    else
        print_error "AWS認証情報の設定に失敗しました"
        exit 1
    fi
fi

# 5. GitHubユーザー情報の取得
print_info "GitHubユーザー情報の取得中..."

# GitHub CLIの利用可能性を再確認
GITHUB_CLI_WORKING=false
if [ "$GITHUB_CLI_AVAILABLE" = true ]; then
    print_info "GitHub CLIの認証状態を確認中..."
    
    # GitHub CLIの認証状態を確認
    if gh auth status &> /dev/null; then
        print_success "GitHub CLIにログイン済みです"
        GITHUB_CLI_WORKING=true
    else
        print_warning "GitHub CLIにログインしていません"
        echo ""
        echo "=== GitHub CLIログイン ==="
        echo "GitHub CLIにログインする必要があります"
        echo "1. ブラウザでログイン"
        echo "2. トークンでログイン"
        echo "3. 手動でユーザー情報を入力"
        echo ""
        
        while true; do
            read -p "ログイン方法を選択してください (1-3): " login_choice
            if [[ "$login_choice" =~ ^[1-3]$ ]]; then
                break
            fi
            echo "無効な選択です。1-3の数字を入力してください。"
        done
        
        case $login_choice in
            1)
                print_info "ブラウザでログインを開始します..."
                if gh auth login --web; then
                    print_success "GitHub CLIログインに成功しました"
                    GITHUB_CLI_WORKING=true
                else
                    print_error "GitHub CLIログインに失敗しました"
                fi
                ;;
            2)
                print_info "トークンでログインします..."
                read -p "GitHub Personal Access Tokenを入力してください: " github_token
                if gh auth login --with-token <<< "$github_token"; then
                    print_success "GitHub CLIログインに成功しました"
                    GITHUB_CLI_WORKING=true
                else
                    print_error "GitHub CLIログインに失敗しました"
                fi
                ;;
            3)
                print_info "手動でユーザー情報を入力します"
                GITHUB_CLI_WORKING=false
                ;;
        esac
    fi
    
    # GitHub CLIが動作する場合、ユーザー情報を取得
    if [ "$GITHUB_CLI_WORKING" = true ]; then
        print_info "GitHubユーザー情報を取得中..."
        
        # ユーザー情報の取得
        USER_RESPONSE=$(gh api user 2>/dev/null)
        if [ $? -eq 0 ] && [ -n "$USER_RESPONSE" ]; then
            GITHUB_USERNAME=$(echo "$USER_RESPONSE" | grep -o '"login": "[^"]*"' | sed 's/"login": "//;s/"//')
            if [ -n "$GITHUB_USERNAME" ]; then
                print_success "GitHubユーザー名: $GITHUB_USERNAME"
            else
                print_error "GitHubユーザー名の取得に失敗しました"
                GITHUB_CLI_WORKING=false
            fi
        else
            print_error "GitHub APIからのユーザー情報取得に失敗しました"
            GITHUB_CLI_WORKING=false
        fi
        
        # リポジトリ情報の取得
        if [ "$GITHUB_CLI_WORKING" = true ]; then
            REPO_RESPONSE=$(gh api repos/$GITHUB_USERNAME/$(basename $(git remote get-url origin 2>/dev/null) .git) 2>/dev/null)
            if [ $? -eq 0 ] && [ -n "$REPO_RESPONSE" ]; then
                GITHUB_REPO_NAME=$(basename $(git remote get-url origin 2>/dev/null) .git)
                print_success "GitHubリポジトリ名: $GITHUB_REPO_NAME"
            else
                print_warning "リポジトリ情報の取得に失敗しました。手動で入力してください"
                GITHUB_CLI_WORKING=false
            fi
        fi
    fi
fi

# GitHub CLIが利用できない場合、手動で入力
if [ "$GITHUB_CLI_WORKING" = false ]; then
    print_warning "GitHub CLIが利用できません。手動でGitHubユーザー名とリポジトリ名を入力してください"
    read -p "GitHubユーザー名を入力してください: " GITHUB_USERNAME
    read -p "GitHubリポジトリ名を入力してください: " GITHUB_REPO_NAME
fi

# 6. AWSアカウントIDの取得
print_info "AWSアカウントIDの取得中..."
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
if [ -z "$AWS_ACCOUNT_ID" ] || [ "$AWS_ACCOUNT_ID" = "None" ]; then
    print_error "AWSアカウントIDの取得に失敗しました"
    print_info "AWS認証情報を確認してください"
    aws sts get-caller-identity
    exit 1
fi
print_success "AWSアカウントID: $AWS_ACCOUNT_ID"

# AWSリージョンの確認
print_info "AWSリージョンの確認"
read -p "AWSリージョンを入力してください (デフォルト: ap-northeast-1): " AWS_REGION_INPUT
AWS_REGION=${AWS_REGION_INPUT:-"ap-northeast-1"}
print_success "AWSリージョン: $AWS_REGION"

# プロジェクト名の確認
print_info "プロジェクト名の確認"
read -p "プロジェクト名を入力してください (デフォルト: LambdaFramework): " PROJECT_NAME_INPUT
PROJECT_NAME=${PROJECT_NAME_INPUT:-"LambdaFramework"}
print_success "プロジェクト名: $PROJECT_NAME"

# S3バケット名の確認
print_info "S3バケット名の確認"
read -p "S3バケット名を入力してください (デフォルト: cn-seba-aws-sam-cli-managed-default-samclisourcebucket): " S3_BUCKET_INPUT
S3_BUCKET=${S3_BUCKET_INPUT:-"cn-seba-aws-sam-cli-managed-default-samclisourcebucket"}
print_success "S3バケット名: $S3_BUCKET"

# 7. OIDCプロバイダーの選択
print_info "OIDCプロバイダーの選択中..."

# 既存のOIDCプロバイダー一覧を取得
print_info "既存のOIDCプロバイダーを取得中..."
OIDC_PROVIDERS=$(aws iam list-open-id-connect-providers --query 'OpenIDConnectProviderList[].Arn' --output text 2>/dev/null)

# GitHub Actions用のOIDCプロバイダーARN
GITHUB_OIDC_ARN="arn:aws:iam::$AWS_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"

# 選択肢を準備
echo ""
echo "=== 利用可能なOIDCプロバイダー ==="
echo "0. 新規作成: GitHub Actions用OIDCプロバイダー"
echo "   ($GITHUB_OIDC_ARN)"

# 既存のプロバイダーを表示
if [ -n "$OIDC_PROVIDERS" ]; then
    IFS=$'\t' read -ra PROVIDER_ARRAY <<< "$OIDC_PROVIDERS"
    for i in "${!PROVIDER_ARRAY[@]}"; do
        PROVIDER_ARN="${PROVIDER_ARRAY[$i]}"
        PROVIDER_URL=$(aws iam get-open-id-connect-provider --open-id-connect-provider-arn "$PROVIDER_ARN" --query 'Url' --output text 2>/dev/null)
        echo "$((i+1)). $PROVIDER_ARN"
        echo "   URL: $PROVIDER_URL"
    done
else
    echo "既存のOIDCプロバイダーが見つかりません"
fi

echo ""
read -p "OIDCプロバイダーを選択してください (0-${#PROVIDER_ARRAY[@]}): " OIDC_CHOICE

# 選択に基づいてOIDCプロバイダーARNを設定
if [ "$OIDC_CHOICE" = "0" ]; then
    print_info "新規OIDCプロバイダーを作成中..."
    OIDC_PROVIDER_ARN="$GITHUB_OIDC_ARN"
    
    # OIDCプロバイダーが既に存在するかチェック
    if ! aws iam get-open-id-connect-provider --open-id-connect-provider-arn "$OIDC_PROVIDER_ARN" &> /dev/null; then
        aws iam create-open-id-connect-provider \
            --url https://token.actions.githubusercontent.com \
            --client-id-list sts.amazonaws.com \
            --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
        print_success "OIDCプロバイダーが作成されました"
    else
        print_success "OIDCプロバイダーは既に存在します"
    fi
else
    # 既存のプロバイダーを選択
    if [ -n "$OIDC_PROVIDERS" ] && [ "$OIDC_CHOICE" -ge 1 ] && [ "$OIDC_CHOICE" -le "${#PROVIDER_ARRAY[@]}" ]; then
        SELECTED_INDEX=$((OIDC_CHOICE-1))
        OIDC_PROVIDER_ARN="${PROVIDER_ARRAY[$SELECTED_INDEX]}"
        print_success "選択されたOIDCプロバイダー: $OIDC_PROVIDER_ARN"
    else
        print_error "無効な選択です。デフォルトで新規作成します"
        OIDC_PROVIDER_ARN="$GITHUB_OIDC_ARN"
        
        if ! aws iam get-open-id-connect-provider --open-id-connect-provider-arn "$OIDC_PROVIDER_ARN" &> /dev/null; then
            aws iam create-open-id-connect-provider \
                --url https://token.actions.githubusercontent.com \
                --client-id-list sts.amazonaws.com \
                --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
            print_success "OIDCプロバイダーが作成されました"
        else
            print_success "OIDCプロバイダーは既に存在します"
        fi
    fi
fi

# 8. IAMロールの作成
print_info "IAMロールの作成について確認します"
DEFAULT_ROLE_NAME="${PROJECT_NAME}-github-actions-role"
read -p "IAMロール名を入力してください (デフォルト: $DEFAULT_ROLE_NAME): " ROLE_NAME_INPUT
ROLE_NAME=${ROLE_NAME_INPUT:-$DEFAULT_ROLE_NAME}
print_info "IAMロールの作成中... ($ROLE_NAME)"
TRUST_POLICY=$(cat <<EOF
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
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                },
                "StringLike": {
                    "token.actions.githubusercontent.com:sub": [
                        "repo:$GITHUB_USERNAME/$GITHUB_REPO_NAME:ref:refs/heads/main",
                        "repo:$GITHUB_USERNAME/$GITHUB_REPO_NAME:ref:refs/heads/deploy"
                    ]
                }
            }
        }
    ]
}
EOF
)

# ロールが存在するかチェック
if ! aws iam get-role --role-name "$ROLE_NAME" &> /dev/null; then
    print_info "IAMロールを作成中..."
    aws iam create-role \
        --role-name "$ROLE_NAME" \
        --assume-role-policy-document "$TRUST_POLICY"
    print_success "IAMロールが作成されました: $ROLE_NAME"
else
    print_success "IAMロールは既に存在します: $ROLE_NAME"
fi

# 9. ポリシーの作成とアタッチ
print_info "IAMポリシーの作成について確認します"
DEFAULT_POLICY_NAME="${PROJECT_NAME}-github-actions-policy"
read -p "IAMポリシー名を入力してください (デフォルト: $DEFAULT_POLICY_NAME): " POLICY_NAME_INPUT
POLICY_NAME=${POLICY_NAME_INPUT:-$DEFAULT_POLICY_NAME}
print_info "IAMポリシーの作成中... ($POLICY_NAME)"
POLICY_DOCUMENT=$(cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "cloudformation:*",
                "lambda:*",
                "iam:*",
                "logs:*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject",
                "s3:ListBucket",
                "s3:GetBucketLocation",
                "s3:GetObjectVersion",
                "s3:PutObjectAcl"
            ],
            "Resource": [
                "arn:aws:s3:::cn-seba-aws-sam-cli-managed-default-samclisourcebucket",
                "arn:aws:s3:::cn-seba-aws-sam-cli-managed-default-samclisourcebucket/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:CreateBucket",
                "s3:DeleteBucket",
                "s3:ListAllMyBuckets"
            ],
            "Resource": "*"
        }
    ]
}
EOF
)

# ポリシーが存在するかチェック
print_info "IAMポリシーの存在を確認中: $POLICY_NAME"
POLICY_EXISTS=false

# より確実な存在確認方法
CHECK_RESULT=$(aws iam list-policies --scope Local --query "Policies[?PolicyName=='$POLICY_NAME'].Arn" --output text 2>/dev/null)
if [ $? -eq 0 ] && [ -n "$CHECK_RESULT" ] && [ "$CHECK_RESULT" != "None" ]; then
    print_success "IAMポリシーは既に存在します: $POLICY_NAME"
    POLICY_EXISTS=true
else
    print_info "IAMポリシーが見つかりません。作成を試行します..."
fi

if [ "$POLICY_EXISTS" = false ]; then
    print_info "IAMポリシーを作成中..."
    aws iam create-policy \
        --policy-name "$POLICY_NAME" \
        --policy-document "$POLICY_DOCUMENT"
    
    if [ $? -eq 0 ]; then
        print_success "IAMポリシーが作成されました: $POLICY_NAME"
    else
        # 作成に失敗した場合、既に存在する可能性があるので再確認
        RECHECK_RESULT=$(aws iam list-policies --scope Local --query "Policies[?PolicyName=='$POLICY_NAME'].Arn" --output text 2>/dev/null)
        if [ $? -eq 0 ] && [ -n "$RECHECK_RESULT" ] && [ "$RECHECK_RESULT" != "None" ]; then
            print_success "IAMポリシーは既に存在します: $POLICY_NAME"
        else
            print_error "IAMポリシーの作成に失敗しました"
            exit 1
        fi
    fi
fi

# ポリシーをロールにアタッチ
print_info "ポリシーをロールにアタッチ中..."
aws iam attach-role-policy \
    --role-name "$ROLE_NAME" \
    --policy-arn "arn:aws:iam::$AWS_ACCOUNT_ID:policy/$POLICY_NAME"
print_success "ポリシーがロールにアタッチされました"

# 10. GitHub Secretsの自動登録
if [ "$GITHUB_CLI_AVAILABLE" = true ]; then
    print_info "GitHub Secretsの自動登録について確認します"
    read -p "GitHub Secretsを自動登録しますか？ (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "GitHub Secretsの自動登録中..."
        
            # Repository Secretsの登録（機密情報）
        print_info "=== Repository Secretsの登録 ==="
        
        # 環境別AWS_ROLE_ARNの登録
        AWS_ROLE_ARN="arn:aws:iam::$AWS_ACCOUNT_ID:role/$ROLE_NAME"
        print_info "登録するARN: $AWS_ROLE_ARN"
        if gh secret set "$SECRET_NAME" --body "$AWS_ROLE_ARN" &> /dev/null; then
            print_success "$SECRET_NAMEがRepository Secretsに登録されました"
        else
            print_warning "$SECRET_NAMEの登録に失敗しました"
            print_info "手動でGitHub Secretsに設定してください:"
            print_info "Name: $SECRET_NAME"
            print_info "Value: $AWS_ROLE_ARN"
        fi
    
    # S3_BUCKETの登録
    if gh secret set S3_BUCKET --body "$S3_BUCKET" &> /dev/null; then
        print_success "S3_BUCKETがRepository Secretsに登録されました"
    else
        print_warning "S3_BUCKETの登録に失敗しました"
    fi
    
    # Repository Variablesの登録（非機密情報）
    print_info "=== Repository Variablesの登録 ==="
    
    # AWS_REGIONの登録
    if gh variable set AWS_REGION --body "$AWS_REGION" &> /dev/null; then
        print_success "AWS_REGIONがRepository Variablesに登録されました"
    else
        print_warning "AWS_REGIONの登録に失敗しました"
    fi
    
    # PROJECT_NAMEの登録
    if gh variable set PROJECT_NAME --body "$PROJECT_NAME" &> /dev/null; then
        print_success "PROJECT_NAMEがRepository Variablesに登録されました"
    else
        print_warning "PROJECT_NAMEの登録に失敗しました"
    fi
    
    # 環境別S3バケットの登録
    if gh variable set S3_BUCKET_DEV --body "$S3_BUCKET" &> /dev/null; then
        print_success "S3_BUCKET_DEVがRepository Variablesに登録されました"
    else
        print_warning "S3_BUCKET_DEVの登録に失敗しました"
    fi
    
    if gh variable set S3_BUCKET_PROD --body "$S3_BUCKET" &> /dev/null; then
        print_success "S3_BUCKET_PRODがRepository Variablesに登録されました"
    else
        print_warning "S3_BUCKET_PRODの登録に失敗しました"
    fi
    else
        print_info "GitHub Secretsの自動登録をスキップしました"
    fi
else
    print_warning "GitHub CLIが利用できないため、手動でGitHub Secretsを設定してください"
fi

# 11. 結果の表示
print_success "設定が完了しました！"
echo ""
echo "=== 設定情報 ==="
echo "AWSアカウントID: $AWS_ACCOUNT_ID"
echo "GitHubユーザー名: $GITHUB_USERNAME"
echo "GitHubリポジトリ名: $GITHUB_REPO_NAME"
echo "IAMロール名: $ROLE_NAME"
echo "IAMロールARN: arn:aws:iam::$AWS_ACCOUNT_ID:role/$ROLE_NAME"
echo ""

if [ "$GITHUB_CLI_AVAILABLE" = true ]; then
    print_success "GitHub SecretsとVariablesが自動登録されました"
    echo "登録されたRepository Secrets:"
    echo "- $SECRET_NAME"
    echo "- S3_BUCKET"
    echo "登録されたRepository Variables:"
    echo "- AWS_REGION"
    echo "- PROJECT_NAME"
    echo "- S3_BUCKET_DEV"
    echo "- S3_BUCKET_PROD"
else
    echo "手動でGitHubに以下を設定してください:"
    echo ""
    echo "Repository Secrets:"
    echo "Name: $SECRET_NAME"
    echo "Value: arn:aws:iam::$AWS_ACCOUNT_ID:role/$ROLE_NAME"
    echo "Name: S3_BUCKET"
    echo "Value: $S3_BUCKET"
    echo ""
    echo "Repository Variables:"
    echo "Name: AWS_REGION"
    echo "Value: $AWS_REGION"
    echo "Name: PROJECT_NAME"
    echo "Value: $PROJECT_NAME"
    echo "Name: S3_BUCKET_DEV"
    echo "Value: $S3_BUCKET"
    echo "Name: S3_BUCKET_PROD"
    echo "Value: $S3_BUCKET"
fi 