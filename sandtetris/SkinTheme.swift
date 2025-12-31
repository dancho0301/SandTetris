//
//  SkinTheme.swift
//  sandtetris
//
//  Created by Claude on 2025/12/31.
//

import SwiftUI

/// スキンテーマの定義
struct SkinTheme: Identifiable, Codable, Equatable {
    let id: String
    let nameKey: String
    let descriptionKey: String
    let price: Int
    let category: SkinCategory

    // 砂の色パレット（7色）
    let sandColors: [CodableColor]

    // 背景グラデーション
    let backgroundColors: [CodableColor]

    // グリッド線の色
    let gridLineColor: CodableColor

    // ゲームオーバーラインの色
    let gameOverLineColor: CodableColor

    // プレビュー用のメイン色
    var previewColor: Color {
        sandColors.first?.color ?? .blue
    }

    static func == (lhs: SkinTheme, rhs: SkinTheme) -> Bool {
        lhs.id == rhs.id
    }
}

/// スキンのカテゴリ
enum SkinCategory: String, CaseIterable, Codable {
    case basic = "basic"
    case nature = "nature"
    case neon = "neon"
    case seasonal = "seasonal"
    case premium = "premium"

    var nameKey: String {
        return "skin_category_\(rawValue)"
    }

    var icon: String {
        switch self {
        case .basic: return "circle.grid.2x2.fill"
        case .nature: return "leaf.fill"
        case .neon: return "sparkles"
        case .seasonal: return "snowflake"
        case .premium: return "crown.fill"
        }
    }
}

/// Colorを永続化するためのCodable対応ラッパー
struct CodableColor: Codable, Equatable {
    let red: Double
    let green: Double
    let blue: Double
    let opacity: Double

    init(_ color: Color) {
        let uiColor = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.red = Double(r)
        self.green = Double(g)
        self.blue = Double(b)
        self.opacity = Double(a)
    }

    init(red: Double, green: Double, blue: Double, opacity: Double = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.opacity = opacity
    }

    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: opacity)
    }
}

/// 全スキンの定義
struct SkinCatalog {

    // MARK: - デフォルトスキン（無料）

    static let defaultSkin = SkinTheme(
        id: "default",
        nameKey: "skin_default_name",
        descriptionKey: "skin_default_desc",
        price: 0,
        category: .basic,
        sandColors: [
            CodableColor(red: 0.0, green: 0.8, blue: 0.8),   // シアン
            CodableColor(red: 1.0, green: 0.8, blue: 0.0),   // イエロー
            CodableColor(red: 0.6, green: 0.4, blue: 0.8),   // パープル
            CodableColor(red: 0.4, green: 0.8, blue: 0.4),   // グリーン
            CodableColor(red: 1.0, green: 0.4, blue: 0.4),   // レッド
            CodableColor(red: 0.4, green: 0.6, blue: 1.0),   // ブルー
            CodableColor(red: 1.0, green: 0.6, blue: 0.2)    // オレンジ
        ],
        backgroundColors: [
            CodableColor(red: 0.15, green: 0.15, blue: 0.2),
            CodableColor(red: 0.1, green: 0.1, blue: 0.15)
        ],
        gridLineColor: CodableColor(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.15),
        gameOverLineColor: CodableColor(red: 1.0, green: 0.0, blue: 0.0, opacity: 0.6)
    )

    // MARK: - Basicスキン

    static let pastelDream = SkinTheme(
        id: "pastel_dream",
        nameKey: "skin_pastel_dream_name",
        descriptionKey: "skin_pastel_dream_desc",
        price: 100,
        category: .basic,
        sandColors: [
            CodableColor(red: 1.0, green: 0.7, blue: 0.7),   // パステルピンク
            CodableColor(red: 1.0, green: 0.9, blue: 0.7),   // パステルイエロー
            CodableColor(red: 0.7, green: 1.0, blue: 0.7),   // パステルグリーン
            CodableColor(red: 0.7, green: 0.85, blue: 1.0),  // パステルブルー
            CodableColor(red: 0.9, green: 0.7, blue: 1.0),   // パステルパープル
            CodableColor(red: 1.0, green: 0.8, blue: 0.6),   // パステルオレンジ
            CodableColor(red: 0.7, green: 1.0, blue: 0.9)    // パステルミント
        ],
        backgroundColors: [
            CodableColor(red: 0.95, green: 0.9, blue: 1.0),
            CodableColor(red: 1.0, green: 0.95, blue: 0.95)
        ],
        gridLineColor: CodableColor(red: 0.8, green: 0.7, blue: 0.9, opacity: 0.3),
        gameOverLineColor: CodableColor(red: 1.0, green: 0.5, blue: 0.5, opacity: 0.6)
    )

