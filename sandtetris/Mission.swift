//
//  Mission.swift
//  sandtetris
//
//  Created by Claude on 2026/01/01.
//

import Foundation

/// ミッションの状態
enum MissionState {
    case active      // 進行中
    case completed   // 成功
    case failed      // 失敗
}

/// ミッション
struct Mission {
    let targetLines: Int        // 目標ライン数
    let timeLimit: TimeInterval // 制限時間（秒）
    var remainingTime: TimeInterval // 残り時間
    var clearedLines: Int       // クリア済みライン数
    var state: MissionState     // ミッション状態

    init(targetLines: Int, timeLimit: TimeInterval) {
        self.targetLines = targetLines
        self.timeLimit = timeLimit
        self.remainingTime = timeLimit
        self.clearedLines = 0
        self.state = .active
    }

    /// 残り時間の割合（0.0〜1.0）
    var timeProgress: Double {
        return remainingTime / timeLimit
    }

    /// クリア進捗の割合（0.0〜1.0）
    var clearProgress: Double {
        return Double(clearedLines) / Double(targetLines)
    }

    /// ミッションが完了したか
    var isCompleted: Bool {
        return clearedLines >= targetLines
    }

    /// 時間切れか
    var isTimeUp: Bool {
        return remainingTime <= 0
    }

    /// 残りライン数
    var remainingLines: Int {
        return max(0, targetLines - clearedLines)
    }
}

/// ミッション生成器
struct MissionGenerator {
    /// 難易度に応じたミッションを生成
    static func generate(level: Int, colorCount: Int) -> Mission {
        // レベルに応じて目標ライン数と制限時間を調整
        let baseTargetLines = 3
        let baseTimeLimit: TimeInterval = 60.0

        // レベルが上がるほど目標ライン数が緩やかに増え、時間が緩やかに短くなる
        // 2レベルごとに目標ライン数+1
        let targetLines = baseTargetLines + (level - 1) / 2
        // レベルごとに3秒減少（以前は5秒）
        let timeReduction = Double(level - 1) * 3.0
        // 最低40秒を保証（以前は30秒）
        let timeLimit = max(40.0, baseTimeLimit - timeReduction)

        // 色数（難易度）による調整
        let colorMultiplier: Double
        switch colorCount {
        case 3:  // Easy
            colorMultiplier = 1.2  // 時間を20%増やす
        case 5:  // Normal
            colorMultiplier = 1.0
        case 7:  // Hard
            colorMultiplier = 0.8  // 時間を20%減らす
        default:
            colorMultiplier = 1.0
        }

        let adjustedTimeLimit = timeLimit * colorMultiplier

        return Mission(targetLines: targetLines, timeLimit: adjustedTimeLimit)
    }
}
