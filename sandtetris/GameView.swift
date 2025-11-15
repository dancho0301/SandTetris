//
//  GameView.swift
//  sandtetris
//
//  Created by dancho on 2025/10/26.
//

import SwiftUI
import SwiftData
import GoogleMobileAds

struct GameView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var gameModel = GameModel()
    @State private var showSettings = false
    @State private var needsReset = false
    @State private var settings = GameSettings.shared
    @StateObject private var interstitialAdManager = InterstitialAdManager()

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // ヘッダー部分（スコア、レベル、次のピース、設定ボタン）
                HeaderView(
                    score: gameModel.score,
                    level: gameModel.currentLevel,
                    nextPiece: gameModel.nextPiece,
                    onSettingsTapped: {
                        showSettings = true
                    }
                )
                .frame(height: geometry.size.height * 0.12)
                .padding(.horizontal)
                .padding(.top, 8)

                // ゲームエリア（砂とテトリスピースが表示される）
                GameAreaView(
                    gameModel: gameModel,
                    interstitialAdManager: interstitialAdManager
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.15, green: 0.15, blue: 0.2),
                                Color(red: 0.1, green: 0.1, blue: 0.15)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(16)
                    .padding()

                // 操作ガイド
                ControlGuideView(touchControlMode: settings.touchControlMode)
                    .padding(.bottom, 8)

                // バナー広告
                BannerAdView()
                    .padding(.bottom, 8)
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.95, green: 0.95, blue: 1.0), Color(red: 1.0, green: 0.95, blue: 0.95)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .onAppear {
            gameModel.modelContext = modelContext
            gameModel.startGame()
        }
        .sheet(isPresented: $showSettings, onDismiss: {
            // ユーザーが「リセットする」を選択した場合のみゲームをリセット
            if needsReset {
                gameModel.setupNewGame()
                gameModel.startGame()
                needsReset = false
            }
        }) {
            SettingsView(needsReset: $needsReset)
        }
        .onChange(of: showSettings) { oldValue, newValue in
            // 設定画面が表示されたらゲームを一時停止
            if newValue {
                gameModel.pauseGame()
            }
            // 設定画面が閉じられたらゲームを再開（ただしゲームオーバーでない場合のみ）
            else if gameModel.gameState == .paused {
                gameModel.resumeGame()
            }
        }
        .onChange(of: interstitialAdManager.isShowingAd) { oldValue, newValue in
            // 広告が表示されたらゲームを一時停止
            if newValue {
                gameModel.pauseGame()
                print("広告表示中：ゲームを一時停止")
            }
            // 広告が閉じられたらゲームを再開（ただしゲームオーバーでない場合のみ）
            else if gameModel.gameState == .paused {
                gameModel.resumeGame()
                print("広告終了：ゲームを再開")
            }
        }
    }
}

// ヘッダービュー（スコア、レベル、次のピース表示、設定ボタン）
struct HeaderView: View {
    let score: Int
    let level: Int
    let nextPiece: TetrisPiece?
    let onSettingsTapped: () -> Void

    var body: some View {
        HStack(spacing: 20) {
            // レベル表示
            VStack(alignment: .leading, spacing: 2) {
                Text("LEVEL")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.orange)
                Text("\(level)")
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundColor(.orange)
                    .shadow(color: .orange.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.orange.opacity(0.15))
                    .shadow(color: .orange.opacity(0.2), radius: 4, x: 0, y: 2)
            )

            // スコア表示
            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizedStringKey("header_score"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(score)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // 次のピース表示
            VStack(spacing: 4) {
                Text(LocalizedStringKey("header_next_piece"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                NextPiecePreview(piece: nextPiece)
            }

            // 設定ボタン
            Button(action: {
                onSettingsTapped()
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.gray)
                    .padding(12)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.7))
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
            }
        }
    }
}

