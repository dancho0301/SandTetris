//
//  AchievementView.swift
//  sandtetris
//
//  Created by Claude on 2025/12/31.
//

import SwiftUI

/// アチーブメント一覧画面
struct AchievementView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var achievementManager = AchievementManager.shared
    @State private var coinManager = CoinManager.shared
    @State private var selectedCategory: AchievementCategory = .score
    @State private var showClaimAnimation: Bool = false
    @State private var claimedAmount: Int = 0

    var body: some View {
        NavigationView {
            ZStack {
                // 背景
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.15, blue: 0.2),
                        Color(red: 0.15, green: 0.1, blue: 0.25)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 16) {
                    // コイン残高 & 進捗
                    AchievementHeaderView(
                        coins: coinManager.coins,
                        unlockedCount: achievementManager.unlockedCount,
                        totalCount: achievementManager.totalCount
                    )

                    // 一括受け取りボタン
                    if achievementManager.hasUnclaimedRewards {
                        ClaimAllRewardsButton(
                            rewardCount: achievementManager.unclaimedRewardCount,
                            onClaim: claimAllRewards
                        )
                    }

                    // カテゴリセレクター
                    CategorySelector(selectedCategory: $selectedCategory, achievementManager: achievementManager)

                    // アチーブメント一覧
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(selectedCategory.achievements, id: \.self) { type in
                                AchievementRow(
                                    type: type,
                                    state: achievementManager.getState(for: type),
                                    onClaimReward: {
                                        claimReward(for: type)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)

                // 報酬獲得アニメーション
                if showClaimAnimation {
                    RewardClaimedAnimationView(amount: claimedAmount) {
                        showClaimAnimation = false
                    }
                }
            }
            .navigationTitle(Text(LocalizedStringKey("achievements_title")))
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
    }

    private func claimReward(for type: AchievementType) {
        let reward = achievementManager.claimReward(for: type)
        if reward > 0 {
            claimedAmount = reward
            showClaimAnimation = true
        }
    }

    private func claimAllRewards() {
        let reward = achievementManager.claimAllRewards()
        if reward > 0 {
            claimedAmount = reward
            showClaimAnimation = true
        }
    }
}

// MARK: - ヘッダー
struct AchievementHeaderView: View {
    let coins: Int
    let unlockedCount: Int
    let totalCount: Int

    var body: some View {
        HStack(spacing: 24) {
            // コイン残高
            HStack(spacing: 6) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.yellow)
                Text("\(coins)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
            )

            // 進捗
            HStack(spacing: 6) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.orange)
                Text("\(unlockedCount)/\(totalCount)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
            )
        }
    }
}

// MARK: - 一括受け取りボタン
struct ClaimAllRewardsButton: View {
    let rewardCount: Int
    let onClaim: () -> Void

    var body: some View {
        Button(action: onClaim) {
            HStack(spacing: 8) {
                Image(systemName: "gift.fill")
                    .foregroundColor(.yellow)
                Text(LocalizedStringKey("claim_all_rewards"))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                Text("(\(rewardCount))")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.yellow)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.orange, Color.pink]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - カテゴリセレクター
struct CategorySelector: View {
    @Binding var selectedCategory: AchievementCategory
    let achievementManager: AchievementManager

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(AchievementCategory.allCases, id: \.self) { category in
                    CategoryTab(
                        category: category,
                        isSelected: selectedCategory == category,
                        unclaimedCount: achievementManager.unclaimedRewardCount(for: category),
                        onTap: { selectedCategory = category }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

struct CategoryTab: View {
    let category: AchievementCategory
    let isSelected: Bool
    let unclaimedCount: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                HStack(spacing: 6) {
                    Text(LocalizedStringKey(category.nameKey))
                        .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                        .foregroundColor(isSelected ? .white : .white.opacity(0.6))

                    // 未受領件数バッジ
                    if unclaimedCount > 0 {
                        Text("\(unclaimedCount)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color.red)
                            )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color.blue : Color.white.opacity(0.1))
                )
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - アチーブメント行
struct AchievementRow: View {
    let type: AchievementType
    let state: AchievementState
    let onClaimReward: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // アイコン
            ZStack {
                Circle()
                    .fill(state.isUnlocked ? type.iconColor.opacity(0.2) : Color.white.opacity(0.05))
                    .frame(width: 50, height: 50)

                Image(systemName: type.icon)
                    .font(.system(size: 22))
                    .foregroundColor(state.isUnlocked ? type.iconColor : .gray.opacity(0.5))
            }

            // 名前と説明
            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizedStringKey(type.nameKey))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(state.isUnlocked ? .white : .gray)

                Text(LocalizedStringKey(type.descriptionKey))
                    .font(.system(size: 12))
                    .foregroundColor(state.isUnlocked ? .white.opacity(0.7) : .gray.opacity(0.6))
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // 報酬 / 受け取りボタン
            if state.isUnlocked {
                if state.isRewardClaimed {
                    // 受け取り済み
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.green)
                } else {
                    // 報酬受け取りボタン
                    Button(action: onClaimReward) {
                        HStack(spacing: 4) {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.yellow)
                            Text("+\(type.rewardCoins)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.yellow)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.orange)
                        )
                    }
                    .buttonStyle(.plain)
                }
            } else {
                // 未解除
                HStack(spacing: 4) {
                    Image(systemName: "dollarsign.circle")
                        .font(.system(size: 14))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("\(type.rewardCoins)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray.opacity(0.5))
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(state.isUnlocked ? 0.1 : 0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            state.isUnlocked && !state.isRewardClaimed ? Color.orange.opacity(0.5) : Color.clear,
                            lineWidth: 2
                        )
                )
        )
    }
}

// MARK: - 報酬獲得アニメーション
struct RewardClaimedAnimationView: View {
    let amount: Int
    let onComplete: () -> Void

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.green)

                Text(LocalizedStringKey("reward_claimed"))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)

                HStack(spacing: 8) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.yellow)
                    Text("+\(amount)")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundColor(.yellow)
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.2, green: 0.2, blue: 0.3))
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

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeOut(duration: 0.2)) {
                    opacity = 0
                    scale = 0.8
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
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

// MARK: - アチーブメント解除通知（ゲーム中に表示）
struct AchievementUnlockedToast: View {
    let type: AchievementType
    let onDismiss: () -> Void

    @State private var offset: CGFloat = -100
    @State private var opacity: Double = 0

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: type.icon)
                .font(.system(size: 24))
                .foregroundColor(type.iconColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(LocalizedStringKey("achievement_unlocked"))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                Text(LocalizedStringKey(type.nameKey))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.yellow)
                Text("+\(type.rewardCoins)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.yellow)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.2, green: 0.2, blue: 0.3),
                            Color(red: 0.3, green: 0.2, blue: 0.35)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal)
        .offset(y: offset)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                offset = 0
                opacity = 1
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeIn(duration: 0.3)) {
                    offset = -100
                    opacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onDismiss()
                }
            }
        }
    }
}

#Preview {
    AchievementView()
}
