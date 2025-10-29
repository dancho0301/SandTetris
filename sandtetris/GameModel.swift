//
//  GameModel.swift
//  sandtetris
//
//  Created by dancho on 2025/10/26.
//

import Foundation
import SwiftUI

// セルの種類
enum CellType: Equatable {
    case empty
    case sand(Color)
    case tetrisPiece(Color)
}

// ゲーム状態
enum GameState {
    case ready
    case playing
    case paused
    case gameOver
}

@Observable
class GameModel {
    // テトリスピースのグリッドサイズ（論理的なサイズ）
    static var pieceGridWidth: Int {
        return max(10, GameSettings.shared.gameAreaWidth)
    }
    static var pieceGridHeight: Int {
        let aspectRatio = max(1.0, GameSettings.shared.gameAreaAspectRatio)
        let height = Int(ceil(Double(pieceGridWidth) * aspectRatio))
        return max(15, height)  // 最小高さ15を保証
    }

    // 粒子の細分化レベル（1ピースセルをN×Nの粒子に分割）
    static let particleSubdivision = 12

    // 実際の粒子グリッドサイズ（物理的なサイズ）
    static var gridWidth: Int {
        return pieceGridWidth * particleSubdivision
    }
    static var gridHeight: Int {
        return pieceGridHeight * particleSubdivision
    }

    // ゲーム状態
    var gameState: GameState = .ready
    var score: Int = 0
    var currentLevel: Int = 1 // 現在のレベル
    var grid: [[CellType]] = Array(repeating: Array(repeating: .empty, count: gridWidth), count: gridHeight)

    // グリッドの実際のサイズを保存（配列範囲チェック用）
    private var currentGridWidth: Int = 0
    private var currentGridHeight: Int = 0

    // 難易度設定（使用する色の数）
    var colorCount: Int = 3

    // 現在のピース
    var currentPiece: TetrisPiece?
    var currentPosition: (x: Int, y: Int) = (0, 0)

    // 次のピース
    var nextPiece: TetrisPiece?

    // タイマー
    private var gameTimer: Timer?
    private let tickInterval: TimeInterval = 0.016 // 約60fps
    private var accumulatedTime: TimeInterval = 0
    private var fallSpeed: TimeInterval = 1.0 // 1秒ごとにピースが落下（スコアに応じて変化）

    // 新しいピース出現の待機時間
    private var pieceSpawnDelay: TimeInterval = 1.0 // 2秒
    private var pieceSpawnTimer: TimeInterval = 0
    private var waitingForNextPiece: Bool = false

    // 砂の静止判定用
    private var sandStableFrames: Int = 0
    private let stableFramesThreshold: Int = 30 // 約0.5秒間変化がなければ静止とみなす

    init() {
        setupNewGame()
    }

    // 新しいゲームのセットアップ
    func setupNewGame() {
        // 現在のグリッドサイズを更新
        currentGridWidth = GameModel.gridWidth
        currentGridHeight = GameModel.gridHeight

        grid = Array(repeating: Array(repeating: .empty, count: currentGridWidth), count: currentGridHeight)
        score = 0
        currentLevel = 1
        updateFallSpeed() // 初期の落下速度を設定
        currentPiece = TetrisPiece.random(colorCount: colorCount)
        nextPiece = TetrisPiece.random(colorCount: colorCount)
        currentPosition = (x: GameModel.pieceGridWidth / 2 - 1, y: 0)
        gameState = .ready
    }

    // 色数（難易度）を変更
    func setColorCount(_ count: Int) {
        colorCount = min(max(count, 2), 7) // 2〜7色の範囲
    }

    // ゲーム開始
    func startGame() {
        gameState = .playing
        startTimer()
    }

    // ゲーム一時停止
    func pauseGame() {
        gameState = .paused
        stopTimer()
    }

    // ゲーム再開
    func resumeGame() {
        gameState = .playing
        startTimer()
    }

    // タイマー開始
    private func startTimer() {
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { [weak self] _ in
            self?.update()
        }
    }

