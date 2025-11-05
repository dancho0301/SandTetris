#!/bin/sh

# Xcode Cloud ビルド後スクリプト
# xcodebuildコマンド失敗時に実行されます

set +e  # エラーでも続行

echo "========================================="
echo "❌ ビルド失敗 - デバッグ情報を収集中..."
echo "========================================="

# プロジェクトルートに移動
cd "$(dirname "$0")/.."
PROJECT_ROOT="$(pwd)"

echo "Project root: $PROJECT_ROOT"

# ビルド成果物の確認
echo "Checking build artifacts..."
if [ -d "/Volumes/workspace/DerivedData" ]; then
    echo "DerivedData contents:"
    ls -la /Volumes/workspace/DerivedData/ | head -20
fi

# Podsの状態確認
echo "Checking Pods..."
if [ -d "Pods" ]; then
    echo "Pods installed:"
    ls -la Pods/ | grep -E "^d" | head -10

    echo "Google-Mobile-Ads-SDK location:"
    find Pods -name "GoogleMobileAds.framework" -o -name "GoogleMobileAds.xcframework" 2>/dev/null | head -5
fi

# .xcworkspaceの構造
echo "Workspace structure:"
if [ -d "sandtetris.xcworkspace" ]; then
    ls -la sandtetris.xcworkspace/
fi

# ビルドログから重要なエラーを抽出
echo "Searching for errors in build log..."
if [ -f "/Volumes/workspace/resultbundle.xcresult" ]; then
    echo "Result bundle found at /Volumes/workspace/resultbundle.xcresult"
fi

echo "========================================="
echo "デバッグ情報の収集が完了しました"
echo "========================================="
