//
//  HighScore.swift
//  sandtetris
//
//  Created by dancho on 2025/10/30.
//

import Foundation
import SwiftData

@Model
class HighScore {
    /// スコア
    var score: Int

    /// 到達レベル
    var level: Int

    /// プレイ日時
    var playDate: Date

    /// 難易度（色の数）
    var colorCount: Int

    init(score: Int, level: Int, playDate: Date = Date(), colorCount: Int) {
        self.score = score
        self.level = level
        self.playDate = playDate
        self.colorCount = colorCount
    }
}
