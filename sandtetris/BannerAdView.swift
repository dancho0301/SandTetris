//
//  BannerAdView.swift
//  sandtetris
//
//  Created for AdMob integration
//

import SwiftUI
import GoogleMobileAds

/// バナー広告を表示するSwiftUIビュー
struct BannerAdView: View {
    @State private var bannerHeight: CGFloat = 50

    var body: some View {
        BannerViewRepresentable(bannerHeight: $bannerHeight)
            .frame(height: bannerHeight)
    }
}

/// UIKitのBannerViewをSwiftUIで使用するためのラッパー
struct BannerViewRepresentable: UIViewRepresentable {
    @Binding var bannerHeight: CGFloat

    // バナー広告ユニットID（砂テトリス用）
    private let adUnitID = "ca-app-pub-3252418079692583/1427284854"

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = adUnitID
        banner.delegate = context.coordinator

        // ルートビューコントローラーを取得
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            banner.rootViewController = rootViewController
        }

        // 広告をロード
        banner.load(Request())

        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
        // 更新が必要な場合はここで処理
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, BannerViewDelegate {
        var parent: BannerViewRepresentable

        init(_ parent: BannerViewRepresentable) {
            self.parent = parent
        }

        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            print("バナー広告の読み込み成功")
            // 広告のサイズに応じて高さを調整
            DispatchQueue.main.async {
                self.parent.bannerHeight = bannerView.adSize.size.height
            }
        }

        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            print("バナー広告の読み込み失敗: \(error.localizedDescription)")
        }
    }
}
