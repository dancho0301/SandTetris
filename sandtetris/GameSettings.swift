//
//  GameSettings.swift
//  sandtetris
//
//  Created by dancho on 2025/10/27.
//

import SwiftUI

/// ゲームの設定を管理するクラス
@Observable
class GameSettings {
    /// タッチ操作の方式
    enum TouchControlMode: String, CaseIterable {
        case delta = "delta"           // 移動量ベース
        case position = "position"     // 指の位置に追従

        var displayName: String {
            switch self {
            case .delta:
                return "移動量ベース"
            case .position:
                return "指の位置に追従"
            }
        }

        var description: String {
            switch self {
            case .delta:
                return "最初にタッチした位置からの移動量で操作"
            case .position:
                return "指の位置に直接ブロックが追従"
            }
        }
    }

    // UserDefaultsのキー
    private enum Keys {
        static let touchControlMode = "touchControlMode"
    }

    /// タッチ操作モード
    var touchControlMode: TouchControlMode {
        didSet {
            UserDefaults.standard.set(touchControlMode.rawValue, forKey: Keys.touchControlMode)
        }
    }

    /// シングルトンインスタンス
    static let shared = GameSettings()

    private init() {
        // UserDefaultsから設定を読み込み
        if let savedMode = UserDefaults.standard.string(forKey: Keys.touchControlMode),
           let mode = TouchControlMode(rawValue: savedMode) {
            self.touchControlMode = mode
        } else {
            // デフォルトは移動量ベース
            self.touchControlMode = .delta
        }
    }
}
