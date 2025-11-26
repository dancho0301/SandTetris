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

    @Test @MainActor func example() async throws {
        // 基本的なテスト例
        let settings = GameSettings.shared
        #expect(settings.gameAreaWidth >= 10, "ゲームエリアの幅は最低10")
        #expect(settings.gameAreaAspectRatio > 0, "アスペクト比は正の数")
    }

    // MARK: - レスポンシブ対応テスト

    /// グリッドサイズが異なるアスペクト比で正しく計算されることをテスト
    @Test @MainActor func testGridSizeCalculation() async throws {
        // テスト前の設定を保存
        let originalWidth = GameSettings.shared.gameAreaWidth
        let originalAspectRatio = GameSettings.shared.gameAreaAspectRatio

        // iPhone SE (縦向き) のアスペクト比 (375x667)
        GameSettings.shared.gameAreaAspectRatio = 667.0 / 375.0 // ≈1.78
        GameSettings.shared.gameAreaWidth = 10

        let seHeight = GameModel.pieceGridHeight
        #expect(seHeight >= 15, "iPhone SEの高さは最低15セル以上必要")
        #expect(seHeight == 18, "iPhone SEの高さは18セル")

        // iPhone 15 Pro Max (縦向き) のアスペクト比 (430x932)
        GameSettings.shared.gameAreaAspectRatio = 932.0 / 430.0 // ≈2.17
        GameSettings.shared.gameAreaWidth = 10

        let proMaxHeight = GameModel.pieceGridHeight
        #expect(proMaxHeight >= 15, "iPhone 15 Pro Maxの高さは最低15セル以上必要")
        #expect(proMaxHeight == 22, "iPhone 15 Pro Maxの高さは22セル")

        // iPad mini (縦向き) のアスペクト比 (744x1133)
        GameSettings.shared.gameAreaAspectRatio = 1133.0 / 744.0 // ≈1.52
        GameSettings.shared.gameAreaWidth = 10

        let iPadHeight = GameModel.pieceGridHeight
        #expect(iPadHeight >= 15, "iPad miniの高さは最低15セル以上必要")
        #expect(iPadHeight == 16, "iPad miniの高さは16セル")

        // 横向きモード (16:9)
        GameSettings.shared.gameAreaAspectRatio = 9.0 / 16.0 // ≈0.56
        GameSettings.shared.gameAreaWidth = 10

        let landscapeHeight = GameModel.pieceGridHeight
        #expect(landscapeHeight == 15, "横向きは最小値の15セル")

        // 正方形 (1:1)
        GameSettings.shared.gameAreaAspectRatio = 1.0
        GameSettings.shared.gameAreaWidth = 10

        let squareHeight = GameModel.pieceGridHeight
        #expect(squareHeight >= 15, "正方形でも最低15セル以上必要")
        #expect(squareHeight == 15, "正方形は15セル（10 * 1.0を切り上げて10、最小値15が適用される）")

        // 設定を元に戻す
        GameSettings.shared.gameAreaWidth = originalWidth
        GameSettings.shared.gameAreaAspectRatio = originalAspectRatio
    }

    /// 粒子グリッドサイズが正しく計算されることをテスト
    @Test @MainActor func testParticleGridSize() async throws {
        // テスト前の設定を保存
        let originalWidth = GameSettings.shared.gameAreaWidth
        let originalAspectRatio = GameSettings.shared.gameAreaAspectRatio

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

        // 設定を元に戻す
        GameSettings.shared.gameAreaWidth = originalWidth
        GameSettings.shared.gameAreaAspectRatio = originalAspectRatio
    }

    /// GameModelが異なる画面サイズで正しく初期化されることをテスト
    @Test @MainActor func testGameModelInitializationWithDifferentScreenSizes() async throws {
        // テスト前の設定を保存
        let originalWidth = GameSettings.shared.gameAreaWidth
        let originalAspectRatio = GameSettings.shared.gameAreaAspectRatio

        let testCases: [(width: Int, aspectRatio: Double, name: String)] = [
            (10, 1.78, "iPhone SE"),
            (10, 1.33, "iPad"),
            (10, 0.56, "横向き")
        ]

        for testCase in testCases {
            GameSettings.shared.gameAreaWidth = testCase.width
            GameSettings.shared.gameAreaAspectRatio = testCase.aspectRatio

            let model = GameModel()

            // グリッドの基本チェック
            #expect(model.grid.count > 0, "\(testCase.name): グリッドが初期化されている")
            #expect(model.grid[0].count > 0, "\(testCase.name): グリッドの各行が初期化されている")

            // グリッドサイズが期待通りか
            let expectedHeight = GameModel.gridHeight
            let expectedWidth = GameModel.gridWidth
            #expect(model.grid.count == expectedHeight, "\(testCase.name): グリッドの高さが正しい")
            #expect(model.grid[0].count == expectedWidth, "\(testCase.name): グリッドの幅が正しい")

            // ピースの初期化チェック
            #expect(model.currentPiece != nil, "\(testCase.name): 現在のピースが初期化されている")
            #expect(model.nextPiece != nil, "\(testCase.name): 次のピースが初期化されている")

            // ゲーム状態の初期値チェック
            #expect(model.gameState == .ready, "\(testCase.name): 初期状態はready")
            #expect(model.score == 0, "\(testCase.name): 初期スコアは0")
            #expect(model.currentLevel == 1, "\(testCase.name): 初期レベルは1")
        }

        // 設定を元に戻す
        GameSettings.shared.gameAreaWidth = originalWidth
        GameSettings.shared.gameAreaAspectRatio = originalAspectRatio
    }

    /// ピースが画面サイズに関わらず正しく配置できることをテスト
    @Test @MainActor func testPiecePlacementAcrossScreenSizes() async throws {
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
    @Test @MainActor func testGameOverLineAcrossScreenSizes() async throws {
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

    // MARK: - 設定値テスト

    /// GameSettingsのデフォルト値が正しいことをテスト
    @Test @MainActor func testGameSettingsDefaults() async throws {
        let settings = GameSettings.shared

        // 基本的な制約のチェック
        #expect(settings.gameAreaWidth >= 10 && settings.gameAreaWidth <= 30,
                "ゲームエリアの幅は10〜30の範囲内")
        #expect(settings.gameAreaAspectRatio > 0,
                "アスペクト比は正の数")
        #expect(settings.colorCount >= 2 && settings.colorCount <= 7,
                "色の数は2〜7の範囲内")
        #expect(settings.movementSensitivity >= 0.5 && settings.movementSensitivity <= 2.0,
                "移動感度は0.5〜2.0の範囲内")
    }

    /// ゲームの定数が正しく定義されていることをテスト
    @Test @MainActor func testGameConstants() async throws {
        // 粒子細分化レベル
        #expect(GameModel.particleSubdivision == 12,
                "粒子細分化レベルは12")

        // ゲームオーバーライン
        #expect(GameModel.gameOverLineRow == 3,
                "ゲームオーバーラインは3行目")
        #expect(GameModel.gameOverLineRow >= 0,
                "ゲームオーバーラインは0以上")

        // グリッドサイズの最小値
        #expect(GameModel.pieceGridWidth >= 10,
                "ピースグリッドの幅は最低10")
        #expect(GameModel.pieceGridHeight >= 15,
                "ピースグリッドの高さは最低15")
    }

}
