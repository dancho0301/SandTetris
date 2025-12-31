//
//  CoinManager.swift
//  sandtetris
//
//  Created by Claude on 2025/12/31.
//

import SwiftUI

/// ゲーム内通貨（コイン）を管理するクラス
@Observable
class CoinManager {
    /// シングルトンインスタンス
    static let shared = CoinManager()

    // UserDefaultsのキー
    private enum Keys {
        static let totalCoins = "totalCoins"
    }

    /// 現在のコイン数
    private(set) var coins: Int {
        didSet {
            UserDefaults.standard.set(coins, forKey: Keys.totalCoins)
        }
    }

    private init() {
        self.coins = UserDefaults.standard.integer(forKey: Keys.totalCoins)
    }

    /// コインを追加する
    /// - Parameter amount: 追加するコイン数
    func addCoins(_ amount: Int) {
        guard amount > 0 else { return }
        coins += amount
    }

    /// コインを消費する
    /// - Parameter amount: 消費するコイン数
    /// - Returns: 消費に成功したかどうか
    @discardableResult
    func spendCoins(_ amount: Int) -> Bool {
        guard amount > 0, coins >= amount else { return false }
        coins -= amount
        return true
    }

    /// 指定額を支払えるかチェック
    /// - Parameter amount: チェックする金額
    /// - Returns: 支払い可能かどうか
    func canAfford(_ amount: Int) -> Bool {
        return coins >= amount
    }

    /// コイン数をリセット（デバッグ用）
    func resetCoins() {
        coins = 0
    }
}
