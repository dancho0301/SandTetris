//
//  sandtetrisTests.swift
//  sandtetrisTests
//
//  Created by dancho on 2025/10/26.
//

import Testing
import SwiftUI
@testable import sandtetris

struct sandtetrisTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

    // MARK: - レスポンシブ対応テスト

    /// グリッドサイズが異なるアスペクト比で正しく計算されることをテスト
    @Test func testGridSizeCalculation() async throws {
        // テスト前の設定を保存
        let originalWidth = GameSettings.shared.gameAreaWidth
        let originalAspectRatio = GameSettings.shared.gameAreaAspectRatio

        // iPhone SE (縦向き) のアスペクト比 (375x667)
        GameSettings.shared.gameAreaAspectRatio = 667.0 / 375.0 // ≈1.78
        GameSettings.shared.gameAreaWidth = 10

        let seHeight = GameModel.pieceGridHeight
        #expect(seHeight >= 15, "iPhone SEの高さは最低15セル以上必要")
        #expect(seHeight >= 17, "iPhone SEの高さは約17-18セル程度")

        // iPhone 15 Pro Max (縦向き) のアスペクト比 (430x932)
        GameSettings.shared.gameAreaAspectRatio = 932.0 / 430.0 // ≈2.17
        GameSettings.shared.gameAreaWidth = 10

        let proMaxHeight = GameModel.pieceGridHeight
        #expect(proMaxHeight >= 15, "iPhone 15 Pro Maxの高さは最低15セル以上必要")
        #expect(proMaxHeight >= 21, "iPhone 15 Pro Maxの高さは約21-22セル程度")

        // iPad mini (縦向き) のアスペクト比 (744x1133)
        GameSettings.shared.gameAreaAspectRatio = 1133.0 / 744.0 // ≈1.52
        GameSettings.shared.gameAreaWidth = 10

        let iPadHeight = GameModel.pieceGridHeight
        #expect(iPadHeight >= 15, "iPad miniの高さは最低15セル以上必要")

        // 横向きモード (16:9)
        GameSettings.shared.gameAreaAspectRatio = 9.0 / 16.0 // ≈0.56
        GameSettings.shared.gameAreaWidth = 10

        let landscapeHeight = GameModel.pieceGridHeight
        #expect(landscapeHeight >= 15, "横向きでも最低15セル以上必要")

        // 正方形 (1:1)
        GameSettings.shared.gameAreaAspectRatio = 1.0
        GameSettings.shared.gameAreaWidth = 10

        let squareHeight = GameModel.pieceGridHeight
        #expect(squareHeight >= 15, "正方形でも最低15セル以上必要")

        // 設定を元に戻す
        GameSettings.shared.gameAreaWidth = originalWidth
        GameSettings.shared.gameAreaAspectRatio = originalAspectRatio
    }

    /// 粒子グリッドサイズが正しく計算されることをテスト
    @Test func testParticleGridSize() async throws {
        // 粒子の細分化レベルが12であることを確認
        #expect(GameModel.particleSubdivision == 12, "粒子の細分化レベルは12である必要がある")

        // ピースグリッドが10x15の場合
        GameSettings.shared.gameAreaWidth = 10
        GameSettings.shared.gameAreaAspectRatio = 1.5

        let pieceWidth = GameModel.pieceGridWidth
        let pieceHeight = GameModel.pieceGridHeight

        let particleWidth = GameModel.gridWidth
        let particleHeight = GameModel.gridHeight

        // 粒子グリッドはピースグリッドの12倍であることを確認
        #expect(particleWidth == pieceWidth * 12, "粒子グリッドの幅はピースグリッドの12倍")
        #expect(particleHeight == pieceHeight * 12, "粒子グリッドの高さはピースグリッドの12倍")
    }

    /// GameModelが異なる画面サイズで正しく初期化されることをテスト
    @Test func testGameModelInitializationWithDifferentScreenSizes() async throws {
        // テスト前の設定を保存
        let originalWidth = GameSettings.shared.gameAreaWidth
        let originalAspectRatio = GameSettings.shared.gameAreaAspectRatio

        // 小さい画面（iPhone SE）
        GameSettings.shared.gameAreaWidth = 10
        GameSettings.shared.gameAreaAspectRatio = 1.78

        let smallModel = GameModel()
        #expect(smallModel.grid.count > 0, "グリッドが初期化されている")
        #expect(smallModel.grid[0].count > 0, "グリッドの各行が初期化されている")
        #expect(smallModel.currentPiece != nil, "現在のピースが初期化されている")
        #expect(smallModel.nextPiece != nil, "次のピースが初期化されている")

        // 大きい画面（iPad）
        GameSettings.shared.gameAreaWidth = 10
        GameSettings.shared.gameAreaAspectRatio = 1.33

        let largeModel = GameModel()
        #expect(largeModel.grid.count > 0, "グリッドが初期化されている")
        #expect(largeModel.grid[0].count > 0, "グリッドの各行が初期化されている")
        #expect(largeModel.currentPiece != nil, "現在のピースが初期化されている")
        #expect(largeModel.nextPiece != nil, "次のピースが初期化されている")

        // 横向き
        GameSettings.shared.gameAreaWidth = 10
        GameSettings.shared.gameAreaAspectRatio = 0.56

        let landscapeModel = GameModel()
        #expect(landscapeModel.grid.count > 0, "グリッドが初期化されている")
        #expect(landscapeModel.grid[0].count > 0, "グリッドの各行が初期化されている")

        // 設定を元に戻す
        GameSettings.shared.gameAreaWidth = originalWidth
        GameSettings.shared.gameAreaAspectRatio = originalAspectRatio
    }

    /// ピースが画面サイズに関わらず正しく配置できることをテスト
    @Test func testPiecePlacementAcrossScreenSizes() async throws {
        // テスト前の設定を保存
        let originalWidth = GameSettings.shared.gameAreaWidth
        let originalAspectRatio = GameSettings.shared.gameAreaAspectRatio

        let testCases: [(width: Int, aspectRatio: Double, name: String)] = [
            (10, 1.78, "iPhone SE"),
            (10, 2.17, "iPhone 15 Pro Max"),
            (10, 1.33, "iPad"),
            (10, 0.56, "横向き")
        ]

        for testCase in testCases {
            GameSettings.shared.gameAreaWidth = testCase.width
            GameSettings.shared.gameAreaAspectRatio = testCase.aspectRatio

            let model = GameModel()

            // ピースが初期位置に配置できることを確認
            #expect(model.currentPiece != nil, "\(testCase.name): 現在のピースが存在する")

            if let piece = model.currentPiece {
                let canPlace = model.canPlacePieceAt(piece, position: model.currentPosition)
                #expect(canPlace, "\(testCase.name): ピースが初期位置に配置できる")

                // ピースを左端に移動できるか
                let leftPosition = (x: 0, y: model.currentPosition.y)
                let canPlaceLeft = model.canPlacePieceAt(piece, position: leftPosition)
                #expect(canPlaceLeft, "\(testCase.name): ピースが左端に配置できる")

                // ピースを右端に移動できるか
                let pieceWidth = piece.shape[0].count
                let rightPosition = (x: GameModel.pieceGridWidth - pieceWidth, y: model.currentPosition.y)
                let canPlaceRight = model.canPlacePieceAt(piece, position: rightPosition)
                #expect(canPlaceRight, "\(testCase.name): ピースが右端に配置できる")
            }
        }

        // 設定を元に戻す
        GameSettings.shared.gameAreaWidth = originalWidth
        GameSettings.shared.gameAreaAspectRatio = originalAspectRatio
    }

    /// ゲームオーバーラインが画面サイズに関わらず正しく機能することをテスト
    @Test func testGameOverLineAcrossScreenSizes() async throws {
        // ゲームオーバーラインが常に上から3行目であることを確認
        #expect(GameModel.gameOverLineRow == 3, "ゲームオーバーラインはピースグリッドの上から3行目")

        // 異なる画面サイズでゲームオーバーラインの位置が一貫していることを確認
        let originalWidth = GameSettings.shared.gameAreaWidth
        let originalAspectRatio = GameSettings.shared.gameAreaAspectRatio

        GameSettings.shared.gameAreaWidth = 10
        GameSettings.shared.gameAreaAspectRatio = 1.78
        let lineRow1 = GameModel.gameOverLineRow

        GameSettings.shared.gameAreaWidth = 10
        GameSettings.shared.gameAreaAspectRatio = 2.17
        let lineRow2 = GameModel.gameOverLineRow

        #expect(lineRow1 == lineRow2, "ゲームオーバーラインの位置は画面サイズに関わらず一貫している")

        // 設定を元に戻す
        GameSettings.shared.gameAreaWidth = originalWidth
        GameSettings.shared.gameAreaAspectRatio = originalAspectRatio
    }

}
