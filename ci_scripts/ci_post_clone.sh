#!/bin/sh

# Xcode Cloud ビルド用スクリプト
# リポジトリクローン後に自動実行されます

set -e

echo "🔧 CocoaPodsをインストール中..."

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
