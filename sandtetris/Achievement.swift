//
//  Achievement.swift
//  sandtetris
//
//  Created by Claude on 2025/12/31.
//

import SwiftUI

/// アチーブメントの種類
enum AchievementType: String, CaseIterable, Codable {
    // スコア系
    case score100 = "score_100"
    case score500 = "score_500"
    case score1000 = "score_1000"
    case score5000 = "score_5000"
    case score10000 = "score_10000"

    // レベル系
    case level3 = "level_3"
    case level5 = "level_5"
    case level10 = "level_10"
    case level20 = "level_20"

    // プレイ回数系
    case play1 = "play_1"
    case play10 = "play_10"
    case play50 = "play_50"
    case play100 = "play_100"

    // 連続ログイン系
    case streak3 = "streak_3"
    case streak7 = "streak_7"
    case streak14 = "streak_14"
    case streak30 = "streak_30"

    // 難易度系
    case easyMode = "easy_mode"
    case hardMode = "hard_mode"
    case hardScore1000 = "hard_score_1000"

    /// アチーブメント名（ローカライズキー）
    var nameKey: String {
        return "achievement_\(rawValue)_name"
    }

    /// アチーブメント説明（ローカライズキー）
    var descriptionKey: String {
        return "achievement_\(rawValue)_desc"
    }

    /// アイコン
    var icon: String {
        switch self {
        case .score100, .score500, .score1000, .score5000, .score10000:
            return "star.fill"
        case .level3, .level5, .level10, .level20:
            return "arrow.up.circle.fill"
        case .play1, .play10, .play50, .play100:
            return "gamecontroller.fill"
        case .streak3, .streak7, .streak14, .streak30:
            return "flame.fill"
        case .easyMode, .hardMode, .hardScore1000:
            return "trophy.fill"
        }
    }

    /// アイコンカラー
    var iconColor: Color {
        switch self {
        case .score100, .score500:
            return .yellow
        case .score1000, .score5000, .score10000:
            return .orange
        case .level3, .level5:
            return .green
        case .level10, .level20:
            return .mint
        case .play1, .play10:
            return .blue
        case .play50, .play100:
            return .purple
        case .streak3, .streak7:
            return .orange
        case .streak14, .streak30:
            return .red
        case .easyMode:
            return .green
        case .hardMode, .hardScore1000:
            return .red
        }
    }

    /// 報酬コイン数
    var rewardCoins: Int {
        switch self {
        case .score100: return 10
        case .score500: return 20
        case .score1000: return 50
        case .score5000: return 100
        case .score10000: return 200

        case .level3: return 15
        case .level5: return 30
        case .level10: return 75
        case .level20: return 150

        case .play1: return 5
        case .play10: return 25
        case .play50: return 75
        case .play100: return 150

        case .streak3: return 20
        case .streak7: return 50
        case .streak14: return 100
        case .streak30: return 250

        case .easyMode: return 10
        case .hardMode: return 30
        case .hardScore1000: return 100
        }
    }

    /// カテゴリ
    var category: AchievementCategory {
        switch self {
        case .score100, .score500, .score1000, .score5000, .score10000:
            return .score
        case .level3, .level5, .level10, .level20:
            return .level
        case .play1, .play10, .play50, .play100:
            return .play
        case .streak3, .streak7, .streak14, .streak30:
            return .streak
        case .easyMode, .hardMode, .hardScore1000:
            return .difficulty
        }
    }
}

/// アチーブメントのカテゴリ
enum AchievementCategory: String, CaseIterable {
    case score = "score"
    case level = "level"
    case play = "play"
    case streak = "streak"
    case difficulty = "difficulty"

    var nameKey: String {
        return "achievement_category_\(rawValue)"
    }

    var achievements: [AchievementType] {
        AchievementType.allCases.filter { $0.category == self }
    }
}

/// アチーブメントの達成状態
struct AchievementState: Codable {
    var isUnlocked: Bool = false
    var isRewardClaimed: Bool = false
    var unlockedDate: Date? = nil
}
