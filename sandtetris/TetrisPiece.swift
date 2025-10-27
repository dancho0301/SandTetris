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

    // カスタム形状用のイニシャライザ
    init(shape: [[Bool]], color: Color) {
        self.shape = shape
        self.color = color
        self.type = .i // ダミーの型（カスタム形状では使用しない）
    }

    static func random(colorCount: Int = 3) -> TetrisPiece {
        // 2〜6個のマスからなるランダムな形状を生成
        let cellCount = Int.random(in: 2...6)
        let shape = generateRandomShape(cellCount: cellCount)

        // 色は指定された色数の範囲からランダムに選択
        let availableColors = Array(colorPalette.prefix(colorCount))
        let color = availableColors.randomElement()!

        return TetrisPiece(shape: shape, color: color)
    }

    // ランダムな形状を生成（cellCount個のマスを連結）
    private static func generateRandomShape(cellCount: Int) -> [[Bool]] {
        // 座標のセット（連結したマスの位置）
        var cells: Set<Position> = []

        // 最初のマスを追加
        cells.insert(Position(x: 0, y: 0))

        // 残りのマスを隣接する位置に追加
        for _ in 1..<cellCount {
            // 既存のマスに隣接可能な位置をすべて取得
            var candidates: Set<Position> = []
            for cell in cells {
                // 上下左右の隣接位置を候補に追加
                let adjacent = [
                    Position(x: cell.x - 1, y: cell.y),
                    Position(x: cell.x + 1, y: cell.y),
                    Position(x: cell.x, y: cell.y - 1),
                    Position(x: cell.x, y: cell.y + 1)
                ]
                for pos in adjacent {
                    if !cells.contains(pos) {
                        candidates.insert(pos)
                    }
                }
            }

            // 候補からランダムに1つ選んで追加
            if let newCell = candidates.randomElement() {
                cells.insert(newCell)
            }
        }

        // 座標を正規化（最小値が0になるように）
        let minX = cells.map { $0.x }.min() ?? 0
        let minY = cells.map { $0.y }.min() ?? 0
        let normalizedCells = cells.map { Position(x: $0.x - minX, y: $0.y - minY) }

        // 2次元配列に変換
        let maxX = normalizedCells.map { $0.x }.max() ?? 0
        let maxY = normalizedCells.map { $0.y }.max() ?? 0

        var shape = Array(repeating: Array(repeating: false, count: maxX + 1), count: maxY + 1)
        for cell in normalizedCells {
            shape[cell.y][cell.x] = true
        }

        return shape
    }

    // 座標を表す構造体
    private struct Position: Hashable {
        let x: Int
        let y: Int
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
