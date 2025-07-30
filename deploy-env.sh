#!/bin/bash

# 環境別デプロイスクリプト
# 使用方法: ./deploy-env.sh [development|production] [aws-profile]

set -e

# 色付きメッセージ関数
print_info() {
    echo -e "\033[34m[INFO]\033[0m $1"
}

print_success() {
    echo -e "\033[32m[SUCCESS]\033[0m $1"
}

print_warning() {
    echo -e "\033[33m[WARNING]\033[0m $1"
}

print_error() {
    echo -e "\033[31m[ERROR]\033[0m $1"
}

# 環境の確認
ENVIRONMENT=${1:-development}
AWS_PROFILE=${2:-}

if [[ "$ENVIRONMENT" != "development" && "$ENVIRONMENT" != "production" ]]; then
    print_error "無効な環境です。development または production を指定してください。"
    echo "使用方法: $0 [development|production] [aws-profile]"
    exit 1
fi

print_info "環境: $ENVIRONMENT"
if [[ -n "$AWS_PROFILE" ]]; then
    print_info "AWS Profile: $AWS_PROFILE"
    export AWS_PROFILE="$AWS_PROFILE"
fi

# スタック名の設定
if [[ "$ENVIRONMENT" == "production" ]]; then
    STACK_NAME="lambda-framework-prod"
    print_info "本番環境にデプロイします"
else
    STACK_NAME="lambda-framework-dev"
    print_info "開発環境にデプロイします"
fi

print_info "スタック名: $STACK_NAME"

# SAMビルド
print_info "SAMビルドを実行中..."
sam build

# SAMデプロイ
print_info "SAMデプロイを実行中..."
if [[ -n "$AWS_PROFILE" ]]; then
    sam deploy \
        --config-env $ENVIRONMENT \
        --stack-name $STACK_NAME \
        --no-confirm-changeset \
        --no-fail-on-empty-changeset \
        --parameter-overrides Environment=$ENVIRONMENT \
        --profile $AWS_PROFILE
else
    sam deploy \
        --config-env $ENVIRONMENT \
        --stack-name $STACK_NAME \
        --no-confirm-changeset \
        --no-fail-on-empty-changeset \
        --parameter-overrides Environment=$ENVIRONMENT
fi

print_success "デプロイが完了しました！"
print_info "スタック名: $STACK_NAME"
print_info "環境: $ENVIRONMENT" 