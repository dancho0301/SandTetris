//
//  DailyBonusManager.swift
//  sandtetris
//
//  Created by Claude on 2025/12/31.
//

import SwiftUI

/// デイリーボーナスを管理するクラス
@Observable
class DailyBonusManager {
    /// シングルトンインスタンス
    static let shared = DailyBonusManager()

    // UserDefaultsのキー
    private enum Keys {
        static let lastClaimDate = "dailyBonusLastClaimDate"
        static let currentStreak = "dailyBonusCurrentStreak"
        static let longestStreak = "dailyBonusLongestStreak"
        static let totalClaims = "dailyBonusTotalClaims"
    }

    /// 最後にボーナスを受け取った日付
    private(set) var lastClaimDate: Date? {
        didSet {
            if let date = lastClaimDate {
                UserDefaults.standard.set(date, forKey: Keys.lastClaimDate)
            } else {
                UserDefaults.standard.removeObject(forKey: Keys.lastClaimDate)
            }
        }
    }

    /// 現在の連続ログイン日数
    private(set) var currentStreak: Int {
        didSet {
            UserDefaults.standard.set(currentStreak, forKey: Keys.currentStreak)
        }
    }

    /// 最長連続ログイン日数
    private(set) var longestStreak: Int {
        didSet {
            UserDefaults.standard.set(longestStreak, forKey: Keys.longestStreak)
        }
    }

    /// 累計受け取り回数
    private(set) var totalClaims: Int {
        didSet {
            UserDefaults.standard.set(totalClaims, forKey: Keys.totalClaims)
        }
    }

    /// 7日間のボーナス報酬
    static let weeklyBonuses: [Int] = [10, 20, 30, 50, 70, 100, 150]

    /// 今日ボーナスを受け取れるかどうか
    var canClaimToday: Bool {
        guard let lastClaim = lastClaimDate else { return true }
        return !Calendar.current.isDateInToday(lastClaim)
    }

    /// 今日受け取れるボーナス量
    var todayBonus: Int {
        let dayIndex = currentStreak % DailyBonusManager.weeklyBonuses.count
        return DailyBonusManager.weeklyBonuses[dayIndex]
    }

    /// 次の日のボーナス量（プレビュー用）
    var nextDayBonus: Int {
        let nextDayIndex = (currentStreak + 1) % DailyBonusManager.weeklyBonuses.count
        return DailyBonusManager.weeklyBonuses[nextDayIndex]
    }

    /// 現在のウィーク内の日数（1〜7）
    var currentDayInWeek: Int {
        return (currentStreak % 7) + 1
    }

    private init() {
        self.lastClaimDate = UserDefaults.standard.object(forKey: Keys.lastClaimDate) as? Date
        self.currentStreak = UserDefaults.standard.integer(forKey: Keys.currentStreak)
        self.longestStreak = UserDefaults.standard.integer(forKey: Keys.longestStreak)
        self.totalClaims = UserDefaults.standard.integer(forKey: Keys.totalClaims)

        // 連続ログインが途切れていないかチェック
        checkStreakContinuity()
    }

    /// 連続ログインの継続性をチェック
    private func checkStreakContinuity() {
        guard let lastClaim = lastClaimDate else { return }

        let calendar = Calendar.current

        // 昨日かどうかをチェック
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: Date())) {
            let lastClaimDay = calendar.startOfDay(for: lastClaim)

            // 昨日より前なら連続が途切れた
            if lastClaimDay < yesterday {
                currentStreak = 0
            }
        }
    }

    /// デイリーボーナスを受け取る
    /// - Returns: 受け取ったコイン数（受け取れなかった場合は0）
    @discardableResult
    func claimDailyBonus() -> Int {
        guard canClaimToday else { return 0 }

        let bonus = todayBonus

        // コインを追加
        CoinManager.shared.addCoins(bonus)

        // ステータスを更新
        lastClaimDate = Date()
        currentStreak += 1
        totalClaims += 1

        // 最長記録を更新
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }

        return bonus
    }

    /// 次のボーナス受け取り可能時刻までの残り時間
    var timeUntilNextBonus: TimeInterval? {
        guard !canClaimToday else { return nil }

        let calendar = Calendar.current
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date())) {
            return tomorrow.timeIntervalSinceNow
        }
        return nil
    }

    /// リセット（デバッグ用）
    func reset() {
        lastClaimDate = nil
        currentStreak = 0
        totalClaims = 0
    }
}
