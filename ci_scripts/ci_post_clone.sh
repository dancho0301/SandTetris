#!/bin/sh

# Xcode Cloud ビルド用スクリプト
# リポジトリクローン後に自動実行されます

set -e

echo "========================================="
echo "🔧 Xcode Cloud環境をセットアップ中..."
echo "========================================="

# 環境変数を表示
echo "CI_WORKSPACE: $CI_WORKSPACE"
echo "CI_XCODE_PATH: $CI_XCODE_PATH"

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
cd "$CI_WORKSPACE"

echo "========================================="
echo "📦 pod installを実行中..."
echo "========================================="

# Podfileの存在を確認
if [ ! -f "Podfile" ]; then
    echo "❌ Error: Podfile not found!"
    exit 1
fi

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