// 次のピースプレビュー
struct NextPiecePreview: View {
    let piece: TetrisPiece?

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.white)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            .frame(width: 70, height: 70)
            .overlay(
                Group {
                    if let piece = piece {
                        PieceShapeView(piece: piece, cellSize: 12)
                    } else {
                        Text("?")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.gray.opacity(0.5))
                    }
                }
            )
    }
}

// ゲームエリアビュー
struct GameAreaView: View {
    let gameModel: GameModel
    @ObservedObject var interstitialAdManager: InterstitialAdManager
    @State private var settings = GameSettings.shared
    @State private var dragStartLocation: CGPoint?
    @State private var lastDragY: CGFloat = 0
    @State private var hasDropped: Bool = false
    @State private var dropMoveThreshold: CGFloat = 0
    @State private var dragDirection: DragDirection? = nil
    @State private var lastMoveTime: Date = Date()
    @State private var lastLocation: CGPoint = .zero
    @State private var dragStartPieceX: Int? // ドラッグ開始時のピースのX座標

    enum DragDirection {
        case horizontal
        case vertical
    }

    var body: some View {
        GeometryReader { geometry in
            let cellWidth = geometry.size.width / CGFloat(GameModel.gridWidth)
            let cellHeight = geometry.size.height / CGFloat(GameModel.gridHeight)

            // 画面のアスペクト比を計算してGameSettingsに反映（マスを正方形にするため）
            let aspectRatio = geometry.size.height / geometry.size.width
            let _ = updateAspectRatioIfNeeded(aspectRatio: aspectRatio)

            ZStack {
                // グリッド背景
                GridBackgroundView()

                // 砂とピースの表示
                Canvas { context, size in
                    // Canvas のサイズから cellWidth と cellHeight を計算（GeometryReader ではなく）
                    let canvasCellWidth = size.width / CGFloat(GameModel.gridWidth)
                    let canvasCellHeight = size.height / CGFloat(GameModel.gridHeight)

                    // グリッド内の砂を描画（粒子レベル）
                    // 実際のgrid配列のサイズを使用して安全にアクセス
                    let gridHeight = gameModel.grid.count
                    let gridWidth = gridHeight > 0 ? gameModel.grid[0].count : 0

                    for y in 0..<gridHeight {
                        for x in 0..<gridWidth {
                            let cell = gameModel.grid[y][x]
                            if case .sand(let color) = cell {
                                let rect = CGRect(
                                    x: CGFloat(x) * canvasCellWidth,
                                    y: CGFloat(y) * canvasCellHeight,
                                    width: canvasCellWidth,
                                    height: canvasCellHeight
                                )
                                context.fill(
                                    Path(roundedRect: rect, cornerRadius: 1),
                                    with: .color(color)
                                )
                            }
                        }
                    }

                    // 現在のピースを描画（ピースグリッド座標系）
                    if let piece = gameModel.currentPiece {
                        let pieceCellWidth = canvasCellWidth * CGFloat(GameModel.particleSubdivision)
                        let pieceCellHeight = canvasCellHeight * CGFloat(GameModel.particleSubdivision)

                        for (dy, row) in piece.shape.enumerated() {
                            for (dx, cell) in row.enumerated() {
                                if cell {
                                    let pieceGridX = gameModel.currentPosition.x + dx
                                    let pieceGridY = gameModel.currentPosition.y + dy

                                    if pieceGridY >= 0 && pieceGridY < GameModel.pieceGridHeight &&
                                       pieceGridX >= 0 && pieceGridX < GameModel.pieceGridWidth {
                                        let rect = CGRect(
                                            x: CGFloat(pieceGridX) * pieceCellWidth + 1,
                                            y: CGFloat(pieceGridY) * pieceCellHeight + 1,
                                            width: pieceCellWidth - 2,
                                            height: pieceCellHeight - 2
                                        )
                                        context.fill(
                                            Path(roundedRect: rect, cornerRadius: 3),
                                            with: .color(piece.color)
                                        )
                                    }
                                }
                            }
                        }
                    }

                    // ゲームオーバーラインを描画
                    let pieceCellHeight = canvasCellHeight * CGFloat(GameModel.particleSubdivision)
                    let gameOverLineY = CGFloat(GameModel.gameOverLineRow) * pieceCellHeight

                    // 点線のパターンを作成
                    let dashPattern: [CGFloat] = [10, 5] // 10ピクセルの線、5ピクセルの空白

                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: gameOverLineY))
                    path.addLine(to: CGPoint(x: size.width, y: gameOverLineY))

                    context.stroke(
                        path,
                        with: .color(.red.opacity(0.6)),
                        style: StrokeStyle(
                            lineWidth: 3,
                            lineCap: .round,
                            dash: dashPattern
                        )
                    )

                    // ラインの上に警告アイコンを描画（左右に配置）
                    let warningSize: CGFloat = 20
                    let warningY = gameOverLineY - warningSize / 2

                    // 左側の警告マーク
                    let leftWarningRect = CGRect(
                        x: 10,
                        y: warningY,
                        width: warningSize,
                        height: warningSize
                    )

                    // 右側の警告マーク
                    let rightWarningRect = CGRect(
                        x: size.width - warningSize - 10,
                        y: warningY,
                        width: warningSize,
                        height: warningSize
                    )

                    // 三角形の警告マークを描画（左）
                    var leftTriangle = Path()
                    leftTriangle.move(to: CGPoint(x: leftWarningRect.midX, y: leftWarningRect.minY))
                    leftTriangle.addLine(to: CGPoint(x: leftWarningRect.minX, y: leftWarningRect.maxY))
                    leftTriangle.addLine(to: CGPoint(x: leftWarningRect.maxX, y: leftWarningRect.maxY))
                    leftTriangle.closeSubpath()

                    context.fill(leftTriangle, with: .color(.red.opacity(0.8)))
                    context.stroke(leftTriangle, with: .color(.white), lineWidth: 1.5)

                    // 三角形の警告マークを描画（右）
                    var rightTriangle = Path()
                    rightTriangle.move(to: CGPoint(x: rightWarningRect.midX, y: rightWarningRect.minY))
                    rightTriangle.addLine(to: CGPoint(x: rightWarningRect.minX, y: rightWarningRect.maxY))
                    rightTriangle.addLine(to: CGPoint(x: rightWarningRect.maxX, y: rightWarningRect.maxY))
                    rightTriangle.closeSubpath()

                    context.fill(rightTriangle, with: .color(.red.opacity(0.8)))
                    context.stroke(rightTriangle, with: .color(.white), lineWidth: 1.5)

                    // 三角形内に「!」マークを描画（簡易版：小さな円と線）
                    let exclamationMarkSize: CGFloat = 8

                    // 左側の「!」
                    var leftExclamation = Path()
                    leftExclamation.move(to: CGPoint(x: leftWarningRect.midX, y: leftWarningRect.minY + 4))
                    leftExclamation.addLine(to: CGPoint(x: leftWarningRect.midX, y: leftWarningRect.midY + 1))
                    context.stroke(leftExclamation, with: .color(.white), style: StrokeStyle(lineWidth: 2, lineCap: .round))

                    let leftDot = Path(ellipseIn: CGRect(
                        x: leftWarningRect.midX - 1.5,
                        y: leftWarningRect.maxY - 5,
                        width: 3,
                        height: 3
                    ))
                    context.fill(leftDot, with: .color(.white))

                    // 右側の「!」
                    var rightExclamation = Path()
                    rightExclamation.move(to: CGPoint(x: rightWarningRect.midX, y: rightWarningRect.minY + 4))
                    rightExclamation.addLine(to: CGPoint(x: rightWarningRect.midX, y: rightWarningRect.midY + 1))
                    context.stroke(rightExclamation, with: .color(.white), style: StrokeStyle(lineWidth: 2, lineCap: .round))

                    let rightDot = Path(ellipseIn: CGRect(
                        x: rightWarningRect.midX - 1.5,
                        y: rightWarningRect.maxY - 5,
                        width: 3,
                        height: 3
                    ))
                    context.fill(rightDot, with: .color(.white))
                }

            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if dragStartLocation == nil {
                            dragStartLocation = value.startLocation
                            lastDragY = value.location.y
                            dropMoveThreshold = cellHeight * 3.6  // 感度をさらに下げる（1/3に）
                            hasDropped = false
                            dragDirection = nil
                            lastMoveTime = Date()
                            lastLocation = value.location
                            dragStartPieceX = gameModel.currentPosition.x // ドラッグ開始時のピースX座標を記録
                        } else {
                            handleDragChange(start: value.startLocation, current: value.location, screenWidth: geometry.size.width, cellHeight: cellHeight)
                        }
                    }
                    .onEnded { value in
                        handleGestureEnd(start: value.startLocation, end: value.location, screenWidth: geometry.size.width)
                        dragStartLocation = nil
                        lastDragY = 0
                        dropMoveThreshold = 0
                        hasDropped = false
                        dragDirection = nil
                        lastMoveTime = Date()
                        lastLocation = .zero
                        dragStartPieceX = nil
                    }
            )
            .allowsHitTesting(gameModel.gameState != .gameOver)

            // ゲームオーバー画面（ZStackの外に配置）
            if gameModel.gameState == .gameOver {
                GameOverView(
                    score: gameModel.score,
                    level: gameModel.currentLevel,
                    onRetry: {
                        gameModel.setupNewGame()
                        gameModel.startGame()
                        // ゲームオーバー後にインタースティシャル広告を表示
                        interstitialAdManager.showAd()
                    }
                )
            }
        }
    }

    private func handleDragChange(start: CGPoint, current: CGPoint, screenWidth: CGFloat, cellHeight: CGFloat) {
        let dx = current.x - start.x
        let dy = current.y - start.y

        // 画面幅に基づいて閾値をスケーリング（基準: iPhone 375pt）
        let scaleFactor = screenWidth / 375.0
        let tapThreshold: CGFloat = 20 * scaleFactor
        let hardDropThreshold: CGFloat = 100 * scaleFactor
        let directionThreshold: CGFloat = 30 * scaleFactor  // 方向を判定するための閾値
        let stopThreshold: CGFloat = 5 * scaleFactor  // 停止判定の閾値
        let stopTimeInterval: TimeInterval = 0.2  // 停止とみなす時間（秒）

        // タップ判定範囲内なら何もしない
        if abs(dx) < tapThreshold && abs(dy) < tapThreshold {
            return
        }

        // 指の停止を検出して方向をリセット
        let distanceFromLastLocation = sqrt(pow(current.x - lastLocation.x, 2) + pow(current.y - lastLocation.y, 2))
        let timeSinceLastMove = Date().timeIntervalSince(lastMoveTime)

        if distanceFromLastLocation < stopThreshold && timeSinceLastMove > stopTimeInterval {
            // 指が停止していると判断し、方向をリセット
            dragDirection = nil
            dragStartLocation = current  // 新しいスタート位置を設定
            lastDragY = current.y
            hasDropped = false
            dragStartPieceX = gameModel.currentPosition.x // 現在のピース位置を新しい基準点として記録
        }

        // 位置が変わったら更新
        if distanceFromLastLocation > stopThreshold {
            lastLocation = current
            lastMoveTime = Date()
        }

        // まだ方向が決まっていない場合、方向を判定する
        if dragDirection == nil {
            if abs(dx) > directionThreshold || abs(dy) > directionThreshold {
                // 横と縦のどちらの移動量が大きいかで方向を決定
                if abs(dx) > abs(dy) {
                    dragDirection = .horizontal
                } else {
                    dragDirection = .vertical
                }
            } else {
                return  // まだ方向が決められない
            }
        }

        // 方向が決まったら、その方向のみで処理
        switch dragDirection {
        case .horizontal:
            // 横移動：設定に応じて方式を切り替え
            switch settings.touchControlMode {
            case .delta:
                // 移動量ベース
                movePieceByDelta(deltaX: dx, screenWidth: screenWidth)
            case .position:
                // 指の位置に追従
                movePieceToFingerPosition(fingerX: current.x, screenWidth: screenWidth)
            }

        case .vertical:
            // 下方向への移動が大きな閾値を超えたら急速落下（一度だけ）
            if !hasDropped && dy > hardDropThreshold {
                gameModel.hardDrop()
                hasDropped = true
                return
            }

            // 下方向のドラッグ（通常落下）
            let deltaY = current.y - lastDragY
            if deltaY > dropMoveThreshold {
                gameModel.moveDown()
                lastDragY = current.y
            }

        case .none:
            break
        }
    }

    // 最初のタッチ位置からの移動量に基づいてピースを移動させる
    private func movePieceByDelta(deltaX: CGFloat, screenWidth: CGFloat) {
        guard let piece = gameModel.currentPiece,
              let startPieceX = dragStartPieceX else { return }

        // 画面幅をピースグリッド幅で割って、1グリッドあたりのスクリーン幅を計算
        let gridCellWidth = screenWidth / CGFloat(GameModel.pieceGridWidth)

        // X方向の移動量をピースグリッド座標の移動量に変換（感度を適用）
        let adjustedDeltaX = deltaX * settings.movementSensitivity
        let gridDeltaX = Int((adjustedDeltaX / gridCellWidth).rounded())

        // 目標位置を計算（開始位置 + 移動量）
        let targetX = startPieceX + gridDeltaX

        // ピースの幅を取得
        let pieceWidth = piece.shape[0].count

        // 範囲チェック
        let clampedX = max(0, min(targetX, GameModel.pieceGridWidth - pieceWidth))

        // 目標位置に移動できるかチェック
        let newPosition = (x: clampedX, y: gameModel.currentPosition.y)
        if gameModel.canPlacePieceAt(piece, position: newPosition) {
            gameModel.setPosition(newPosition)
        } else {
            // 配置できない場合、最も近い有効な位置を探す
            findNearestValidPosition(targetX: clampedX, currentY: gameModel.currentPosition.y, piece: piece)
        }
    }

    // 指の位置にピースを移動させる
    private func movePieceToFingerPosition(fingerX: CGFloat, screenWidth: CGFloat) {
        guard let piece = gameModel.currentPiece,
              let startPieceX = dragStartPieceX,
              let startLocation = dragStartLocation else { return }

        // ピースの幅を取得
        let pieceWidth = piece.shape[0].count

        // 画面幅をピースグリッド幅で割って、1グリッドあたりのスクリーン幅を計算
        let gridCellWidth = screenWidth / CGFloat(GameModel.pieceGridWidth)

        // 開始位置からの移動量を計算し、感度を適用
        let deltaX = (fingerX - startLocation.x) * settings.movementSensitivity
        let gridDeltaX = Int((deltaX / gridCellWidth).rounded())

        // 目標位置を計算（開始位置 + 移動量）
        let targetX = startPieceX + gridDeltaX

        // 範囲チェック
        let clampedX = max(0, min(targetX, GameModel.pieceGridWidth - pieceWidth))

        // 目標位置に移動できるかチェック
        let newPosition = (x: clampedX, y: gameModel.currentPosition.y)
        if gameModel.canPlacePieceAt(piece, position: newPosition) {
            gameModel.setPosition(newPosition)
        } else {
            // 配置できない場合、最も近い有効な位置を探す
            findNearestValidPosition(targetX: clampedX, currentY: gameModel.currentPosition.y, piece: piece)
        }
    }

    // 最も近い有効な位置を探す
    private func findNearestValidPosition(targetX: Int, currentY: Int, piece: TetrisPiece) {
        let pieceWidth = piece.shape[0].count
        let maxX = GameModel.pieceGridWidth - pieceWidth

        // 目標位置から左右に探索
        for offset in 0...maxX {
            // 右方向を試す
            let rightX = min(targetX + offset, maxX)
            if gameModel.canPlacePieceAt(piece, position: (x: rightX, y: currentY)) {
                gameModel.setPosition((x: rightX, y: currentY))
                return
            }

            // 左方向を試す
            let leftX = max(targetX - offset, 0)
            if leftX != rightX && gameModel.canPlacePieceAt(piece, position: (x: leftX, y: currentY)) {
                gameModel.setPosition((x: leftX, y: currentY))
                return
            }
        }
    }

    private func handleGestureEnd(start: CGPoint, end: CGPoint, screenWidth: CGFloat) {
        let dx = end.x - start.x
        let dy = end.y - start.y

        // 画面幅に基づいて閾値をスケーリング（基準: iPhone 375pt）
        let scaleFactor = screenWidth / 375.0
        let tapThreshold: CGFloat = 20 * scaleFactor

        // タップ判定（移動も落下もしていない場合）
        if abs(dx) < tapThreshold && abs(dy) < tapThreshold {
            gameModel.rotate()
        }
    }

    // アスペクト比を更新（変更があった場合のみ）
    private func updateAspectRatioIfNeeded(aspectRatio: CGFloat) {
        let currentAspectRatio = settings.gameAreaAspectRatio
        let newAspectRatio = Double(aspectRatio)

        // アスペクト比が正の値であることを確認
        guard newAspectRatio > 0 else { return }

        // 初回または誤差が5%以上ある場合のみ更新（頻繁な更新を避ける）
        if currentAspectRatio <= 0 || abs(currentAspectRatio - newAspectRatio) / currentAspectRatio > 0.05 {
            settings.gameAreaAspectRatio = newAspectRatio
        }
    }
}