    // タイマー停止
    private func stopTimer() {
        gameTimer?.invalidate()
        gameTimer = nil
    }

    // ゲームループ更新
    private func update() {
        guard gameState == .playing else { return }

        // 新しいピースの出現待機中
        if waitingForNextPiece {
            pieceSpawnTimer += tickInterval
            if pieceSpawnTimer >= pieceSpawnDelay {
                pieceSpawnTimer = 0
                waitingForNextPiece = false
                spawnNextPiece()
            }
        } else {
            accumulatedTime += tickInterval

            // ピースの自動落下
            if accumulatedTime >= fallSpeed {
                accumulatedTime = 0
                moveDown()
            }
        }

        // 砂の物理シミュレーション（3倍の速度で実行）
        var sandHasChanged = false
        for _ in 0..<3 {
            if updateSandPhysics() {
                sandHasChanged = true
            }
        }

        // 砂の静止判定
        if sandHasChanged {
            // 砂が動いている場合はカウンターをリセット
            sandStableFrames = 0
        } else {
            // 砂が動いていない場合はカウンターを増やす
            sandStableFrames += 1

            // 一定フレーム数砂が動かなかったら、完全に静止したとみなして消去チェック
            if sandStableFrames == stableFramesThreshold {
                checkAndClearLines()
                // チェック後もカウンターを維持（連続チェックを防ぐ）
            }
        }

        // 砂が画面上部まで詰まったかチェック
        checkGameOverBySandOverflow()
    }

    // 砂の物理シミュレーション（変化があったかどうかを返す）
    private func updateSandPhysics() -> Bool {
        var hasChanged = false

        // グリッドサイズが変更されている場合は処理をスキップ
        guard currentGridWidth > 0 && currentGridHeight > 0 &&
              grid.count == currentGridHeight &&
              grid[0].count == currentGridWidth else {
            return false
        }

        // 下の行から順に処理（砂が下に落ちる）
        for y in stride(from: currentGridHeight - 2, through: 0, by: -1) {
            for x in 0..<currentGridWidth {
                if case .sand(let color) = grid[y][x] {
                    // 真下が空なら落下
                    if grid[y + 1][x] == .empty {
                        grid[y + 1][x] = .sand(color)
                        grid[y][x] = .empty
                        hasChanged = true
                    }
                    // 真下が埋まっている場合、斜め下をチェック
                    else {
                        let canMoveLeft = x > 0 && grid[y + 1][x - 1] == .empty
                        let canMoveRight = x < currentGridWidth - 1 && grid[y + 1][x + 1] == .empty

                        if canMoveLeft && canMoveRight {
                            // 両方空いている場合はランダムに選択
                            let moveLeft = Bool.random()
                            if moveLeft {
                                grid[y + 1][x - 1] = .sand(color)
                                grid[y][x] = .empty
                            } else {
                                grid[y + 1][x + 1] = .sand(color)
                                grid[y][x] = .empty
                            }
                            hasChanged = true
                        } else if canMoveLeft {
                            grid[y + 1][x - 1] = .sand(color)
                            grid[y][x] = .empty
                            hasChanged = true
                        } else if canMoveRight {
                            grid[y + 1][x + 1] = .sand(color)
                            grid[y][x] = .empty
                            hasChanged = true
                        }
                    }
                }
            }
        }

        return hasChanged
    }

    // ピースを左に移動
    func moveLeft() {
        guard gameState == .playing, let piece = currentPiece else { return }
        let newPosition = (x: currentPosition.x - 1, y: currentPosition.y)
        if canPlacePiece(piece, at: newPosition) {
            currentPosition = newPosition
        }
    }

    // ピースを右に移動
    func moveRight() {
        guard gameState == .playing, let piece = currentPiece else { return }
        let newPosition = (x: currentPosition.x + 1, y: currentPosition.y)
        if canPlacePiece(piece, at: newPosition) {
            currentPosition = newPosition
        }
    }

