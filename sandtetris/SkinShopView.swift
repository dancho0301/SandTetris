//
//  SkinShopView.swift
//  sandtetris
//
//  Created by Claude on 2025/12/31.
//

import SwiftUI

/// スキンショップ画面
struct SkinShopView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var skinManager = SkinManager.shared
    @State private var coinManager = CoinManager.shared
    @State private var selectedCategory: SkinCategory = .basic
    @State private var showPurchaseAnimation: Bool = false
    @State private var purchasedSkin: SkinTheme?

    var body: some View {
        NavigationView {
            ZStack {
                // 背景
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.15),
                        Color(red: 0.15, green: 0.1, blue: 0.2)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 16) {
                    // コイン残高
                    ShopCoinBalanceView(coins: coinManager.coins)

                    // カテゴリセレクター
                    ShopCategorySelector(selectedCategory: $selectedCategory, skinManager: skinManager)

                    // スキン一覧
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach(skinManager.skins(for: selectedCategory)) { skin in
                                SkinCard(
                                    skin: skin,
                                    isOwned: skinManager.ownsSkin(skin),
                                    isSelected: skinManager.isSelected(skin),
                                    canAfford: coinManager.canAfford(skin.price),
                                    onTap: { handleSkinTap(skin) }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)

                // 購入アニメーション
                if showPurchaseAnimation, let skin = purchasedSkin {
                    SkinPurchasedAnimationView(skin: skin) {
                        showPurchaseAnimation = false
                        purchasedSkin = nil
                    }
                }
            }
            .navigationTitle(Text(LocalizedStringKey("skin_shop_title")))
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

    private func handleSkinTap(_ skin: SkinTheme) {
        if skinManager.ownsSkin(skin) {
            // 所有済み: 選択
            skinManager.selectSkin(skin)
        } else if skinManager.canPurchase(skin) {
            // 購入可能: 購入
            if skinManager.purchaseSkin(skin) {
                purchasedSkin = skin
                showPurchaseAnimation = true
                // 購入後に自動選択
                skinManager.selectSkin(skin)
            }
        }
    }
}

// MARK: - コイン残高表示
struct ShopCoinBalanceView: View {
    let coins: Int

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(.yellow)

            Text("\(coins)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text(LocalizedStringKey("coins_unit"))
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .shadow(color: .yellow.opacity(0.2), radius: 8, x: 0, y: 0)
        )
    }
}

// MARK: - カテゴリセレクター
struct ShopCategorySelector: View {
    @Binding var selectedCategory: SkinCategory
    let skinManager: SkinManager

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(SkinCategory.allCases, id: \.self) { category in
                    ShopCategoryTab(
                        category: category,
                        isSelected: selectedCategory == category,
                        ownedCount: skinManager.ownedCount(for: category),
                        totalCount: skinManager.totalCount(for: category),
                        onTap: { selectedCategory = category }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

struct ShopCategoryTab: View {
    let category: SkinCategory
    let isSelected: Bool
    let ownedCount: Int
    let totalCount: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 14))
                Text(LocalizedStringKey(category.nameKey))
                    .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                Text("\(ownedCount)/\(totalCount)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .white.opacity(0.5))
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.6))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? categoryColor : Color.white.opacity(0.1))
            )
        }
        .buttonStyle(.plain)
    }

    private var categoryColor: Color {
        switch category {
        case .basic: return .blue
        case .nature: return .green
        case .neon: return .purple
        case .seasonal: return .pink
        case .premium: return .orange
        }
    }
}

// MARK: - スキンカード
struct SkinCard: View {
    let skin: SkinTheme
    let isOwned: Bool
    let isSelected: Bool
    let canAfford: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // プレビュー
                SkinPreviewView(skin: skin)
                    .frame(height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.yellow : Color.clear, lineWidth: 3)
                    )

                // スキン名
                Text(LocalizedStringKey(skin.nameKey))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                // ステータス/価格
                if isOwned {
                    if isSelected {
                        Label {
                            Text(LocalizedStringKey("skin_equipped"))
                        } icon: {
                            Image(systemName: "checkmark.circle.fill")
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.green)
                    } else {
                        Text(LocalizedStringKey("skin_owned"))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(canAfford ? .yellow : .gray)
                        Text("\(skin.price)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(canAfford ? .yellow : .gray)
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(isOwned ? 0.1 : 0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? Color.yellow.opacity(0.5) :
                                    (canAfford && !isOwned ? Color.yellow.opacity(0.3) : Color.clear),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
        .opacity(isOwned || canAfford ? 1.0 : 0.6)
    }
}

// MARK: - スキンプレビュー
struct SkinPreviewView: View {
    let skin: SkinTheme

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景グラデーション
                LinearGradient(
                    gradient: Gradient(colors: skin.backgroundColors.map { $0.color }),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // グリッド線
                Canvas { context, size in
                    let cellSize: CGFloat = 10
                    let cols = Int(size.width / cellSize) + 1
                    let rows = Int(size.height / cellSize) + 1

                    context.stroke(
                        Path { path in
                            for i in 0...cols {
                                let x = CGFloat(i) * cellSize
                                path.move(to: CGPoint(x: x, y: 0))
                                path.addLine(to: CGPoint(x: x, y: size.height))
                            }
                            for i in 0...rows {
                                let y = CGFloat(i) * cellSize
                                path.move(to: CGPoint(x: 0, y: y))
                                path.addLine(to: CGPoint(x: size.width, y: y))
                            }
                        },
                        with: .color(skin.gridLineColor.color),
                        lineWidth: 1
                    )
                }

                // サンプルの砂粒子
                Canvas { context, size in
                    let cellSize: CGFloat = 8
                    let startX = size.width * 0.2
                    let startY = size.height * 0.3

                    // 砂の色をランダムに配置
                    for i in 0..<7 {
                        let color = skin.sandColors[i % skin.sandColors.count].color
                        let x = startX + CGFloat(i % 4) * cellSize * 1.5
                        let y = startY + CGFloat(i / 4) * cellSize * 1.5 + CGFloat(i % 2) * cellSize

                        // 3x3の砂ブロック
                        for dy in 0..<3 {
                            for dx in 0..<3 {
                                let rect = CGRect(
                                    x: x + CGFloat(dx) * cellSize,
                                    y: y + CGFloat(dy) * cellSize,
                                    width: cellSize - 1,
                                    height: cellSize - 1
                                )
                                context.fill(
                                    Path(roundedRect: rect, cornerRadius: 1),
                                    with: .color(color)
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 購入アニメーション
struct SkinPurchasedAnimationView: View {
    let skin: SkinTheme
    let onComplete: () -> Void

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // スキンプレビュー
                SkinPreviewView(skin: skin)
                    .frame(width: 150, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: skin.previewColor.opacity(0.5), radius: 20, x: 0, y: 0)

                Text(LocalizedStringKey("skin_purchased"))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)

                Text(LocalizedStringKey(skin.nameKey))
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.2, green: 0.2, blue: 0.3),
                                Color(red: 0.25, green: 0.2, blue: 0.35)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
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
    SkinShopView()
}
