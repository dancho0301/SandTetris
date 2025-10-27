//
//  GameView.swift
//  sandtetris
//
//  Created by dancho on 2025/10/26.
//

import SwiftUI

struct GameView: View {
    @State private var gameModel = GameModel()
    @State private var showSettings = false
    @State private var needsReset = false
    @State private var settings = GameSettings.shared

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // 設定ボタン
                HStack {
                    Spacer()
                    Button(action: {
                        showSettings = true
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
                    .padding(.trailing)
                    .padding(.top, 8)
                }

                // ヘッダー部分（スコア、難易度、次のピース）
                HeaderView(
                    score: gameModel.score,
                    nextPiece: gameModel.nextPiece,
                    colorCount: gameModel.colorCount,
                    onColorCountChange: { newCount in
                        gameModel.setColorCount(newCount)
                        gameModel.setupNewGame()
                        gameModel.startGame()
                    }
                )
                .frame(height: geometry.size.height * 0.15)
                .padding(.horizontal)

                // ゲームエリア（砂とテトリスピースが表示される）
                GameAreaView(gameModel: gameModel)
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
                    .padding(.bottom, 20)
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
    }
}

// ヘッダービュー（スコア、難易度、次のピース表示）
struct HeaderView: View {
    let score: Int
    let nextPiece: TetrisPiece?
    let colorCount: Int
    let onColorCountChange: (Int) -> Void

    var body: some View {
        HStack(spacing: 15) {
            // スコア表示
            VStack(alignment: .leading, spacing: 4) {
                Text("スコア")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(score)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // 難易度設定
            VStack(spacing: 4) {
                Text("難易度")
                    .font(.caption)
                    .foregroundColor(.secondary)
                HStack(spacing: 4) {
                    Button(action: { onColorCountChange(max(2, colorCount - 1)) }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(colorCount > 2 ? .blue : .gray)
                    }
                    .disabled(colorCount <= 2)

                    Text("\(colorCount)色")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .frame(minWidth: 40)

                    Button(action: { onColorCountChange(min(7, colorCount + 1)) }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(colorCount < 7 ? .blue : .gray)
                    }
                    .disabled(colorCount >= 7)
                }
            }

            // 次のピース表示
            VStack(spacing: 4) {
                Text("次のピース")
                    .font(.caption)
                    .foregroundColor(.secondary)
                NextPiecePreview(piece: nextPiece)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
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

            ZStack {
                // グリッド背景
                GridBackgroundView()

                // 砂とピースの表示
                Canvas { context, size in
                    // グリッド内の砂を描画（粒子レベル）
                    for y in 0..<GameModel.gridHeight {
                        for x in 0..<GameModel.gridWidth {
                            let cell = gameModel.grid[y][x]
                            if case .sand(let color) = cell {
                                let rect = CGRect(
                                    x: CGFloat(x) * cellWidth,
                                    y: CGFloat(y) * cellHeight,
                                    width: cellWidth,
                                    height: cellHeight
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
                        let pieceCellWidth = cellWidth * CGFloat(GameModel.particleSubdivision)
                        let pieceCellHeight = cellHeight * CGFloat(GameModel.particleSubdivision)

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
                        handleGestureEnd(start: value.startLocation, end: value.location)
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
                    onRetry: {
                        gameModel.setupNewGame()
                        gameModel.startGame()
                    }
                )
            }
        }
    }

    private func handleDragChange(start: CGPoint, current: CGPoint, screenWidth: CGFloat, cellHeight: CGFloat) {
        let dx = current.x - start.x
        let dy = current.y - start.y
        let tapThreshold: CGFloat = 20
        let hardDropThreshold: CGFloat = 100
        let directionThreshold: CGFloat = 30  // 方向を判定するための閾値
        let stopThreshold: CGFloat = 5  // 停止判定の閾値
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

    private func handleGestureEnd(start: CGPoint, end: CGPoint) {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let tapThreshold: CGFloat = 20

        // タップ判定（移動も落下もしていない場合）
        if abs(dx) < tapThreshold && abs(dy) < tapThreshold {
            gameModel.rotate()
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
            GuideItem(icon: "hand.tap", text: "タップで回転")
            GuideItem(
                icon: "hand.point.up.left",
                text: touchControlMode == .delta ? "横ドラッグで移動" : "横ドラッグで指に追従"
            )
            GuideItem(icon: "arrow.down", text: "下スワイプで急速落下")
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
    let onRetry: () -> Void

    var body: some View {
        ZStack {
            // 半透明の背景
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            // ゲームオーバーカード
            VStack(spacing: 30) {
                // ゲームオーバーテキスト
                Text("ゲームオーバー")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)

                // 最終スコア表示
                VStack(spacing: 8) {
                    Text("スコア")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))

                    Text("\(score)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.yellow)
                        .shadow(color: .yellow.opacity(0.5), radius: 8, x: 0, y: 0)
                }
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.1))
                )

                // リトライボタン
                Button(action: onRetry) {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 24, weight: .semibold))
                        Text("もう一度プレイ")
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

#Preview {
    GameView()
}