    // ピースを下に移動
    func moveDown() {
        guard gameState == .playing, let piece = currentPiece else { return }
        let newPosition = (x: currentPosition.x, y: currentPosition.y + 1)

        if canPlacePiece(piece, at: newPosition) {
            currentPosition = newPosition
        } else {
            // ピースを固定して砂に変換
            lockPiece()
        }
    }

    // ピースを即座に落下
    func hardDrop() {
        guard gameState == .playing, let piece = currentPiece else { return }

        while canPlacePiece(piece, at: (x: currentPosition.x, y: currentPosition.y + 1)) {
            currentPosition.y += 1
        }

        lockPiece()
    }

    // ピースを回転
    func rotate() {
        guard gameState == .playing, var piece = currentPiece else { return }
        piece.rotate()

        if canPlacePiece(piece, at: currentPosition) {
            currentPiece = piece
        }
    }

    // ピースを配置できるかチェック
    private func canPlacePiece(_ piece: TetrisPiece, at position: (x: Int, y: Int)) -> Bool {
        for (dy, row) in piece.shape.enumerated() {
            for (dx, cell) in row.enumerated() {
                if cell {
                    let gridX = position.x + dx
                    let gridY = position.y + dy

                    // グリッド外チェック（ピースグリッド座標系）
                    if gridX < 0 || gridX >= GameModel.pieceGridWidth || gridY >= GameModel.pieceGridHeight {
                        return false
                    }

                    // 上端は許可（ピースが出現する場所）
                    if gridY < 0 {
                        continue
                    }

                    // 衝突チェック（粒子グリッドをチェック）
                    if !canPlacePieceCell(at: (x: gridX, y: gridY)) {
                        return false
                    }
                }
            }
        }
        return true
    }

    // 外部からピースを配置できるかチェック（公開メソッド）
    func canPlacePieceAt(_ piece: TetrisPiece, position: (x: Int, y: Int)) -> Bool {
        return canPlacePiece(piece, at: position)
    }

    // ピースの位置を直接設定（公開メソッド）
    func setPosition(_ position: (x: Int, y: Int)) {
        currentPosition = position
    }

    // ピースの1セルが配置可能かチェック（粒子レベルで）
    private func canPlacePieceCell(at position: (x: Int, y: Int)) -> Bool {
        // グリッドサイズが変更されている場合は配置不可
        guard currentGridWidth > 0 && currentGridHeight > 0 &&
              grid.count == currentGridHeight &&
              grid[0].count == currentGridWidth else {
            return false
        }

        let baseX = position.x * GameModel.particleSubdivision
        let baseY = position.y * GameModel.particleSubdivision

        // ピースが占める領域に砂粒子があるかチェック
        for dy in 0..<GameModel.particleSubdivision {
            for dx in 0..<GameModel.particleSubdivision {
                let particleX = baseX + dx
                let particleY = baseY + dy

                if particleY >= 0 && particleY < currentGridHeight &&
                   particleX >= 0 && particleX < currentGridWidth {
                    if grid[particleY][particleX] != .empty {
                        return false
                    }
                }
            }
        }
        return true
    }

    // ピースを固定（砂に変換）
    private func lockPiece() {
        guard let piece = currentPiece else { return }

        // テトリスピースの各セルを細かい粒子に分割
        for (dy, row) in piece.shape.enumerated() {
            for (dx, cell) in row.enumerated() {
                if cell {
                    let gridX = currentPosition.x + dx
                    let gridY = currentPosition.y + dy

                    if gridY >= 0 && gridY < GameModel.gridHeight && gridX >= 0 && gridX < GameModel.gridWidth {
                        // 1つのピースセルを3x3の細かい粒子に分割
                        subdivideIntoParticles(at: (x: gridX, y: gridY), color: piece.color)
                    }
                }
            }
        }

        // 砂が静止するまで待ってから消去チェックを行う（update()で自動的に行われる）
        // 静止判定カウンターをリセット
        sandStableFrames = 0

        // 次のピースを生成するまで待機
        currentPiece = nil
        waitingForNextPiece = true
        pieceSpawnTimer = 0
    }