    static let monochrome = SkinTheme(
        id: "monochrome",
        nameKey: "skin_monochrome_name",
        descriptionKey: "skin_monochrome_desc",
        price: 100,
        category: .basic,
        sandColors: [
            CodableColor(red: 1.0, green: 1.0, blue: 1.0),
            CodableColor(red: 0.85, green: 0.85, blue: 0.85),
            CodableColor(red: 0.7, green: 0.7, blue: 0.7),
            CodableColor(red: 0.55, green: 0.55, blue: 0.55),
            CodableColor(red: 0.4, green: 0.4, blue: 0.4),
            CodableColor(red: 0.25, green: 0.25, blue: 0.25),
            CodableColor(red: 0.1, green: 0.1, blue: 0.1)
        ],
        backgroundColors: [
            CodableColor(red: 0.12, green: 0.12, blue: 0.12),
            CodableColor(red: 0.05, green: 0.05, blue: 0.05)
        ],
        gridLineColor: CodableColor(red: 0.3, green: 0.3, blue: 0.3, opacity: 0.3),
        gameOverLineColor: CodableColor(red: 0.8, green: 0.8, blue: 0.8, opacity: 0.6)
    )

    // MARK: - Natureスキン

    static let forest = SkinTheme(
        id: "forest",
        nameKey: "skin_forest_name",
        descriptionKey: "skin_forest_desc",
        price: 150,
        category: .nature,
        sandColors: [
            CodableColor(red: 0.2, green: 0.5, blue: 0.2),   // ダークグリーン
            CodableColor(red: 0.4, green: 0.7, blue: 0.3),   // グリーン
            CodableColor(red: 0.6, green: 0.8, blue: 0.4),   // ライトグリーン
            CodableColor(red: 0.5, green: 0.35, blue: 0.2),  // ブラウン
            CodableColor(red: 0.9, green: 0.85, blue: 0.6),  // ベージュ
            CodableColor(red: 0.8, green: 0.6, blue: 0.3),   // オレンジブラウン
            CodableColor(red: 0.3, green: 0.6, blue: 0.5)    // ティール
        ],
        backgroundColors: [
            CodableColor(red: 0.1, green: 0.15, blue: 0.1),
            CodableColor(red: 0.05, green: 0.1, blue: 0.05)
        ],
        gridLineColor: CodableColor(red: 0.3, green: 0.5, blue: 0.3, opacity: 0.2),
        gameOverLineColor: CodableColor(red: 0.8, green: 0.3, blue: 0.2, opacity: 0.6)
    )

    static let ocean = SkinTheme(
        id: "ocean",
        nameKey: "skin_ocean_name",
        descriptionKey: "skin_ocean_desc",
        price: 150,
        category: .nature,
        sandColors: [
            CodableColor(red: 0.0, green: 0.3, blue: 0.6),   // ディープブルー
            CodableColor(red: 0.0, green: 0.5, blue: 0.8),   // オーシャンブルー
            CodableColor(red: 0.3, green: 0.7, blue: 0.9),   // スカイブルー
            CodableColor(red: 0.0, green: 0.6, blue: 0.6),   // ティール
            CodableColor(red: 0.5, green: 0.9, blue: 0.9),   // アクア
            CodableColor(red: 0.9, green: 0.95, blue: 1.0),  // フォーム
            CodableColor(red: 0.2, green: 0.4, blue: 0.5)    // ダークティール
        ],
        backgroundColors: [
            CodableColor(red: 0.0, green: 0.1, blue: 0.2),
            CodableColor(red: 0.0, green: 0.05, blue: 0.15)
        ],
        gridLineColor: CodableColor(red: 0.3, green: 0.5, blue: 0.7, opacity: 0.2),
        gameOverLineColor: CodableColor(red: 1.0, green: 0.5, blue: 0.3, opacity: 0.6)
    )

    static let sunset = SkinTheme(
        id: "sunset",
        nameKey: "skin_sunset_name",
        descriptionKey: "skin_sunset_desc",
        price: 150,
        category: .nature,
        sandColors: [
            CodableColor(red: 1.0, green: 0.3, blue: 0.2),   // レッド
            CodableColor(red: 1.0, green: 0.5, blue: 0.2),   // オレンジ
            CodableColor(red: 1.0, green: 0.7, blue: 0.3),   // ゴールド
            CodableColor(red: 1.0, green: 0.85, blue: 0.4),  // イエロー
            CodableColor(red: 0.8, green: 0.4, blue: 0.6),   // ピンク
            CodableColor(red: 0.5, green: 0.3, blue: 0.6),   // パープル
            CodableColor(red: 0.3, green: 0.2, blue: 0.4)    // ダークパープル
        ],
        backgroundColors: [
            CodableColor(red: 0.2, green: 0.1, blue: 0.15),
            CodableColor(red: 0.1, green: 0.05, blue: 0.1)
        ],
        gridLineColor: CodableColor(red: 1.0, green: 0.6, blue: 0.4, opacity: 0.15),
        gameOverLineColor: CodableColor(red: 1.0, green: 0.3, blue: 0.3, opacity: 0.6)
    )

