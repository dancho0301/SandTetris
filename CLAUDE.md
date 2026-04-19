# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Language Preference

**IMPORTANT: Always communicate in Japanese (日本語) with the user.**

## Project Overview

sandtetris is an iOS application built with SwiftUI and SwiftData. The project uses Xcode 26.0+ with Swift 5.0, targeting iOS 26.0+.

### Game Concept

サンドドロップ（Sand Drop）ゲームを作成するプロジェクト。既存の砂テトリスゲームは操作感が今ひとつなので、以下の点を重視して開発する：

- **手に馴染む操作感**: 直感的で快適な操作性を実現
- **日本人受けしやすいポップなデザイン**: 親しみやすく魅力的なビジュアル

## Build and Test Commands

**IMPORTANT**: This project uses Swift Package Manager (SPM) for dependencies. Open `sandtetris.xcodeproj` directly (no workspace needed).

### SPM Dependencies
- Google Mobile Ads SDK: `https://github.com/googleads/swift-package-manager-google-mobile-ads.git`
- Add via Xcode: File → Add Package Dependencies
- Xcode automatically resolves packages on first build

### Building the App
- Build the project: Open `sandtetris.xcodeproj` in Xcode and use Cmd+B
- Build via command line: `xcodebuild -project sandtetris.xcodeproj -scheme sandtetris -configuration Debug build`
- Build for release: `xcodebuild -project sandtetris.xcodeproj -scheme sandtetris -configuration Release build`

### Running Tests
- Run unit tests: `xcodebuild test -project sandtetris.xcodeproj -scheme sandtetris -destination 'platform=iOS Simulator,name=iPhone 15'`
- Run UI tests: `xcodebuild test -project sandtetris.xcodeproj -scheme sandtetris -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:sandtetrisUITests`

### Running the App
- Run in simulator: Open `sandtetris.xcodeproj` in Xcode and use Cmd+R

## Architecture

### Game Architecture

This is a sand physics simulation game with tetris pieces that decompose into sand particles.

#### Core Game Components

**GameModel.swift** - Main game state and logic
- `@Observable @MainActor class GameModel`: Core game engine with 60fps update loop
- Dual grid system:
  - Piece grid: Logical grid for tetris pieces (10×15 default)
  - Particle grid: Physical grid for sand simulation (piece grid × 12 subdivision)
- Sand physics: Gravity-based falling sand with diagonal flow
- Line clearing: Flood-fill algorithm checks for color connections from left to right edge
- Score system: Dynamic difficulty with fall speed increase every 500 points

**TetrisPiece.swift** - Tetris piece definitions
- Standard tetris shapes (I, O, T, S, Z, J, L)
- Each piece has a color from configurable palette (3, 5, or 7 colors)
- Rotation support with boundary checking

**GameView.swift** - Main game UI
- Header with score, level, next piece preview
- Game area with sand particle rendering
- Control guide and touch gesture handling
- AdMob integration (banner + interstitial)

#### Monetization System

**CoinManager.swift** - Virtual currency management
- Singleton managing coins via UserDefaults
- Earned through achievements and daily bonuses
- Used for purchasing skins

**AchievementManager.swift** - Achievement tracking
- Tracks play count, high scores, difficulty levels
- Unlocks award coins when milestones are reached
- Persists state via UserDefaults

**DailyBonusManager.swift** - Daily reward system
- Awards coins for consecutive daily logins
- Streak tracking with last claim date

**SkinManager.swift** & **SkinTheme.swift** - Visual customization
- Manages owned and selected skins
- Skins define background colors and sand particle colors
- Default skin is free, others purchasable with coins

**SkinShopView.swift** - In-game shop UI
- Purchase and select skins using coins
- Preview available and owned skins

#### Ad Integration

**AdMobManager.swift** - AdMob SDK initialization and configuration
- Shared singleton initializing Google Mobile Ads SDK on app launch
- Manages app-level ad configuration

**BannerAdView.swift** - Banner ad display
- GADBannerView wrapper as SwiftUI view
- Displayed at bottom of game screen

**InterstitialAdManager.swift** - Interstitial ad management
- Shows full-screen ads periodically (every 3 games)
- Pauses game during ad display
- Handles ad loading and presentation

#### Settings & Configuration

**GameSettings.swift** - Game configuration singleton
- Color count (difficulty: 3/5/7 colors)
- Game area dimensions and aspect ratio
- Touch control modes
- Persisted via UserDefaults

**SettingsView.swift** - Settings UI
- Color count selection
- Game reset option
- Links to achievements, daily bonus, skin shop

#### Data Models

**HighScore.swift** - SwiftData model for score persistence
- Stores score, level, play date, color count
- Queried in settings to show high scores by difficulty

**Item.swift** - Legacy SwiftData model (may be unused)

### App Structure

**sandtetrisApp.swift**
- App entry point with `@main` attribute
- Sets up SwiftData `ModelContainer` for `Item` and `HighScore` models
- Initializes AdMob on app launch
- Injects `AdMobManager` as environment object

**ContentView.swift**
- Root view presenting `DifficultySelectionView` or `GameView`
- Difficulty selection sets color count before starting game

**DifficultySelectionView.swift**
- Initial screen for choosing difficulty (3/5/7 colors)
- Launches game after selection

### Key Patterns

1. **Observable Pattern**: Game state uses Swift's `@Observable` macro for reactive UI updates
2. **Singleton Managers**: Settings, coins, achievements, skins, ads all use shared singletons
3. **SwiftData**: High scores persisted via SwiftData with ModelContainer/ModelContext
4. **UserDefaults**: Achievements, coins, skins, settings stored in UserDefaults
5. **60fps Game Loop**: Timer-based update at ~16ms intervals for smooth physics
6. **Physics Simulation**: Bottom-up iteration for sand gravity with diagonal flow

### Important Implementation Details

- **Grid Resizing**: GameModel checks grid bounds on every physics update to handle dynamic resizing
- **Piece Subdivision**: Each tetris cell becomes 12×12 sand particles when locked
- **Game Over Conditions**: (1) New piece can't spawn, (2) Sand fills top 50% of upper 3 rows
- **Line Clearing**: Only triggers after sand is stable for ~0.5 seconds (30 frames)
- **Ad Timing**: Interstitial ads show after every 3rd game over

## Project Configuration

- **Bundle Identifier**: jp.dancho.sandtetris
- **Development Team**: 6549AY6J4G
- **Deployment Target**: iOS 17.0 (Podfile), iOS 26.0 (Xcode project)
- **Swift Features**: Approachable concurrency, MainActor isolation, member import visibility
- **Supported Devices**: iPhone and iPad
- **Dependencies**: Google Mobile Ads SDK (via Swift Package Manager)

## Dependencies

### Swift Package Manager
- **Google Mobile Ads SDK**: `https://github.com/googleads/swift-package-manager-google-mobile-ads.git`
  - AdMob integration for banner and interstitial ads
  - Uses new Swift API (`MobileAds`, `BannerView`, `InterstitialAd`, `Request`)

### Important Notes
- Use `sandtetris.xcodeproj` directly (no workspace)
- Xcode Cloud works natively with SPM — no workarounds needed
- Package resolution is automatic on build
