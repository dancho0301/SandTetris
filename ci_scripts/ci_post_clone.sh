#!/bin/sh

# Xcode Cloud ビルド用スクリプト
# リポジトリクローン後に自動実行されます

set -e

echo "========================================="
echo "🔧 Xcode Cloud環境をセットアップ中..."
echo "========================================="

# 現在のディレクトリを表示
echo "Current directory: $(pwd)"

# 環境変数を表示
echo "CI_WORKSPACE: ${CI_WORKSPACE:-not set}"
echo "CI_XCODE_PATH: ${CI_XCODE_PATH:-not set}"

# Xcode Command Line Toolsのパスを設定
if [ -n "$CI_XCODE_PATH" ]; then
    echo "Setting Xcode path to: $CI_XCODE_PATH"
    sudo xcode-select -s "$CI_XCODE_PATH"
else
    echo "⚠️ CI_XCODE_PATH is not set, using default"
fi

# Xcodeのバージョンを表示
echo "Xcode version:"
xcodebuild -version

# CocoaPodsのバージョンを確認
if command -v pod &> /dev/null
then
    echo "CocoaPods version:"
    pod --version
else
    echo "CocoaPods not found, installing..."
    sudo gem install cocoapods -v 1.15.2
    echo "Installed CocoaPods version:"
    pod --version
fi

# プロジェクトルートディレクトリに移動
# ci_scriptsディレクトリから1つ上の階層に移動
cd "$(dirname "$0")/.."
PROJECT_ROOT="$(pwd)"

echo "Project root: $PROJECT_ROOT"

# ディレクトリ内容を確認
echo "Files in project root:"
ls -la

echo "========================================="
echo "📦 pod installを実行中..."
echo "========================================="

# Podfileの存在を確認
if [ ! -f "Podfile" ]; then
    echo "❌ Error: Podfile not found in $PROJECT_ROOT"
    echo "Available files:"
    ls -la
    exit 1
fi

echo "✅ Podfile found!"

# CocoaPodsのキャッシュをクリア
pod cache clean --all

# pod install実行
pod install --verbose

# .xcworkspaceが生成されたか確認
if [ ! -d "sandtetris.xcworkspace" ]; then
    echo "❌ Error: sandtetris.xcworkspace was not created!"
    exit 1
fi

echo "========================================="
echo "✅ CocoaPodsのセットアップが完了しました"
echo "========================================="

# 生成されたファイルを確認
echo "Generated files:"
ls -la | grep -E "\.xc"