    // MARK: - Neonスキン

    static let cyberpunk = SkinTheme(
        id: "cyberpunk",
        nameKey: "skin_cyberpunk_name",
        descriptionKey: "skin_cyberpunk_desc",
        price: 200,
        category: .neon,
        sandColors: [
            CodableColor(red: 1.0, green: 0.0, blue: 0.5),   // ホットピンク
            CodableColor(red: 0.0, green: 1.0, blue: 1.0),   // シアン
            CodableColor(red: 1.0, green: 1.0, blue: 0.0),   // イエロー
            CodableColor(red: 0.5, green: 0.0, blue: 1.0),   // パープル
            CodableColor(red: 0.0, green: 1.0, blue: 0.5),   // ネオングリーン
            CodableColor(red: 1.0, green: 0.5, blue: 0.0),   // オレンジ
            CodableColor(red: 0.0, green: 0.5, blue: 1.0)    // ブルー
        ],
        backgroundColors: [
            CodableColor(red: 0.05, green: 0.0, blue: 0.1),
            CodableColor(red: 0.0, green: 0.0, blue: 0.05)
        ],
        gridLineColor: CodableColor(red: 0.5, green: 0.0, blue: 1.0, opacity: 0.3),
        gameOverLineColor: CodableColor(red: 1.0, green: 0.0, blue: 0.5, opacity: 0.8)
    )

    static let retroWave = SkinTheme(
        id: "retro_wave",
        nameKey: "skin_retro_wave_name",
        descriptionKey: "skin_retro_wave_desc",
        price: 200,
        category: .neon,
        sandColors: [
            CodableColor(red: 1.0, green: 0.4, blue: 0.8),   // ピンク
            CodableColor(red: 0.4, green: 0.8, blue: 1.0),   // ライトブルー
            CodableColor(red: 0.8, green: 0.4, blue: 1.0),   // パープル
            CodableColor(red: 1.0, green: 0.6, blue: 0.2),   // オレンジ
            CodableColor(red: 0.2, green: 1.0, blue: 0.8),   // ミント
            CodableColor(red: 1.0, green: 1.0, blue: 0.4),   // イエロー
            CodableColor(red: 0.6, green: 0.2, blue: 0.8)    // ディープパープル
        ],
        backgroundColors: [
            CodableColor(red: 0.15, green: 0.0, blue: 0.2),
            CodableColor(red: 0.05, green: 0.0, blue: 0.1)
        ],
        gridLineColor: CodableColor(red: 1.0, green: 0.4, blue: 0.8, opacity: 0.2),
        gameOverLineColor: CodableColor(red: 0.4, green: 0.8, blue: 1.0, opacity: 0.8)
    )

    // MARK: - Seasonalスキン

    static let sakura = SkinTheme(
        id: "sakura",
        nameKey: "skin_sakura_name",
        descriptionKey: "skin_sakura_desc",
        price: 250,
        category: .seasonal,
        sandColors: [
            CodableColor(red: 1.0, green: 0.75, blue: 0.8),  // ライトピンク
            CodableColor(red: 1.0, green: 0.6, blue: 0.7),   // ピンク
            CodableColor(red: 0.95, green: 0.85, blue: 0.9), // ペールピンク
            CodableColor(red: 1.0, green: 0.9, blue: 0.95),  // ホワイトピンク
            CodableColor(red: 0.8, green: 0.5, blue: 0.6),   // ダスティピンク
            CodableColor(red: 0.6, green: 0.8, blue: 0.6),   // グリーン（葉）
            CodableColor(red: 0.5, green: 0.35, blue: 0.3)   // ブラウン（枝）
        ],
        backgroundColors: [
            CodableColor(red: 0.95, green: 0.9, blue: 0.92),
            CodableColor(red: 1.0, green: 0.95, blue: 0.97)
        ],
        gridLineColor: CodableColor(red: 1.0, green: 0.7, blue: 0.8, opacity: 0.3),
        gameOverLineColor: CodableColor(red: 0.9, green: 0.4, blue: 0.5, opacity: 0.6)
    )

