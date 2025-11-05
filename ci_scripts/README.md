# Xcode Cloud ビルド設定

このディレクトリには、Xcode Cloud で自動ビルドを行うためのスクリプトが含まれています。

## ファイル説明

### ci_post_clone.sh
リポジトリのクローン後に自動実行されるスクリプトです。
- Xcode Command Line Toolsのパスを設定
- CocoaPods の依存関係をインストール
- Xcodeバージョンを表示

### ci_pre_xcodebuild.sh
xcodebuildコマンド実行前に自動実行されるスクリプトです。
- DerivedDataをクリーン（Metalツールチェーンのキャッシュ問題を回避）
- ビルド環境変数を表示

## Xcode Cloud の設定手順

### 1. Xcode Cloud でワークフローを作成
1. Xcode を開く
2. メニューから「Product」→「Xcode Cloud」→「Create Workflow」を選択
3. ワークフローの設定を行う

### 2. ビルド設定
- **Scheme**: `sandtetris` を選択
- **Platform**: iOS を選択
- **Archive**: sandtetris.xcworkspace を使用（重要！）

### 3. 環境設定
Xcode Cloud は自動的に `ci_scripts/ci_post_clone.sh` を検出して実行します。

### 4. 必要な権限
スクリプトには実行権限が必要です（すでに付与済み）：
```bash
chmod +x ci_scripts/ci_post_clone.sh
```

## トラブルシューティング

### ビルドが失敗する場合
1. Xcode Cloud のログを確認
2. CocoaPods のインストールが成功しているか確認
3. .xcworkspace ファイルが正しく生成されているか確認

### ローカルでテスト
```bash
# プロジェクトルートで実行
./ci_scripts/ci_post_clone.sh
```

## 参考リンク
- [Xcode Cloud Documentation](https://developer.apple.com/documentation/xcode/xcode-cloud)
- [CocoaPods with Xcode Cloud](https://guides.cocoapods.org/using/using-cocoapods.html)
