#!/bin/sh

# Xcode Cloud ビルド用スクリプト
# リポジトリクローン後に自動実行されます

set -e

echo "🔧 Xcode Cloud環境をセットアップ中..."

# Xcode Command Line Toolsのパスを設定
if [ -n "$CI_XCODE_PATH" ]; then
    echo "Setting Xcode path to: $CI_XCODE_PATH"
    sudo xcode-select -s "$CI_XCODE_PATH"
fi

# CocoaPodsがインストールされていない場合はインストール
if ! command -v pod &> /dev/null
then
    echo "CocoaPods not found, installing..."
    sudo gem install cocoapods
fi

# プロジェクトルートディレクトリに移動
cd "$CI_WORKSPACE"

echo "📦 pod installを実行中..."
pod install

echo "✅ CocoaPodsのセットアップが完了しました"

# Xcodeのバージョンを表示（デバッグ用）
xcodebuild -version
