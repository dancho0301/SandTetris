//
//  AchievementManager.swift
//  sandtetris
//
//  Created by Claude on 2025/12/31.
//

import SwiftUI

/// アチーブメントを管理するクラス
@Observable
class AchievementManager {
    /// シングルトンインスタンス
    static let shared = AchievementManager()

    // UserDefaultsのキー
    private enum Keys {
        static let achievementStates = "achievementStates"
        static let totalPlayCount = "totalPlayCount"
        static let highestScore = "highestScore"
        static let highestLevel = "highestLevel"
    }

    /// 各アチーブメントの状態
    private(set) var states: [AchievementType: AchievementState] = [:]

    /// 累計プレイ回数
    private(set) var totalPlayCount: Int {
        didSet {
            UserDefaults.standard.set(totalPlayCount, forKey: Keys.totalPlayCount)
        }
    }

    /// 最高スコア
    private(set) var highestScore: Int {
        didSet {
            UserDefaults.standard.set(highestScore, forKey: Keys.highestScore)
        }
    }

    /// 最高レベル
    private(set) var highestLevel: Int {
        didSet {
            UserDefaults.standard.set(highestLevel, forKey: Keys.highestLevel)
        }
    }

    /// 最近解除されたアチーブメント（通知用）
    var recentlyUnlocked: [AchievementType] = []

    /// 未受け取りの報酬があるかどうか
    var hasUnclaimedRewards: Bool {
        states.values.contains { $0.isUnlocked && !$0.isRewardClaimed }
    }

    /// 未受け取りの報酬数
    var unclaimedRewardCount: Int {
        states.values.filter { $0.isUnlocked && !$0.isRewardClaimed }.count
    }

    /// 解除済みアチーブメント数
    var unlockedCount: Int {
        states.values.filter { $0.isUnlocked }.count
    }

    /// 全アチーブメント数
    var totalCount: Int {
        AchievementType.allCases.count
    }

    /// 特定カテゴリの未受領報酬数を取得
    /// - Parameter category: カテゴリ
    /// - Returns: 未受領の報酬数
    func unclaimedRewardCount(for category: AchievementCategory) -> Int {
        return category.achievements.filter { type in
            if let state = states[type] {
                return state.isUnlocked && !state.isRewardClaimed
            }
            return false
        }.count
    }

    private init() {
        self.totalPlayCount = UserDefaults.standard.integer(forKey: Keys.totalPlayCount)
        self.highestScore = UserDefaults.standard.integer(forKey: Keys.highestScore)
        self.highestLevel = UserDefaults.standard.integer(forKey: Keys.highestLevel)

        loadStates()
    }

    // MARK: - 保存/読み込み

    private func loadStates() {
        if let data = UserDefaults.standard.data(forKey: Keys.achievementStates),
           let decoded = try? JSONDecoder().decode([String: AchievementState].self, from: data) {
            for type in AchievementType.allCases {
                states[type] = decoded[type.rawValue] ?? AchievementState()
            }
        } else {
            // 初期化
            for type in AchievementType.allCases {
                states[type] = AchievementState()
            }
        }
    }

    private func saveStates() {
        var encoded: [String: AchievementState] = [:]
        for (type, state) in states {
            encoded[type.rawValue] = state
        }

        if let data = try? JSONEncoder().encode(encoded) {
            UserDefaults.standard.set(data, forKey: Keys.achievementStates)
        }
    }

    // MARK: - アチーブメント解除

    /// アチーブメントを解除する
    /// - Parameter type: 解除するアチーブメントの種類
    /// - Returns: 新しく解除されたかどうか
    @discardableResult
    func unlock(_ type: AchievementType) -> Bool {
        guard var state = states[type], !state.isUnlocked else {
            return false
        }

        state.isUnlocked = true
        state.unlockedDate = Date()
        states[type] = state
        saveStates()

        recentlyUnlocked.append(type)
        return true
    }

