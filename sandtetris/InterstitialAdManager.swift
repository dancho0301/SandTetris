//
//  InterstitialAdManager.swift
//  sandtetris
//
//  Created for AdMob integration
//

import Foundation
import Combine
import GoogleMobileAds
import UIKit

/// インタースティシャル広告を管理するクラス
class InterstitialAdManager: NSObject, ObservableObject {
    @Published var interstitialAd: InterstitialAd?
    @Published var isLoading = false

    // インタースティシャル広告ユニットIDをInfo.plistから取得
    private var adUnitID: String {
        guard let adUnitID = Bundle.main.object(forInfoDictionaryKey: "AdMobInterstitialAdUnitID") as? String else {
            fatalError("AdMobInterstitialAdUnitID not found in Info.plist")
        }
        return adUnitID
    }

    // 広告表示の頻度制御（2回に1回表示）
    private var showAdCallCount: Int = 0

    override init() {
        super.init()
        loadAd()
    }

    /// 広告をロードする
    func loadAd() {
        guard !isLoading else { return }

        isLoading = true
        let request = Request()

        InterstitialAd.load(with: adUnitID, request: request) { [weak self] ad, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    print("インタースティシャル広告の読み込み失敗: \(error.localizedDescription)")
                    return
                }

                self?.interstitialAd = ad
                self?.interstitialAd?.fullScreenContentDelegate = self
                print("インタースティシャル広告の読み込み成功")
            }
        }
    }

    /// 広告を表示する（2回に1回表示）
    func showAd() {
        // 呼び出し回数をインクリメント
        showAdCallCount += 1

        // 2回に1回のみ広告を表示（奇数回目はスキップ）
        if showAdCallCount % 2 != 0 {
            print("広告表示スキップ（\(showAdCallCount)回目の呼び出し）")
            return
        }

        print("広告を表示します（\(showAdCallCount)回目の呼び出し）")

        guard let interstitialAd = interstitialAd else {
            print("インタースティシャル広告がまだ読み込まれていません")
            loadAd() // 読み込まれていない場合は再読み込み
            return
        }

        guard let rootViewController = getRootViewController() else {
            print("ルートビューコントローラーが見つかりません")
            return
        }

        interstitialAd.present(from: rootViewController)
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

extension InterstitialAdManager: FullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: any FullScreenPresentingAd) {
        print("インタースティシャル広告が閉じられました")
        // 広告が閉じられたら次の広告をプリロード
        loadAd()
    }

    func ad(_ ad: any FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("インタースティシャル広告の表示に失敗: \(error.localizedDescription)")
        loadAd()
    }

    func adWillPresentFullScreenContent(_ ad: any FullScreenPresentingAd) {
        print("インタースティシャル広告を表示します")
    }
}
