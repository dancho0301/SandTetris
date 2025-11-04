//
//  InterstitialAdManager.swift
//  sandtetris
//
//  Created for AdMob integration
//

import Foundation
import GoogleMobileAds
import UIKit

/// インタースティシャル広告を管理するクラス
class InterstitialAdManager: NSObject, ObservableObject {
    @Published var interstitialAd: GADInterstitialAd?
    @Published var isLoading = false

    // インタースティシャル広告ユニットID（砂テトリス用）
    private let adUnitID = "ca-app-pub-3252418079692583/1044141474"

    // 広告表示の頻度制御
    private var lastAdShowTime: Date?
    private let minimumTimeBetweenAds: TimeInterval = 60 // 60秒以上の間隔を空ける

    override init() {
        super.init()
        loadAd()
    }

    /// 広告をロードする
    func loadAd() {
        guard !isLoading else { return }

        isLoading = true
        let request = GADRequest()

        GADInterstitialAd.load(withAdUnitID: adUnitID, request: request) { [weak self] ad, error in
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

    /// 広告を表示する（頻度制限付き）
    func showAd() {
        // 頻度制御チェック
        if let lastShowTime = lastAdShowTime {
            let timeSinceLastAd = Date().timeIntervalSince(lastShowTime)
            if timeSinceLastAd < minimumTimeBetweenAds {
                print("広告表示が早すぎます。\(minimumTimeBetweenAds - timeSinceLastAd)秒後に再試行してください。")
                return
            }
        }

        guard let interstitialAd = interstitialAd else {
            print("インタースティシャル広告がまだ読み込まれていません")
            loadAd() // 読み込まれていない場合は再読み込み
            return
        }

        guard let rootViewController = getRootViewController() else {
            print("ルートビューコントローラーが見つかりません")
            return
        }

        interstitialAd.present(fromRootViewController: rootViewController)
        lastAdShowTime = Date()
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

// MARK: - GADFullScreenContentDelegate

extension InterstitialAdManager: GADFullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("インタースティシャル広告が閉じられました")
        // 広告が閉じられたら次の広告をプリロード
        loadAd()
    }

    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("インタースティシャル広告の表示に失敗: \(error.localizedDescription)")
        loadAd()
    }

    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("インタースティシャル広告を表示します")
    }
}