    /// 報酬を受け取る
    /// - Parameter type: アチーブメントの種類
    /// - Returns: 受け取ったコイン数（既に受け取り済みまたは未解除の場合は0）
    @discardableResult
    func claimReward(for type: AchievementType) -> Int {
        guard var state = states[type],
              state.isUnlocked,
              !state.isRewardClaimed else {
            return 0
        }

        state.isRewardClaimed = true
        states[type] = state
        saveStates()

        let reward = type.rewardCoins
        CoinManager.shared.addCoins(reward)
        return reward
    }

    /// 全ての未受け取り報酬を一括で受け取る
    /// - Returns: 受け取った合計コイン数
    @discardableResult
    func claimAllRewards() -> Int {
        var totalReward = 0

        for type in AchievementType.allCases {
            if let state = states[type], state.isUnlocked && !state.isRewardClaimed {
                totalReward += claimReward(for: type)
            }
        }

        return totalReward
    }

    // MARK: - ゲームイベント処理

    /// ゲーム終了時の処理
    /// - Parameters:
    ///   - score: 最終スコア
    ///   - level: 最終レベル
    ///   - colorCount: 色数（難易度）
    func onGameOver(score: Int, level: Int, colorCount: Int) {
        // プレイ回数を更新
        totalPlayCount += 1

        // 最高記録を更新
        if score > highestScore {
            highestScore = score
        }
        if level > highestLevel {
            highestLevel = level
        }

        // クリアした最近解除リスト
        recentlyUnlocked.removeAll()

        // スコアアチーブメントをチェック
        checkScoreAchievements(score: score)

        // レベルアチーブメントをチェック
        checkLevelAchievements(level: level)

        // プレイ回数アチーブメントをチェック
        checkPlayCountAchievements()

        // 難易度アチーブメントをチェック
        checkDifficultyAchievements(score: score, colorCount: colorCount)
    }

    /// 連続ログインアチーブメントをチェック
    func checkStreakAchievements(streak: Int) {
        recentlyUnlocked.removeAll()

        if streak >= 3 { unlock(.streak3) }
        if streak >= 7 { unlock(.streak7) }
        if streak >= 14 { unlock(.streak14) }
        if streak >= 30 { unlock(.streak30) }
    }

    // MARK: - 各種チェック

    private func checkScoreAchievements(score: Int) {
        if score >= 100 { unlock(.score100) }
        if score >= 500 { unlock(.score500) }
        if score >= 1000 { unlock(.score1000) }
        if score >= 5000 { unlock(.score5000) }
        if score >= 10000 { unlock(.score10000) }
    }

    private func checkLevelAchievements(level: Int) {
        if level >= 3 { unlock(.level3) }
        if level >= 5 { unlock(.level5) }
        if level >= 10 { unlock(.level10) }
        if level >= 20 { unlock(.level20) }
    }

    private func checkPlayCountAchievements() {
        if totalPlayCount >= 1 { unlock(.play1) }
        if totalPlayCount >= 10 { unlock(.play10) }
        if totalPlayCount >= 50 { unlock(.play50) }
        if totalPlayCount >= 100 { unlock(.play100) }
    }

    private func checkDifficultyAchievements(score: Int, colorCount: Int) {
        // イージーモード（3色）でプレイ
        if colorCount == 3 { unlock(.easyMode) }

        // ハードモード（7色）でプレイ
        if colorCount == 7 { unlock(.hardMode) }

        // ハードモードで1000点以上
        if colorCount == 7 && score >= 1000 { unlock(.hardScore1000) }
    }

    /// アチーブメントの状態を取得
    func getState(for type: AchievementType) -> AchievementState {
        return states[type] ?? AchievementState()
    }

    /// リセット（デバッグ用）
    func reset() {
        for type in AchievementType.allCases {
            states[type] = AchievementState()
        }
        totalPlayCount = 0
        highestScore = 0
        highestLevel = 0
        saveStates()
    }
}
