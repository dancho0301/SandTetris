//
//  DifficultySelectionView.swift
//  sandtetris
//
//  Created by dancho on 2025/10/29.
//

import SwiftUI

struct DifficultySelectionView: View {
    let onDifficultySelected: (Difficulty) -> Void
    @State private var selectedDifficulty: Difficulty = .normal

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
                Text("砂テトリス")
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

#Preview {
    DifficultySelectionView { difficulty in
        print("Selected: \(difficulty)")
    }
}