// グリッド背景
struct GridBackgroundView: View {
    let columns = GameModel.pieceGridWidth
    let rows = GameModel.pieceGridHeight

    var body: some View {
        GeometryReader { geometry in
            let cellWidth = geometry.size.width / CGFloat(columns)
            let cellHeight = geometry.size.height / CGFloat(rows)

            Canvas { context, size in
                context.stroke(
                    Path { path in
                        // 縦線
                        for i in 0...columns {
                            let x = CGFloat(i) * cellWidth
                            path.move(to: CGPoint(x: x, y: 0))
                            path.addLine(to: CGPoint(x: x, y: size.height))
                        }

                        // 横線
                        for i in 0...rows {
                            let y = CGFloat(i) * cellHeight
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: size.width, y: y))
                        }
                    },
                    with: .color(.white.opacity(0.15)),
                    lineWidth: 1
                )
            }
        }
    }
}

// 操作ガイド
struct ControlGuideView: View {
    let touchControlMode: GameSettings.TouchControlMode

    var body: some View {
        HStack(spacing: 20) {
            GuideItem(icon: "hand.tap", text: NSLocalizedString("control_guide_tap", comment: ""))
            GuideItem(
                icon: "hand.point.up.left",
                text: touchControlMode == .delta ? NSLocalizedString("control_guide_drag_delta", comment: "") : NSLocalizedString("control_guide_drag_position", comment: "")
            )
            GuideItem(icon: "arrow.down", text: NSLocalizedString("control_guide_swipe", comment: ""))
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.7))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

// ガイドアイテム
struct GuideItem: View {
    let icon: String
    let text: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.blue)
            Text(text)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// ピースの形状表示ビュー
struct PieceShapeView: View {
    let piece: TetrisPiece
    let cellSize: CGFloat

