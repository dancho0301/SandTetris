#!/bin/sh

# Xcode Cloud ビルド前スクリプト
# xcodebuildコマンド実行前に自動実行されます

set -e

echo "========================================="
echo "🔨 ビルド前のセットアップ..."
echo "========================================="

# プロジェクトルートに移動
cd "$(dirname "$0")/.."
PROJECT_ROOT="$(pwd)"

echo "Project root: $PROJECT_ROOT"

# ビルド設定を表示（デバッグ用）
echo "CI_XCODE_VERSION: ${CI_XCODE_VERSION:-not set}"
echo "CI_XCODEBUILD_ACTION: ${CI_XCODEBUILD_ACTION:-not set}"
echo "CI_WORKSPACE: ${CI_WORKSPACE:-not set}"

# .xcworkspaceの存在を確認
if [ ! -d "sandtetris.xcworkspace" ]; then
    echo "❌ Error: sandtetris.xcworkspace not found!"
    echo "Available files:"
    ls -la
    exit 1
fi

echo "✅ sandtetris.xcworkspace found"

# Podsディレクトリの確認
if [ ! -d "Pods" ]; then
    echo "⚠️ Warning: Pods directory not found"
else
    echo "✅ Pods directory found"
    echo "Installed pods:"
    ls -la Pods | grep -E "^d" | tail -n +2
fi

# DerivedDataをクリーン（Metalツールチェーンのキャッシュ問題を回避）
if [ -n "$CI_DERIVED_DATA_PATH" ] && [ -d "$CI_DERIVED_DATA_PATH" ]; then
    echo "Cleaning DerivedData at: $CI_DERIVED_DATA_PATH"
    rm -rf "$CI_DERIVED_DATA_PATH"/*
else
    echo "⚠️ CI_DERIVED_DATA_PATH not set or not found, skipping DerivedData clean"
fi

# Xcodeプロジェクト設定を確認
echo "Checking Xcode project settings..."
xcodebuild -workspace sandtetris.xcworkspace -scheme sandtetris -showBuildSettings | grep -E "PRODUCT_BUNDLE_IDENTIFIER|DEVELOPMENT_TEAM|CODE_SIGN" | head -20

echo "========================================="
echo "✅ ビルド前のセットアップが完了しました"
echo "========================================="
