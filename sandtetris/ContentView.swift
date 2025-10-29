//
//  ContentView.swift
//  sandtetris
//
//  Created by dancho on 2025/10/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var settings = GameSettings.shared
    @State private var showGame = false

    var body: some View {
        Group {
            if settings.hasSelectedDifficulty || showGame {
                GameView()
            } else {
                DifficultySelectionView { difficulty in
                    // 選択された難易度に応じて色数を設定
                    settings.colorCount = difficulty.colorCount
                    settings.hasSelectedDifficulty = true
                    showGame = true
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
