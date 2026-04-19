//
//  MissionView.swift
//  sandtetris
//
//  Created by Claude on 2026/01/01.
//

import SwiftUI

/// ミッション表示UI
struct MissionView: View {
    let mission: Mission

    var body: some View {
        VStack(spacing: 8) {
            // ミッション目標
            HStack(spacing: 8) {
                Image(systemName: "target")
                    .font(.system(size: 16))
                    .foregroundColor(.yellow)

                Text("ミッション: \(mission.remainingLines)ライン消去")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                // 進捗表示
                Text("\(mission.clearedLines)/\(mission.targetLines)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(mission.isCompleted ? .green : .white)
            }

            // 進捗バー
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.2))

                    // 進捗
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.green, Color.yellow]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * mission.clearProgress)
                }
            }
            .frame(height: 6)

            // 残り時間
            HStack(spacing: 8) {
                Image(systemName: "timer")
                    .font(.system(size: 14))
                    .foregroundColor(mission.timeProgress < 0.3 ? .red : .white)

                Text(timeString(from: mission.remainingTime))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(mission.timeProgress < 0.3 ? .red : .white)

                Spacer()

                // タイムバー
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // 背景
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.2))

                        // 残り時間
                        RoundedRectangle(cornerRadius: 3)
                            .fill(timeBarColor(progress: mission.timeProgress))
                            .frame(width: geometry.size.width * mission.timeProgress)
                    }
                }
                .frame(width: 80, height: 4)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            mission.state == .completed ? Color.green :
                                (mission.timeProgress < 0.3 ? Color.red : Color.yellow),
                            lineWidth: 2
                        )
                )
        )
    }

    private func timeString(from seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, secs)
    }

    private func timeBarColor(progress: Double) -> Color {
        if progress < 0.3 {
            return .red
        } else if progress < 0.6 {
            return .orange
        } else {
            return .green
        }
    }
}

/// ミッション達成アニメーション
struct MissionCompletedView: View {
    let mission: Mission
    let level: Int
    let onDismiss: () -> Void

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // 成功アイコン
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)

                Text("ミッション達成！")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)

                VStack(spacing: 8) {
                    Text("ボーナス: +\(bonusScore) スコア")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.yellow)

                    Text("コイン: +\(coinReward)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.yellow)

                    Text("レベル: \(level) → \(level + 1)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.cyan)
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.1, green: 0.3, blue: 0.2),
                                Color(red: 0.15, green: 0.4, blue: 0.25)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .green.opacity(0.3), radius: 20, x: 0, y: 10)
            )
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeOut(duration: 0.3)) {
                    opacity = 0
                    scale = 0.8
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onDismiss()
                }
            }
        }
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.2)) {
                opacity = 0
                scale = 0.8
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                onDismiss()
            }
        }
    }

    private var bonusScore: Int {
        return 500 * level
    }

    private var coinReward: Int {
        return 10 * level
    }
}

#Preview {
    ZStack {
        Color.black
        VStack {
            MissionView(mission: Mission(targetLines: 5, timeLimit: 60))
                .padding()

            MissionCompletedView(mission: Mission(targetLines: 5, timeLimit: 60), level: 3, onDismiss: {})
        }
    }
}
