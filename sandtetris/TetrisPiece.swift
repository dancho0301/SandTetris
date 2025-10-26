//
//  TetrisPiece.swift
//  sandtetris
//
//  Created by dancho on 2025/10/26.
//

import SwiftUI

struct TetrisPiece {
    var shape: [[Bool]]
    var color: Color
    var type: PieceType

    enum PieceType: CaseIterable {
        case i, o, t, s, z, j, l

        var shape: [[Bool]] {
            switch self {
            case .i:
                return [
                    [true, true, true, true]
                ]
            case .o:
                return [
                    [true, true],
                    [true, true]
                ]
            case .t:
                return [
                    [false, true, false],
                    [true, true, true]
                ]
            case .s:
                return [
                    [false, true, true],
                    [true, true, false]
                ]
            case .z:
                return [
                    [true, true, false],
                    [false, true, true]
                ]
            case .j:
                return [
                    [true, false, false],
                    [true, true, true]
                ]
            case .l:
                return [
                    [false, false, true],
                    [true, true, true]
                ]
            }
        }
    }

    // 利用可能な色のパレット
    static let colorPalette: [Color] = [
        Color(red: 0.4, green: 0.8, blue: 1.0), // シアン
        Color(red: 1.0, green: 0.9, blue: 0.3), // イエロー
        Color(red: 0.8, green: 0.4, blue: 1.0), // パープル
        Color(red: 0.5, green: 1.0, blue: 0.5), // グリーン
        Color(red: 1.0, green: 0.4, blue: 0.4), // レッド
        Color(red: 0.3, green: 0.5, blue: 1.0), // ブルー
        Color(red: 1.0, green: 0.6, blue: 0.3)  // オレンジ
    ]

    init(type: PieceType, color: Color) {
        self.type = type
        self.shape = type.shape
        self.color = color
    }

    static func random(colorCount: Int = 3) -> TetrisPiece {
        // 形状はランダムに選択（全ての形状から）
        let type = PieceType.allCases.randomElement()!

        // 色は指定された色数の範囲からランダムに選択
        let availableColors = Array(colorPalette.prefix(colorCount))
        let color = availableColors.randomElement()!

        return TetrisPiece(type: type, color: color)
    }

    // 時計回りに90度回転
    mutating func rotate() {
        let rows = shape.count
        let cols = shape[0].count

        var rotated = Array(repeating: Array(repeating: false, count: rows), count: cols)

        for y in 0..<rows {
            for x in 0..<cols {
                rotated[x][rows - 1 - y] = shape[y][x]
            }
        }

        shape = rotated
    }

    // 回転後の形状を取得（元の形状は変更しない）
    func rotated() -> TetrisPiece {
        var copy = self
        copy.rotate()
        return copy
    }
}
