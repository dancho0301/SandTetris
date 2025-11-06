//
//  RewardedAdManager.swift
//  sandtetris
//
//  Created for AdMob integration
//

import Foundation
import Combine
import GoogleMobileAds
import UIKit

/// リワード広告を管理するクラス
class RewardedAdManager: NSObject, ObservableObject {
    @Published var rewardedAd: RewardedAd?
    @Published var isLoading = false
    @Published var rewardEarned = false

    // リワード広告ユニットIDをInfo.plistから取得
    private var adUnitID: String {
        guard let adUnitID = Bundle.main.object(forInfoDictionaryKey: "AdMobRewardedAdUnitID") as? String else {
            fatalError("AdMobRewardedAdUnitID not found in Info.plist")
        }
        return adUnitID
    }

    var onRewardEarned: (() -> Void)?

    override init() {
        super.init()
        loadAd()
    }

    /// 広告をロードする
    func loadAd() {
        guard !isLoading else { return }

        isLoading = true
        let request = Request()

        RewardedAd.load(with: adUnitID, request: request) { [weak self] ad, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    print("リワード広告の読み込み失敗: \(error.localizedDescription)")
                    return
                }

                self?.rewardedAd = ad
                self?.rewardedAd?.fullScreenContentDelegate = self
                print("リワード広告の読み込み成功")
            }
        }
    }

    /// 広告を表示する
    /// - Parameter onReward: 報酬獲得時のコールバック
    func showAd(onReward: @escaping () -> Void) {
        guard let rewardedAd = rewardedAd else {
            print("リワード広告がまだ読み込まれていません")
            loadAd() // 読み込まれていない場合は再読み込み
            return
        }

        guard let rootViewController = getRootViewController() else {
            print("ルートビューコントローラーが見つかりません")
            return
        }

        self.onRewardEarned = onReward

        rewardedAd.present(from: rootViewController) { [weak self] in
            let reward = rewardedAd.adReward
            print("リワード獲得: \(reward.amount) \(reward.type)")
            self?.rewardEarned = true
            self?.onRewardEarned?()
        }
    }

    /// ルートビューコントローラーを取得
    private func getRootViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return nil
        }
        return rootViewController
    }
}

// MARK: - FullScreenContentDelegate

extension RewardedAdManager: FullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: any FullScreenPresentingAd) {
        print("リワード広告が閉じられました")
        // 広告が閉じられたら次の広告をプリロード
        rewardEarned = false
        loadAd()
    }

    func ad(_ ad: any FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("リワード広告の表示に失敗: \(error.localizedDescription)")
        loadAd()
    }

    func adWillPresentFullScreenContent(_ ad: any FullScreenPresentingAd) {
        print("リワード広告を表示します")
    }
}
