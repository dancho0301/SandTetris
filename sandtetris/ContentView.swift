//
//  ContentView.swift
//  sandtetris
//
//  Created by dancho on 2025/10/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        GameView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
