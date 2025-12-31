//
//  SkinManager.swift
//  sandtetris
//
//  Created by Claude on 2025/12/31.
//

import SwiftUI

/// スキンの購入・選択を管理するクラス
@Observable
class SkinManager {
    /// シングルトンインスタンス
    static let shared = SkinManager()

    // UserDefaultsのキー
    private enum Keys {
        static let ownedSkinIds = "ownedSkinIds"
        static let selectedSkinId = "selectedSkinId"
    }

    /// 所有しているスキンのID一覧
    private(set) var ownedSkinIds: Set<String> {
        didSet {
            saveOwnedSkins()
        }
    }

    /// 現在選択中のスキンID
    private(set) var selectedSkinId: String {
        didSet {
            UserDefaults.standard.set(selectedSkinId, forKey: Keys.selectedSkinId)
        }
    }

    /// 現在選択中のスキン
    var currentSkin: SkinTheme {
        SkinCatalog.skin(for: selectedSkinId) ?? SkinCatalog.defaultSkin
    }

    /// 所有しているスキン一覧
    var ownedSkins: [SkinTheme] {
        SkinCatalog.allSkins.filter { ownedSkinIds.contains($0.id) }
    }

    /// 未所有のスキン一覧
    var unownedSkins: [SkinTheme] {
        SkinCatalog.allSkins.filter { !ownedSkinIds.contains($0.id) }
    }

    private init() {
        // 所有スキンを読み込み
        if let savedIds = UserDefaults.standard.array(forKey: Keys.ownedSkinIds) as? [String] {
            self.ownedSkinIds = Set(savedIds)
        } else {
            // デフォルトスキンは最初から所有
            self.ownedSkinIds = [SkinCatalog.defaultSkin.id]
        }

        // 選択中のスキンを読み込み
        if let savedId = UserDefaults.standard.string(forKey: Keys.selectedSkinId),
           SkinCatalog.skin(for: savedId) != nil {
            self.selectedSkinId = savedId
        } else {
            self.selectedSkinId = SkinCatalog.defaultSkin.id
        }

        // デフォルトスキンが所有リストにない場合は追加
        if !ownedSkinIds.contains(SkinCatalog.defaultSkin.id) {
            ownedSkinIds.insert(SkinCatalog.defaultSkin.id)
        }
    }

    // MARK: - スキン購入

    /// スキンを購入する
    /// - Parameter skin: 購入するスキン
    /// - Returns: 購入成功かどうか
    @discardableResult
    func purchaseSkin(_ skin: SkinTheme) -> Bool {
        // 既に所有している場合は失敗
        guard !ownedSkinIds.contains(skin.id) else { return false }

        // コインが足りない場合は失敗
        guard CoinManager.shared.canAfford(skin.price) else { return false }

        // コインを消費
        CoinManager.shared.spendCoins(skin.price)

        // スキンを所有リストに追加
        ownedSkinIds.insert(skin.id)

        return true
    }

    /// スキンを所有しているかチェック
    func ownsSkin(_ skin: SkinTheme) -> Bool {
        ownedSkinIds.contains(skin.id)
    }

    /// スキンを購入可能かチェック
    func canPurchase(_ skin: SkinTheme) -> Bool {
        !ownsSkin(skin) && CoinManager.shared.canAfford(skin.price)
    }

    // MARK: - スキン選択

    /// スキンを選択する
    func selectSkin(_ skin: SkinTheme) {
        guard ownedSkinIds.contains(skin.id) else { return }
        selectedSkinId = skin.id
    }

    /// スキンが選択中かチェック
    func isSelected(_ skin: SkinTheme) -> Bool {
        selectedSkinId == skin.id
    }

    // MARK: - 永続化

    private func saveOwnedSkins() {
        UserDefaults.standard.set(Array(ownedSkinIds), forKey: Keys.ownedSkinIds)
    }

    // MARK: - ヘルパー

    /// カテゴリ別のスキン一覧を取得
    func skins(for category: SkinCategory) -> [SkinTheme] {
        SkinCatalog.skins(for: category)
    }

    /// カテゴリ内の所有スキン数を取得
    func ownedCount(for category: SkinCategory) -> Int {
        skins(for: category).filter { ownedSkinIds.contains($0.id) }.count
    }

    /// カテゴリ内の全スキン数を取得
    func totalCount(for category: SkinCategory) -> Int {
        skins(for: category).count
    }

    // MARK: - デバッグ

    /// 全スキンをアンロック（デバッグ用）
    func unlockAllSkins() {
        for skin in SkinCatalog.allSkins {
            ownedSkinIds.insert(skin.id)
        }
    }

    /// リセット（デバッグ用）
    func reset() {
        ownedSkinIds = [SkinCatalog.defaultSkin.id]
        selectedSkinId = SkinCatalog.defaultSkin.id
    }
}