    // セルを細かい粒子に分割
    private func subdivideIntoParticles(at position: (x: Int, y: Int), color: Color) {
        // グリッドサイズが変更されている場合は処理をスキップ
        guard currentGridWidth > 0 && currentGridHeight > 0 &&
              grid.count == currentGridHeight &&
              grid[0].count == currentGridWidth else {
            return
        }

        let baseX = position.x * GameModel.particleSubdivision
        let baseY = position.y * GameModel.particleSubdivision

        for dy in 0..<GameModel.particleSubdivision {
            for dx in 0..<GameModel.particleSubdivision {
                let particleX = baseX + dx
                let particleY = baseY + dy

                if particleY >= 0 && particleY < currentGridHeight &&
                   particleX >= 0 && particleX < currentGridWidth {
                    // ランダムに一部の粒子を空にして、よりリアルな砂の見た目に
                    if Bool.random() || (dx == 1 && dy == 1) { // 中心は必ず埋める
                        grid[particleY][particleX] = .sand(color)
                    }
                }
            }
        }
    }

    // ラインのチェックと消去（砂テトリスルール：左から右に同じ色が繋がったら消える）
    private func checkAndClearLines() {
        // グリッドサイズが変更されている場合は処理をスキップ
        guard currentGridWidth > 0 && currentGridHeight > 0 &&
              grid.count == currentGridHeight &&
              grid[0].count == currentGridWidth else {
            return
        }

        var cellsToRemove: Set<String> = []

        // 全ての行について、左から右への繋がりをチェック
        for y in 0..<currentGridHeight {
            guard case .sand(let color) = grid[y][0] else { continue }

            // この行で左端から繋がっている同じ色のセルを探索
            var connectedCells: Set<String> = []
            var reachedRight = false

            floodFillHorizontal(from: (x: 0, y: y), color: color, visited: &connectedCells, reachedRight: &reachedRight)

            // 右端まで繋がっていたら消去対象に追加
            if reachedRight {
                cellsToRemove.formUnion(connectedCells)
            }
        }

        // 消去対象のセルを削除
        var particlesCleared = 0
        for cellKey in cellsToRemove {
            let components = cellKey.split(separator: ",")
            if let x = Int(components[0]), let y = Int(components[1]) {
                grid[y][x] = .empty
                particlesCleared += 1
            }
        }

        if particlesCleared > 0 {
            score += particlesCleared
            updateFallSpeed() // スコアに応じて落下速度を更新
        }
    }

    // 水平方向（左から右）に繋がっている同じ色のセルを探索（縦横斜めに広がりながら）
    private func floodFillHorizontal(from position: (x: Int, y: Int), color: Color, visited: inout Set<String>, reachedRight: inout Bool) {
        let cellKey = "\(position.x),\(position.y)"

        // 既に訪問済み、または範囲外ならスキップ
        if visited.contains(cellKey) ||
           position.y < 0 || position.y >= currentGridHeight ||
           position.x < 0 || position.x >= currentGridWidth {
            return
        }

        // 同じ色の砂でなければスキップ
        guard case .sand(let cellColor) = grid[position.y][position.x],
              areColorsEqual(cellColor, color) else {
            return
        }

        // 訪問済みに追加
        visited.insert(cellKey)

        // 右端に到達したかチェック
        if position.x == currentGridWidth - 1 {
            reachedRight = true
        }

        // 8方向に探索（上下左右＋斜め4方向）
        floodFillHorizontal(from: (x: position.x + 1, y: position.y), color: color, visited: &visited, reachedRight: &reachedRight)
        floodFillHorizontal(from: (x: position.x - 1, y: position.y), color: color, visited: &visited, reachedRight: &reachedRight)
        floodFillHorizontal(from: (x: position.x, y: position.y + 1), color: color, visited: &visited, reachedRight: &reachedRight)
        floodFillHorizontal(from: (x: position.x, y: position.y - 1), color: color, visited: &visited, reachedRight: &reachedRight)
        // 斜め4方向を追加
        floodFillHorizontal(from: (x: position.x + 1, y: position.y + 1), color: color, visited: &visited, reachedRight: &reachedRight)
        floodFillHorizontal(from: (x: position.x + 1, y: position.y - 1), color: color, visited: &visited, reachedRight: &reachedRight)
        floodFillHorizontal(from: (x: position.x - 1, y: position.y + 1), color: color, visited: &visited, reachedRight: &reachedRight)
        floodFillHorizontal(from: (x: position.x - 1, y: position.y - 1), color: color, visited: &visited, reachedRight: &reachedRight)
    }

