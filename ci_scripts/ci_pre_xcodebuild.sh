#!/bin/sh

# Xcode Cloud ビルド前スクリプト
# xcodebuildコマンド実行前に自動実行されます

set -e

echo "🔨 ビルド前のセットアップ..."

# DerivedDataをクリーン（Metalツールチェーンのキャッシュ問題を回避）
if [ -d "$CI_DERIVED_DATA_PATH" ]; then
    echo "Cleaning DerivedData..."
    rm -rf "$CI_DERIVED_DATA_PATH"/*
fi

# ビルド設定を表示（デバッグ用）
echo "CI_XCODE_VERSION: $CI_XCODE_VERSION"
echo "CI_XCODEBUILD_ACTION: $CI_XCODEBUILD_ACTION"
echo "CI_WORKSPACE: $CI_WORKSPACE"

echo "✅ ビルド前のセットアップが完了しました"
