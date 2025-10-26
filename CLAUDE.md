# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Language Preference

**IMPORTANT: Always communicate in Japanese (日本語) with the user.**

## Project Overview

sandtetris is an iOS application built with SwiftUI and SwiftData. The project uses Xcode 26.0+ with Swift 5.0, targeting iOS 26.0+.

### Game Concept

砂テトリス（Sand Tetris）ゲームを作成するプロジェクト。既存の砂テトリスゲームは操作感が今ひとつなので、以下の点を重視して開発する：

- **手に馴染む操作感**: 直感的で快適な操作性を実現
- **日本人受けしやすいポップなデザイン**: 親しみやすく魅力的なビジュアル

## Build and Test Commands

### Building the App
- Build the project: Open `sandtetris.xcodeproj` in Xcode and use Cmd+B, or use `xcodebuild -project sandtetris.xcodeproj -scheme sandtetris -configuration Debug build`
- Build for release: `xcodebuild -project sandtetris.xcodeproj -scheme sandtetris -configuration Release build`

### Running Tests
- Run unit tests: `xcodebuild test -project sandtetris.xcodeproj -scheme sandtetris -destination 'platform=iOS Simulator,name=iPhone 15'`
- Run specific test: `xcodebuild test -project sandtetris.xcodeproj -scheme sandtetris -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:sandtetrisTests/sandtetrisTests/example`
- Run UI tests: `xcodebuild test -project sandtetris.xcodeproj -scheme sandtetris -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:sandtetrisUITests`

### Running the App
- Run in simulator: Open project in Xcode and use Cmd+R, or `xcodebuild -project sandtetris.xcodeproj -scheme sandtetris -destination 'platform=iOS Simulator,name=iPhone 15' run`

## Architecture

### Core Components

**sandtetrisApp.swift** (sandtetris/sandtetrisApp.swift:12-32)
- Main app entry point using `@main` attribute
- Sets up SwiftData `ModelContainer` with the `Item` schema
- Configures persistent storage (not in-memory)
- Injects model container into the SwiftUI environment via `.modelContainer()` modifier

**ContentView.swift** (sandtetris/ContentView.swift:11-61)
- Main view displaying a list of items with timestamps
- Uses `NavigationSplitView` for iPad-optimized layout
- Accesses SwiftData via `@Environment(\.modelContext)` and `@Query`
- Implements add/delete operations with animations

**Item.swift** (sandtetris/Item.swift:11-18)
- SwiftData model marked with `@Model` macro
- Simple data structure containing only a timestamp property
- Represents the core data entity in the app

### Data Flow

The app uses SwiftData for persistence:
1. `sandtetrisApp` creates the `ModelContainer` and injects it into the view hierarchy
2. `ContentView` accesses the model context and queries items automatically
3. All CRUD operations on `Item` objects go through the model context
4. SwiftData handles persistence automatically

### Test Structure

- **sandtetrisTests/**: Unit tests using Swift Testing framework (`@Test` attribute)
- **sandtetrisUITests/**: UI tests for end-to-end testing

## Project Configuration

- **Bundle Identifier**: jp.dancho.sandtetris
- **Development Team**: 6549AY6J4G
- **Deployment Target**: iOS 26.0
- **Swift Features**: Approachable concurrency, MainActor isolation, member import visibility
- **Supported Devices**: iPhone and iPad (1,2)
