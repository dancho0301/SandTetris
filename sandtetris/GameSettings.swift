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
        static let movementSensitivity = "movementSensitivity"
        static let gameAreaWidth = "gameAreaWidth"
        static let gameAreaAspectRatio = "gameAreaAspectRatio"
    }

    /// タッチ操作モード
    var touchControlMode: TouchControlMode {
        didSet {
            UserDefaults.standard.set(touchControlMode.rawValue, forKey: Keys.touchControlMode)
        }
    }

    /// 移動操作の感度（0.5〜2.0）
    var movementSensitivity: Double {
        didSet {
            UserDefaults.standard.set(movementSensitivity, forKey: Keys.movementSensitivity)
        }
    }

    /// ゲームエリアの横幅（マス数：10〜30）
    var gameAreaWidth: Int {
        didSet {
            UserDefaults.standard.set(gameAreaWidth, forKey: Keys.gameAreaWidth)
        }
    }

    /// ゲームエリアのアスペクト比（高さ / 幅）
    var gameAreaAspectRatio: Double {
        didSet {
            UserDefaults.standard.set(gameAreaAspectRatio, forKey: Keys.gameAreaAspectRatio)
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

        // 感度設定を読み込み
        let savedSensitivity = UserDefaults.standard.double(forKey: Keys.movementSensitivity)
        if savedSensitivity > 0 {
            self.movementSensitivity = savedSensitivity
        } else {
            // デフォルトは1.0（標準）
            self.movementSensitivity = 1.0
        }

        // ゲームエリア横幅を読み込み
        let savedWidth = UserDefaults.standard.integer(forKey: Keys.gameAreaWidth)
        if savedWidth >= 10 && savedWidth <= 30 {
            self.gameAreaWidth = savedWidth
        } else {
            // デフォルトは20
            self.gameAreaWidth = 20
        }

        // ゲームエリアアスペクト比を読み込み
        let savedAspectRatio = UserDefaults.standard.double(forKey: Keys.gameAreaAspectRatio)
        if savedAspectRatio > 0 {
            self.gameAreaAspectRatio = savedAspectRatio
        } else {
            // デフォルトは1.5（3:2の比率）
            self.gameAreaAspectRatio = 1.5
        }
    }
}
