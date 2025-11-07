//
//  DifficultySelectionView.swift
//  sandtetris
//
//  Created by dancho on 2025/10/29.
//

import SwiftUI
import SwiftData

struct DifficultySelectionView: View {
    let onDifficultySelected: (Difficulty) -> Void
    @State private var selectedDifficulty: Difficulty = .normal

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

    enum Difficulty: String, CaseIterable {
        case easy = "easy"
        case normal = "normal"
        case hard = "hard"

        var displayName: String {
            switch self {
            case .easy:
                return "かんたん"
            case .normal:
                return "ふつう"
            case .hard:
                return "むずかしい"
            }
        }

        var colorCount: Int {
            switch self {
            case .easy:
                return 3
            case .normal:
                return 5
            case .hard:
                return 7
            }
        }

        var description: String {
            switch self {
            case .easy:
                return "3色で遊びやすい"
            case .normal:
                return "5色でバランスが良い"
            case .hard:
                return "7色で挑戦的"
            }
        }

        var color: Color {
            switch self {
            case .easy:
                return .green
            case .normal:
                return .blue
            case .hard:
                return .red
            }
        }

        var icon: String {
            switch self {
            case .easy:
                return "star.fill"
            case .normal:
                return "star.fill"
            case .hard:
                return "flame.fill"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // タイトル
            VStack(spacing: 16) {
                Text("サンドドロップ")
                    .font(.system(size: 48, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [.orange, .pink]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)

                Text("難易度を選択してください")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.top, 60)
            .padding(.bottom, 40)

            // 難易度選択
            VStack(spacing: 20) {
                ForEach(Difficulty.allCases, id: \.self) { difficulty in
                    DifficultyCard(
                        difficulty: difficulty,
                        isSelected: selectedDifficulty == difficulty,
                        onTap: {
                            selectedDifficulty = difficulty
                        }
                    )
                }
            }
            .padding(.horizontal, 30)

            Spacer()

            // ハイスコア表示（コンパクト版）
            ScrollView {
                VStack(spacing: 12) {
                    HighScoreSectionCompact(title: "トータルTOP3", scores: topScores)
                    HighScoreSectionCompact(title: "本日のTOP3", scores: todayTopScores)
                }
            }
            .frame(maxHeight: 200)
            .padding(.horizontal, 30)

            // スタートボタン
            Button(action: {
                onDifficultySelected(selectedDifficulty)
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 24, weight: .bold))
                    Text("ゲームスタート")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            selectedDifficulty.color,
                            selectedDifficulty.color.opacity(0.7)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(20)
                .shadow(color: selectedDifficulty.color.opacity(0.5), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.95, blue: 1.0),
                    Color(red: 1.0, green: 0.95, blue: 0.95)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
}

struct DifficultyCard: View {
    let difficulty: DifficultySelectionView.Difficulty
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // アイコン
                Image(systemName: difficulty.icon)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(isSelected ? difficulty.color : .gray)
                    .frame(width: 50, height: 50)

                // テキスト
                VStack(alignment: .leading, spacing: 4) {
                    Text(difficulty.displayName)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(isSelected ? .primary : .secondary)

                    Text(difficulty.description)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }

                Spacer()

                // チェックマーク
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(difficulty.color)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(
                        color: isSelected ? difficulty.color.opacity(0.3) : .black.opacity(0.1),
                        radius: isSelected ? 12 : 4,
                        x: 0,
                        y: isSelected ? 6 : 2
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? difficulty.color : .clear, lineWidth: 3)
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

// ハイスコアセクション（コンパクト版）
struct HighScoreSectionCompact: View {
    let title: String
    let scores: [HighScore]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)

            if scores.isEmpty {
                Text("記録なし")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 4) {
                    ForEach(Array(scores.enumerated()), id: \.element.id) { index, score in
                        HighScoreRowCompact(rank: index + 1, score: score)
                    }
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.7))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

// ハイスコア行（コンパクト版）
struct HighScoreRowCompact: View {
    let rank: Int
    let score: HighScore

    var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return Color(red: 0.75, green: 0.75, blue: 0.75)  // Silver
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2)     // Bronze
        default: return .gray
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
        HStack(spacing: 8) {
            // ランク
            if rank <= 3 {
                Image(systemName: rankIcon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(rankColor)
                    .frame(width: 20)
            } else {
                Text("\(rank)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.secondary)
                    .frame(width: 20)
            }

            // スコア
            Text("\(score.score)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .frame(minWidth: 50, alignment: .leading)

            // レベル
            HStack(spacing: 2) {
                Text("Lv.")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
                Text("\(score.level)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.orange)
            }

            Spacer()

            // 日付
            Text(formatDate(score.playDate))
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.white.opacity(0.5))
        )
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            formatter.dateFormat = "HH:mm"
            return "今日 " + formatter.string(from: date)
        } else {
            formatter.dateFormat = "MM/dd"
            return formatter.string(from: date)
        }
    }
}

#Preview {
    DifficultySelectionView { difficulty in
        print("Selected: \(difficulty)")
    }
}
