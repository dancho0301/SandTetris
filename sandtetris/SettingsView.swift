//
//  SettingsView.swift
//  sandtetris
//
//  Created by dancho on 2025/10/27.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var settings = GameSettings.shared

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text("ブロックの横移動の操作方法を選択できます")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    ForEach(GameSettings.TouchControlMode.allCases, id: \.self) { mode in
                        Button(action: {
                            settings.touchControlMode = mode
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(mode.displayName)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    Text(mode.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                if settings.touchControlMode == mode {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.system(size: 24))
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text("タッチ操作")
                }

                Section {
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("アプリ情報")
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