    static let winter = SkinTheme(
        id: "winter",
        nameKey: "skin_winter_name",
        descriptionKey: "skin_winter_desc",
        price: 250,
        category: .seasonal,
        sandColors: [
            CodableColor(red: 1.0, green: 1.0, blue: 1.0),   // ホワイト
            CodableColor(red: 0.85, green: 0.92, blue: 1.0), // アイスブルー
            CodableColor(red: 0.7, green: 0.85, blue: 0.95), // ライトブルー
            CodableColor(red: 0.5, green: 0.7, blue: 0.9),   // スカイブルー
            CodableColor(red: 0.9, green: 0.95, blue: 1.0),  // スノーホワイト
            CodableColor(red: 0.6, green: 0.75, blue: 0.85), // フロストブルー
            CodableColor(red: 0.4, green: 0.55, blue: 0.7)   // ウィンターブルー
        ],
        backgroundColors: [
            CodableColor(red: 0.15, green: 0.2, blue: 0.3),
            CodableColor(red: 0.1, green: 0.15, blue: 0.25)
        ],
        gridLineColor: CodableColor(red: 0.7, green: 0.85, blue: 1.0, opacity: 0.2),
        gameOverLineColor: CodableColor(red: 0.5, green: 0.7, blue: 1.0, opacity: 0.6)
    )

    // MARK: - Premiumスキン

    static let galaxy = SkinTheme(
        id: "galaxy",
        nameKey: "skin_galaxy_name",
        descriptionKey: "skin_galaxy_desc",
        price: 500,
        category: .premium,
        sandColors: [
            CodableColor(red: 0.9, green: 0.8, blue: 1.0),   // ネビュラピンク
            CodableColor(red: 0.5, green: 0.3, blue: 0.9),   // ディープパープル
            CodableColor(red: 0.3, green: 0.5, blue: 1.0),   // コズミックブルー
            CodableColor(red: 1.0, green: 0.9, blue: 0.5),   // スターゴールド
            CodableColor(red: 0.2, green: 0.8, blue: 0.8),   // ティール
            CodableColor(red: 1.0, green: 0.5, blue: 0.7),   // ピンク
            CodableColor(red: 0.4, green: 0.2, blue: 0.6)    // ダークパープル
        ],
        backgroundColors: [
            CodableColor(red: 0.05, green: 0.02, blue: 0.15),
            CodableColor(red: 0.02, green: 0.0, blue: 0.08)
        ],
        gridLineColor: CodableColor(red: 0.5, green: 0.3, blue: 0.8, opacity: 0.2),
        gameOverLineColor: CodableColor(red: 1.0, green: 0.5, blue: 0.7, opacity: 0.7)
    )

    static let golden = SkinTheme(
        id: "golden",
        nameKey: "skin_golden_name",
        descriptionKey: "skin_golden_desc",
        price: 500,
        category: .premium,
        sandColors: [
            CodableColor(red: 1.0, green: 0.84, blue: 0.0),  // ゴールド
            CodableColor(red: 0.85, green: 0.65, blue: 0.13),// ダークゴールド
            CodableColor(red: 1.0, green: 0.93, blue: 0.55), // ライトゴールド
            CodableColor(red: 0.8, green: 0.5, blue: 0.2),   // ブロンズ
            CodableColor(red: 0.95, green: 0.9, blue: 0.8),  // クリーム
            CodableColor(red: 0.6, green: 0.45, blue: 0.2),  // ダークブロンズ
            CodableColor(red: 1.0, green: 0.95, blue: 0.7)   // シャンパン
        ],
        backgroundColors: [
            CodableColor(red: 0.15, green: 0.1, blue: 0.05),
            CodableColor(red: 0.08, green: 0.05, blue: 0.02)
        ],
        gridLineColor: CodableColor(red: 1.0, green: 0.84, blue: 0.0, opacity: 0.2),
        gameOverLineColor: CodableColor(red: 1.0, green: 0.6, blue: 0.2, opacity: 0.7)
    )

    // MARK: - 全スキン一覧

    static let allSkins: [SkinTheme] = [
        // Basic
        defaultSkin,
        pastelDream,
        monochrome,
        // Nature
        forest,
        ocean,
        sunset,
        // Neon
        cyberpunk,
        retroWave,
        // Seasonal
        sakura,
        winter,
        // Premium
        galaxy,
        golden
    ]

    static func skin(for id: String) -> SkinTheme? {
        allSkins.first { $0.id == id }
    }

    static func skins(for category: SkinCategory) -> [SkinTheme] {
        allSkins.filter { $0.category == category }
    }
}
