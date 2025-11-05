//
//  AdMobManager.swift
//  sandtetris
//
//  Created for AdMob integration
//

import Foundation
import Combine
import GoogleMobileAds

/// Google AdMobを管理するシングルトンクラス
class AdMobManager: ObservableObject {
    static let shared = AdMobManager()

    @Published var isInitialized = false

    private init() {
    }

    /// AdMob SDKを初期化する
    func initializeAdMob() {
        MobileAds.shared.start { [weak self] status in
            DispatchQueue.main.async {
                self?.isInitialized = true
                print("AdMob初期化完了: \(status.adapterStatusesByClassName)")
            }
        }
    }
}