    // 2つの色が等しいかチェック
    private func areColorsEqual(_ color1: Color, _ color2: Color) -> Bool {
        // SwiftUIのColorを比較するため、UIColorに変換して比較
        #if canImport(UIKit)
        let uiColor1 = UIColor(color1)
        let uiColor2 = UIColor(color2)
        return uiColor1 == uiColor2
        #else
        return true // macOSの場合は簡略化
        #endif
    }

    // スコアに応じた落下速度とレベルを計算
    private func updateFallSpeed() {
        // スコアに応じてレベルを計算（500点ごとにレベルアップ）
        currentLevel = max(1, (score / 500) + 1)

        // レベルに応じて落下速度を設定
        // Level 1: 1.0秒
        // Level 2: 0.85秒
        // Level 3: 0.72秒
        // Level 4: 0.61秒
        // Level 5: 0.52秒
        // Level 6: 0.44秒
        // Level 7: 0.37秒
        // Level 8: 0.31秒
        // Level 9: 0.26秒
        // Level 10以上: 0.15秒（最速）
        let baseSpeed = 1.0
        let minSpeed = 0.15
        let maxLevel = 10

        if currentLevel >= maxLevel {
            fallSpeed = minSpeed
        } else {
            // 指数関数的に速度を上げる
            let progress = Double(currentLevel - 1) / Double(maxLevel - 1)
            let speedReduction = pow(progress, 1.5) * (baseSpeed - minSpeed)
            fallSpeed = max(minSpeed, baseSpeed - speedReduction)
        }
    }

    // 砂が画面上部まで詰まったかチェック
    private func checkGameOverBySandOverflow() {
        // グリッドサイズが変更されている場合は処理をスキップ
        guard currentGridWidth > 0 && currentGridHeight > 0 &&
              grid.count == currentGridHeight &&
              grid[0].count == currentGridWidth else {
            return
        }

        // ピースが生成される上部エリア（ピースグリッド座標で上から3行分）をチェック
        let checkRows = 3 // ピースグリッド座標での行数
        let checkHeight = checkRows * GameModel.particleSubdivision // 粒子グリッド座標での行数

        // 上部エリアの砂粒子をカウント
        var sandCount = 0
        let totalCells = currentGridWidth * checkHeight

        for y in 0..<min(checkHeight, currentGridHeight) {
            for x in 0..<currentGridWidth {
                if case .sand(_) = grid[y][x] {
                    sandCount += 1
                }
            }
        }

        // 上部エリアの50%以上が砂で埋まっている場合はゲームオーバー
        let fillRatio = Double(sandCount) / Double(totalCells)
        if fillRatio >= 0.5 {
            gameState = .gameOver
            stopTimer()
        }
    }

    // 次のピースを生成
    private func spawnNextPiece() {
        currentPiece = nextPiece
        nextPiece = TetrisPiece.random(colorCount: colorCount)
        currentPosition = (x: GameModel.pieceGridWidth / 2 - 1, y: 0)

        // ゲームオーバーチェック
        if let piece = currentPiece, !canPlacePiece(piece, at: currentPosition) {
            gameState = .gameOver
            stopTimer()
        }
    }

    deinit {
        stopTimer()
    }
}