    var body: some View {
        VStack(spacing: 1) {
            ForEach(0..<piece.shape.count, id: \.self) { y in
                HStack(spacing: 1) {
                    ForEach(0..<piece.shape[y].count, id: \.self) { x in
                        if piece.shape[y][x] {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(piece.color)
                                .frame(width: cellSize, height: cellSize)
                        } else {
                            Color.clear
                                .frame(width: cellSize, height: cellSize)
                        }
                    }
                }
            }
        }
    }
}

// ゲームオーバー画面
struct GameOverView: View {
    let score: Int
    let level: Int
    let onRetry: () -> Void

    @Query(sort: \HighScore.score, order: .reverse) private var allHighScores: [HighScore]

    // 当日のハイスコアをフィルタリング
    private var todayHighScores: [HighScore] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return allHighScores.filter { highScore in
            calendar.isDate(highScore.playDate, inSameDayAs: today)
        }
    }

    // トータルTOP3
    private var topScores: [HighScore] {
        Array(allHighScores.prefix(3))
    }

    // 当日TOP3
    private var todayTopScores: [HighScore] {
        Array(todayHighScores.prefix(3))
    }

    var body: some View {
        ZStack {
            // 半透明の背景
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            // ゲームオーバーカード
            VStack(spacing: 20) {
                // ゲームオーバーテキスト
                Text(LocalizedStringKey("game_over_title"))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)

                // レベルとスコア表示
                VStack(spacing: 16) {
                    // レベル表示
                    HStack(spacing: 12) {
                        Text(LocalizedStringKey("game_over_level"))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        Text("\(level)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.orange)
                            .shadow(color: .orange.opacity(0.5), radius: 8, x: 0, y: 0)
                    }

                    Divider()
                        .background(Color.white.opacity(0.3))

                    // スコア表示
                    VStack(spacing: 6) {
                        Text(LocalizedStringKey("game_over_score"))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))

                        Text("\(score)")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundColor(.yellow)
                            .shadow(color: .yellow.opacity(0.5), radius: 8, x: 0, y: 0)
                    }
                }
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.1))
                )

                // ハイスコア表示
                ScrollView {
                    VStack(spacing: 16) {
                        // トータルTOP3
                        HighScoreSection(title: NSLocalizedString("high_scores_total", comment: ""), scores: topScores)

                        // 当日TOP3
                        HighScoreSection(title: NSLocalizedString("high_scores_today", comment: ""), scores: todayTopScores)
                    }
                }
                .frame(maxHeight: 250)

                // リトライボタン
                Button(action: onRetry) {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 24, weight: .semibold))
                        Text(LocalizedStringKey("game_over_retry"))
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: .blue.opacity(0.5), radius: 10, x: 0, y: 5)
                }
                .buttonStyle(.plain)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.2, green: 0.2, blue: 0.3),
                                Color(red: 0.3, green: 0.2, blue: 0.4)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 30)
        }
        .transition(.opacity.combined(with: .scale))
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: true)
    }
}

