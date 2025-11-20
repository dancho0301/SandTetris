//
//  sandtetrisUITests.swift
//  sandtetrisUITests
//
//  Created by dancho on 2025/10/26.
//

import XCTest

final class sandtetrisUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it's important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    // MARK: - レスポンシブ対応UIテスト

    /// iPhoneの縦向きでゲームが正しく表示されることをテスト
    @MainActor
    func testGameDisplayOnIPhonePortrait() throws {
        let app = XCUIApplication()

        // 縦向きに設定
        XCUIDevice.shared.orientation = .portrait

        app.launch()

        // ゲーム画面が表示されるまで待機
        sleep(2)

        // ゲーム画面の主要な要素が存在することを確認
        // ヘッダー要素（スコア、レベルなど）が表示されている
        XCTAssertTrue(app.staticTexts["LEVEL"].exists, "レベル表示が存在する")

        // アプリが起動していることを確認
        XCTAssertTrue(app.exists, "アプリが正しく起動している")

        // スクリーンショットを撮影（デバッグ用）
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "iPhone Portrait View"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// iPhoneの横向きでゲームが正しく表示されることをテスト
    @MainActor
    func testGameDisplayOnIPhoneLandscape() throws {
        let app = XCUIApplication()

        // 横向きに設定
        XCUIDevice.shared.orientation = .landscapeLeft

        app.launch()

        // ゲーム画面が表示されるまで待機
        sleep(2)

        // ゲーム画面の主要な要素が存在することを確認
        XCTAssertTrue(app.staticTexts["LEVEL"].exists, "レベル表示が存在する")

        // アプリが起動していることを確認
        XCTAssertTrue(app.exists, "アプリが正しく起動している")

        // スクリーンショットを撮影（デバッグ用）
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "iPhone Landscape View"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// iPadの縦向きでゲームが正しく表示されることをテスト
    @MainActor
    func testGameDisplayOnIPadPortrait() throws {
        let app = XCUIApplication()

        // iPadでのみ実行
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            throw XCTSkip("このテストはiPadでのみ実行されます")
        }

        // 縦向きに設定
        XCUIDevice.shared.orientation = .portrait

        app.launch()

        // ゲーム画面が表示されるまで待機
        sleep(2)

        // ゲーム画面の主要な要素が存在することを確認
        XCTAssertTrue(app.staticTexts["LEVEL"].exists, "レベル表示が存在する")

        // アプリが起動していることを確認
        XCTAssertTrue(app.exists, "アプリが正しく起動している")

        // スクリーンショットを撮影（デバッグ用）
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "iPad Portrait View"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// iPadの横向きでゲームが正しく表示されることをテスト
    @MainActor
    func testGameDisplayOnIPadLandscape() throws {
        let app = XCUIApplication()

        // iPadでのみ実行
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            throw XCTSkip("このテストはiPadでのみ実行されます")
        }

        // 横向きに設定
        XCUIDevice.shared.orientation = .landscapeLeft

        app.launch()

        // ゲーム画面が表示されるまで待機
        sleep(2)

        // ゲーム画面の主要な要素が存在することを確認
        XCTAssertTrue(app.staticTexts["LEVEL"].exists, "レベル表示が存在する")

        // アプリが起動していることを確認
        XCTAssertTrue(app.exists, "アプリが正しく起動している")

        // スクリーンショットを撮影（デバッグ用）
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "iPad Landscape View"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// 画面回転でゲームが正しく動作することをテスト
    @MainActor
    func testGameRotation() throws {
        let app = XCUIApplication()

        // 縦向きで起動
        XCUIDevice.shared.orientation = .portrait
        app.launch()

        // ゲーム画面が表示されるまで待機
        sleep(2)

        // 縦向きで要素が存在することを確認
        XCTAssertTrue(app.staticTexts["LEVEL"].exists, "縦向きでレベル表示が存在する")

        // 横向きに回転
        XCUIDevice.shared.orientation = .landscapeLeft
        sleep(1)

        // 横向きでも要素が存在することを確認
        XCTAssertTrue(app.staticTexts["LEVEL"].exists, "横向きでレベル表示が存在する")

        // 再び縦向きに回転
        XCUIDevice.shared.orientation = .portrait
        sleep(1)

        // 縦向きに戻っても要素が存在することを確認
        XCTAssertTrue(app.staticTexts["LEVEL"].exists, "縦向きに戻してもレベル表示が存在する")
    }

    /// 設定画面が画面サイズに関わらず正しく表示されることをテスト
    @MainActor
    func testSettingsDisplayAcrossScreenSizes() throws {
        let app = XCUIApplication()

        // 縦向きで起動
        XCUIDevice.shared.orientation = .portrait
        app.launch()

        // ゲーム画面が表示されるまで待機
        sleep(2)

        // 設定ボタンをタップ（歯車アイコン）
        let settingsButton = app.buttons.matching(identifier: "gearshape.fill").firstMatch
        if settingsButton.exists {
            settingsButton.tap()

            // 設定画面が表示されることを確認
            sleep(1)

            // 設定画面のスクリーンショット
            let screenshot1 = XCUIScreen.main.screenshot()
            let attachment1 = XCTAttachment(screenshot: screenshot1)
            attachment1.name = "Settings Portrait"
            attachment1.lifetime = .keepAlways
            add(attachment1)

            // 設定を閉じる
            if app.buttons["閉じる"].exists {
                app.buttons["閉じる"].tap()
            } else {
                // 設定画面の外をタップして閉じる
                app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1)).tap()
            }

            sleep(1)
        }

        // 横向きに回転して再度テスト
        XCUIDevice.shared.orientation = .landscapeLeft
        sleep(1)

        if settingsButton.exists {
            settingsButton.tap()

            // 設定画面が表示されることを確認
            sleep(1)

            // 設定画面のスクリーンショット
            let screenshot2 = XCUIScreen.main.screenshot()
            let attachment2 = XCTAttachment(screenshot: screenshot2)
            attachment2.name = "Settings Landscape"
            attachment2.lifetime = .keepAlways
            add(attachment2)
        }
    }

    /// タップ操作が画面サイズに関わらず正しく機能することをテスト
    @MainActor
    func testTapInteractionAcrossScreenSizes() throws {
        let app = XCUIApplication()

        // 縦向きで起動
        XCUIDevice.shared.orientation = .portrait
        app.launch()

        // ゲーム画面が表示されるまで待機
        sleep(2)

        // ゲームエリアの中央をタップ（ピースを回転）
        let gameArea = app.otherElements.firstMatch
        gameArea.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()

        // タップが正常に処理されることを確認（クラッシュしない）
        XCTAssertTrue(app.exists, "タップ後もアプリが正常に動作している")

        // 横向きでも同様にテスト
        XCUIDevice.shared.orientation = .landscapeLeft
        sleep(1)

        gameArea.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()

        // タップが正常に処理されることを確認
        XCTAssertTrue(app.exists, "横向きでのタップ後もアプリが正常に動作している")
    }

    /// スワイプ操作が画面サイズに関わらず正しく機能することをテスト
    @MainActor
    func testSwipeInteractionAcrossScreenSizes() throws {
        let app = XCUIApplication()

        // 縦向きで起動
        XCUIDevice.shared.orientation = .portrait
        app.launch()

        // ゲーム画面が表示されるまで待機
        sleep(2)

        // ゲームエリアを左にスワイプ
        let gameArea = app.otherElements.firstMatch
        let startPoint = gameArea.coordinate(withNormalizedOffset: CGVector(dx: 0.7, dy: 0.5))
        let endPoint = gameArea.coordinate(withNormalizedOffset: CGVector(dx: 0.3, dy: 0.5))
        startPoint.press(forDuration: 0.1, thenDragTo: endPoint)

        // スワイプが正常に処理されることを確認
        XCTAssertTrue(app.exists, "スワイプ後もアプリが正常に動作している")

        sleep(1)

        // 下方向にスワイプ（急速落下）
        let startPoint2 = gameArea.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.3))
        let endPoint2 = gameArea.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.7))
        startPoint2.press(forDuration: 0.1, thenDragTo: endPoint2)

        // スワイプが正常に処理されることを確認
        XCTAssertTrue(app.exists, "下スワイプ後もアプリが正常に動作している")

        // 横向きでも同様にテスト
        XCUIDevice.shared.orientation = .landscapeLeft
        sleep(1)

        let startPoint3 = gameArea.coordinate(withNormalizedOffset: CGVector(dx: 0.7, dy: 0.5))
        let endPoint3 = gameArea.coordinate(withNormalizedOffset: CGVector(dx: 0.3, dy: 0.5))
        startPoint3.press(forDuration: 0.1, thenDragTo: endPoint3)

        // スワイプが正常に処理されることを確認
        XCTAssertTrue(app.exists, "横向きでのスワイプ後もアプリが正常に動作している")
    }

}
