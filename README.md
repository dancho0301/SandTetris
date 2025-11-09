# SandTetris

<div align="center">

🎮 **サンドドロップ（Sand Drop）** - 心地よい操作感の落ち物パズルゲーム

[日本語](#日本語) | [English](#english)

</div>

---

## 日本語

### 概要

SandTetrisは、SwiftUIとSwiftDataで構築されたiOSゲームアプリケーションです。既存の砂テトリスゲームの操作性を改善し、以下の点を重視して開発されています：

- **手に馴染む操作感**: 直感的で快適な操作性を実現
- **日本人受けしやすいポップなデザイン**: 親しみやすく魅力的なビジュアル

### 主な機能

- 🎯 複数の難易度レベル
- 💾 ハイスコア記録システム
- ⚙️ カスタマイズ可能な設定
- 📱 iPhone/iPad対応
- 🌐 日本語・英語の多言語対応
- 📊 AdMobによる広告表示（バナー・インタースティシャル）

### 動作要件

- iOS 17.0以上
- Xcode 26.0以上
- Swift 5.0
- CocoaPods

### セットアップ

1. リポジトリをクローン:
```bash
git clone https://github.com/dancho0301/SandTetris.git
cd SandTetris
```

2. CocoaPodsで依存関係をインストール:
```bash
pod install
```

3. Xcodeでプロジェクトを開く:
```bash
open sandtetris.xcodeproj
```

### ビルドと実行

#### アプリのビルド

Xcodeで `Cmd+B` を押すか、以下のコマンドを実行:

```bash
# デバッグビルド
xcodebuild -project sandtetris.xcodeproj -scheme sandtetris -configuration Debug build

# リリースビルド
xcodebuild -project sandtetris.xcodeproj -scheme sandtetris -configuration Release build
```

#### シミュレータで実行

Xcodeで `Cmd+R` を押すか、以下のコマンドを実行:

```bash
xcodebuild -project sandtetris.xcodeproj -scheme sandtetris -destination 'platform=iOS Simulator,name=iPhone 15' run
```

#### テストの実行

```bash
# ユニットテスト
xcodebuild test -project sandtetris.xcodeproj -scheme sandtetris -destination 'platform=iOS Simulator,name=iPhone 15'

# UIテスト
xcodebuild test -project sandtetris.xcodeproj -scheme sandtetris -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:sandtetrisUITests
```

### アーキテクチャ

#### コアコンポーネント

- **sandtetrisApp.swift**: アプリのエントリーポイント、SwiftDataのModelContainerを設定
- **GameView.swift**: メインのゲームビュー
- **GameModel.swift**: ゲームロジックとステート管理
- **TetrisPiece.swift**: テトリスピースの定義と動作
- **DifficultySelectionView.swift**: 難易度選択画面
- **SettingsView.swift**: 設定画面
- **HighScore.swift**: ハイスコアのデータモデル
- **AdMobManager.swift**: 広告管理（バナー・インタースティシャル）

#### データフロー

SwiftDataを使用した永続化:
1. `sandtetrisApp`が`ModelContainer`を作成し、ビュー階層に注入
2. 各ビューが`@Environment(\.modelContext)`と`@Query`でデータにアクセス
3. すべてのCRUD操作はモデルコンテキストを通じて実行
4. SwiftDataが自動的に永続化を処理

### プロジェクト設定

- **Bundle Identifier**: jp.dancho.sandtetris
- **開発チーム**: 6549AY6J4G
- **デプロイメントターゲット**: iOS 26.0（※Podfileでは17.0に設定）
- **対応デバイス**: iPhone、iPad

### 依存関係

- Google-Mobile-Ads-SDK: AdMob広告の表示

### ライセンス

このプロジェクトのライセンスについては、リポジトリのオーナーにお問い合わせください。

---

## English

### Overview

SandTetris is an iOS game application built with SwiftUI and SwiftData. It improves upon existing sand tetris games with a focus on:

- **Comfortable controls**: Intuitive and smooth gameplay experience
- **Pop design**: Attractive and user-friendly visuals appealing to Japanese users

### Key Features

- 🎯 Multiple difficulty levels
- 💾 High score tracking system
- ⚙️ Customizable settings
- 📱 iPhone/iPad support
- 🌐 Multi-language support (Japanese/English)
- 📊 AdMob integration (Banner & Interstitial ads)

### Requirements

- iOS 17.0 or later
- Xcode 26.0 or later
- Swift 5.0
- CocoaPods

### Setup

1. Clone the repository:
```bash
git clone https://github.com/dancho0301/SandTetris.git
cd SandTetris
```

2. Install dependencies with CocoaPods:
```bash
pod install
```

3. Open the project in Xcode:
```bash
open sandtetris.xcodeproj
```

### Build & Run

#### Building the App

Press `Cmd+B` in Xcode or run:

```bash
# Debug build
xcodebuild -project sandtetris.xcodeproj -scheme sandtetris -configuration Debug build

# Release build
xcodebuild -project sandtetris.xcodeproj -scheme sandtetris -configuration Release build
```

#### Run in Simulator

Press `Cmd+R` in Xcode or run:

```bash
xcodebuild -project sandtetris.xcodeproj -scheme sandtetris -destination 'platform=iOS Simulator,name=iPhone 15' run
```

#### Running Tests

```bash
# Unit tests
xcodebuild test -project sandtetris.xcodeproj -scheme sandtetris -destination 'platform=iOS Simulator,name=iPhone 15'

# UI tests
xcodebuild test -project sandtetris.xcodeproj -scheme sandtetris -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:sandtetrisUITests
```

### Architecture

#### Core Components

- **sandtetrisApp.swift**: App entry point, sets up SwiftData ModelContainer
- **GameView.swift**: Main game view
- **GameModel.swift**: Game logic and state management
- **TetrisPiece.swift**: Tetris piece definitions and behaviors
- **DifficultySelectionView.swift**: Difficulty selection screen
- **SettingsView.swift**: Settings screen
- **HighScore.swift**: High score data model
- **AdMobManager.swift**: Ad management (Banner & Interstitial)

#### Data Flow

Persistence using SwiftData:
1. `sandtetrisApp` creates the `ModelContainer` and injects it into the view hierarchy
2. Views access data via `@Environment(\.modelContext)` and `@Query`
3. All CRUD operations go through the model context
4. SwiftData handles persistence automatically

### Project Configuration

- **Bundle Identifier**: jp.dancho.sandtetris
- **Development Team**: 6549AY6J4G
- **Deployment Target**: iOS 26.0 (※Podfile sets 17.0)
- **Supported Devices**: iPhone, iPad

### Dependencies

- Google-Mobile-Ads-SDK: For AdMob ad display

### License

Please contact the repository owner for licensing information.

---

<div align="center">

Made with ❤️ for puzzle game enthusiasts

</div>
