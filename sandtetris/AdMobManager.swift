//
//  AdMobManager.swift
//  sandtetris
//
//  Created for AdMob integration
//

import Foundation
import GoogleMobileAds

/// Google AdMobを管理するシングルトンクラス
class AdMobManager: NSObject, ObservableObject {
    static let shared = AdMobManager()

    @Published var isInitialized = false

    private override init() {
        super.init()
    }

    /// AdMob SDKを初期化する
    func initializeAdMob() {
        GADMobileAds.sharedInstance().start { [weak self] status in
            DispatchQueue.main.async {
                self?.isInitialized = true
                print("AdMob初期化完了: \(status.adapterStatusesByClassName)")
            }
        }
    }
}