// ハイスコアセクション
struct HighScoreSection: View {
    let title: String
    let scores: [HighScore]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 12)

            if scores.isEmpty {
                Text(LocalizedStringKey("high_scores_no_records"))
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 12)
            } else {
                VStack(spacing: 6) {
                    ForEach(Array(scores.enumerated()), id: \.element.id) { index, score in
                        HighScoreRow(rank: index + 1, score: score)
                    }
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
    }
}

// ハイスコア行
struct HighScoreRow: View {
    let rank: Int
    let score: HighScore

    var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return Color(red: 0.75, green: 0.75, blue: 0.75)  // Silver
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2)     // Bronze
        default: return .white
        }
    }

    var rankIcon: String {
        switch rank {
        case 1: return "crown.fill"
        case 2: return "medal.fill"
        case 3: return "medal.fill"
        default: return "\(rank)"
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // ランク
            if rank <= 3 {
                Image(systemName: rankIcon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(rankColor)
                    .frame(width: 24)
            } else {
                Text("\(rank)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: 24)
            }

            // スコア
            Text("\(score.score)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(minWidth: 70, alignment: .leading)

            // レベル
            HStack(spacing: 2) {
                Text("Lv.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                Text("\(score.level)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.orange.opacity(0.8))
            }
            .frame(minWidth: 55, alignment: .leading)

            Spacer()

            // 日付
            Text(formatDate(score.playDate))
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.05))
        )
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            formatter.dateFormat = "HH:mm"
            return NSLocalizedString("high_score_today", comment: "") + " " + formatter.string(from: date)
        } else {
            formatter.dateFormat = "MM/dd"
            return formatter.string(from: date)
        }
    }
}

#Preview {
    GameView()
}
