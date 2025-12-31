//
//  DailyBonusView.swift
//  sandtetris
//
//  Created by Claude on 2025/12/31.
//

import SwiftUI

/// デイリーボーナス画面
struct DailyBonusView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var dailyBonusManager = DailyBonusManager.shared
    @State private var coinManager = CoinManager.shared
    @State private var claimedBonus: Int = 0
    @State private var showClaimedAnimation: Bool = false
    @State private var remainingTimeString: String = ""
    @State private var timer: Timer?

    var body: some View {
        NavigationView {
            ZStack {
                // 背景グラデーション
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.2),
                        Color(red: 0.2, green: 0.1, blue: 0.3)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 24) {
                    // コイン残高表示
                    CoinBalanceView(coins: coinManager.coins)

                    // 連続ログイン日数
                    StreakInfoView(
                        currentStreak: dailyBonusManager.currentStreak,
                        longestStreak: dailyBonusManager.longestStreak
                    )

                    // 週間ボーナスカレンダー
                    WeeklyBonusCalendarView(
                        currentDayInWeek: dailyBonusManager.currentDayInWeek,
                        canClaimToday: dailyBonusManager.canClaimToday
                    )

                    Spacer()

                    // ボーナス受け取りボタン
                    if dailyBonusManager.canClaimToday {
                        ClaimBonusButton(
                            bonus: dailyBonusManager.todayBonus,
                            onClaim: claimBonus
                        )
                    } else {
                        NextBonusCountdownView(remainingTime: remainingTimeString)
                    }

                    Spacer()
                }
                .padding()

                // 受け取りアニメーション
                if showClaimedAnimation {
                    BonusClaimedAnimationView(amount: claimedBonus) {
                        showClaimedAnimation = false
                    }
                }
            }
            .navigationTitle(Text(LocalizedStringKey("daily_bonus_title")))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .toolbarBackground(Color.clear, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func claimBonus() {
        let bonus = dailyBonusManager.claimDailyBonus()
        if bonus > 0 {
            claimedBonus = bonus
            showClaimedAnimation = true
        }
    }

    private func startTimer() {
        updateRemainingTime()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            updateRemainingTime()
        }
    }

    private func updateRemainingTime() {
        if let remaining = dailyBonusManager.timeUntilNextBonus {
            let hours = Int(remaining) / 3600
            let minutes = (Int(remaining) % 3600) / 60
            let seconds = Int(remaining) % 60
            remainingTimeString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            remainingTimeString = ""
        }
    }
}

// MARK: - コイン残高表示
struct CoinBalanceView: View {
    let coins: Int

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 28))
                .foregroundColor(.yellow)

            Text("\(coins)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text(LocalizedStringKey("coins_unit"))
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .shadow(color: .yellow.opacity(0.2), radius: 10, x: 0, y: 0)
        )
    }
}

// MARK: - 連続ログイン情報
struct StreakInfoView: View {
    let currentStreak: Int
    let longestStreak: Int

    var body: some View {
        HStack(spacing: 32) {
            VStack(spacing: 4) {
                Text(LocalizedStringKey("streak_current"))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("\(currentStreak)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                    Text(LocalizedStringKey("days_unit"))
                        .font(.system(size: 14))
                        .foregroundColor(.orange.opacity(0.8))
                }
            }

            VStack(spacing: 4) {
                Text(LocalizedStringKey("streak_best"))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                HStack(spacing: 4) {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                    Text("\(longestStreak)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.yellow)
                    Text(LocalizedStringKey("days_unit"))
                        .font(.system(size: 14))
                        .foregroundColor(.yellow.opacity(0.8))
                }
            }
        }
    }
}

// MARK: - 週間ボーナスカレンダー
struct WeeklyBonusCalendarView: View {
    let currentDayInWeek: Int
    let canClaimToday: Bool

    var body: some View {
        VStack(spacing: 12) {
            Text(LocalizedStringKey("weekly_bonus"))
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)

            HStack(spacing: 8) {
                ForEach(1...7, id: \.self) { day in
                    DayBonusCell(
                        day: day,
                        bonus: DailyBonusManager.weeklyBonuses[day - 1],
                        isCurrent: day == currentDayInWeek && canClaimToday,
                        isClaimed: day < currentDayInWeek || (day == currentDayInWeek && !canClaimToday),
                        isFuture: day > currentDayInWeek || (day == currentDayInWeek && !canClaimToday && currentDayInWeek < 7)
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
    }
}

// MARK: - 日別ボーナスセル
struct DayBonusCell: View {
    let day: Int
    let bonus: Int
    let isCurrent: Bool
    let isClaimed: Bool
    let isFuture: Bool

    var body: some View {
        VStack(spacing: 4) {
            Text(LocalizedStringKey("day_\(day)"))
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(textColor)

            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor)
                    .frame(width: 40, height: 40)

                if isClaimed {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 20))
                } else {
                    VStack(spacing: 0) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.yellow)
                        Text("\(bonus)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(textColor)
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isCurrent ? Color.yellow : Color.clear, lineWidth: 2)
            )
        }
    }

    private var backgroundColor: Color {
        if isCurrent {
            return Color.yellow.opacity(0.3)
        } else if isClaimed {
            return Color.green.opacity(0.2)
        } else {
            return Color.white.opacity(0.1)
        }
    }

    private var textColor: Color {
        if isCurrent {
            return .yellow
        } else if isClaimed {
            return .green
        } else {
            return .white.opacity(0.6)
        }
    }
}

// MARK: - ボーナス受け取りボタン
struct ClaimBonusButton: View {
    let bonus: Int
    let onClaim: () -> Void

    @State private var isPressed: Bool = false

    var body: some View {
        Button(action: onClaim) {
            VStack(spacing: 8) {
                Text(LocalizedStringKey("claim_bonus"))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)

                HStack(spacing: 4) {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(.yellow)
                    Text("+\(bonus)")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(.yellow)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.orange, Color.pink]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(20)
            .shadow(color: .orange.opacity(0.5), radius: 15, x: 0, y: 5)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - 次回ボーナスカウントダウン
struct NextBonusCountdownView: View {
    let remainingTime: String

    var body: some View {
        VStack(spacing: 8) {
            Text(LocalizedStringKey("next_bonus_in"))
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.6))

            Text(remainingTime)
                .font(.system(size: 36, weight: .bold, design: .monospaced))
                .foregroundColor(.white)

            Text(LocalizedStringKey("already_claimed_today"))
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
        )
    }
}

// MARK: - ボーナス獲得アニメーション
struct BonusClaimedAnimationView: View {
    let amount: Int
    let onComplete: () -> Void

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "gift.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.yellow)

                Text(LocalizedStringKey("bonus_received"))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)

                HStack(spacing: 8) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.yellow)
                    Text("+\(amount)")
                        .font(.system(size: 48, weight: .heavy, design: .rounded))
                        .foregroundColor(.yellow)
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.3, green: 0.2, blue: 0.4),
                                Color(red: 0.2, green: 0.2, blue: 0.3)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .yellow.opacity(0.3), radius: 20, x: 0, y: 10)
            )
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 0.3)) {
                    opacity = 0
                    scale = 0.8
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onComplete()
                }
            }
        }
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.2)) {
                opacity = 0
                scale = 0.8
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                onComplete()
            }
        }
    }
}

#Preview {
    DailyBonusView()
}
