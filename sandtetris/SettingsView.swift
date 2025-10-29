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
    @Binding var needsReset: Bool

    // 元の設定値を保存
    @State private var originalGameAreaWidth: Int = 0
    @State private var originalColorCount: Int = 0
    @State private var showResetConfirmation = false

    private var sensitivityLabel: String {
        String(format: "%.1f×", settings.movementSensitivity)
    }

    // ゲームをリセットする必要がある設定に変更があるかチェック
    private var hasGameSettingChanged: Bool {
        settings.gameAreaWidth != originalGameAreaWidth || settings.colorCount != originalColorCount
    }

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
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("感度")
                                .font(.body)
                            Spacer()
                            Text(sensitivityLabel)
                                .font(.body)
                                .foregroundColor(.blue)
                                .fontWeight(.semibold)
                        }

                        Slider(
                            value: $settings.movementSensitivity,
                            in: 0.5...2.0,
                            step: 0.1
                        )
                        .tint(.blue)

                        HStack {
                            Text("遅い")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("標準")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("速い")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)

                    Text("横移動の反応速度を調整できます。値が大きいほど、指の動きに対してブロックが速く移動します")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } header: {
                    Text("移動感度")
                }

                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("横幅")
                                .font(.body)
                            Spacer()
                            Text("\(settings.gameAreaWidth)マス")
                                .font(.body)
                                .foregroundColor(.blue)
                                .fontWeight(.semibold)
                        }

                        Slider(
                            value: Binding(
                                get: { Double(settings.gameAreaWidth) },
                                set: { settings.gameAreaWidth = Int($0.rounded()) }
                            ),
                            in: 10...30,
                            step: 1
                        )
                        .tint(.blue)

                        HStack {
                            Text("狭い")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("標準")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("広い")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)

                    Text("ゲームエリアの横幅を調整できます。値を変更するとゲームがリセットされます")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } header: {
                    Text("ゲームエリア")
                }

                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("色の数")
                                .font(.body)
                            Spacer()
                            Text("\(settings.colorCount)色")
                                .font(.body)
                                .foregroundColor(.blue)
                                .fontWeight(.semibold)
                        }

                        Slider(
                            value: Binding(
                                get: { Double(settings.colorCount) },
                                set: { settings.colorCount = Int($0.rounded()) }
                            ),
                            in: 2...7,
                            step: 1
                        )
                        .tint(.blue)

                        HStack {
                            Text("簡単")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("標準")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("難しい")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)

                    Text("ブロックとして出現する色の数を調整できます。色が多いほど難易度が上がります。値を変更するとゲームがリセットされます")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } header: {
                    Text("難易度")
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
                        handleDismiss()
                    }
                }
            }
            .onAppear {
                // 元の設定値を保存
                originalGameAreaWidth = settings.gameAreaWidth
                originalColorCount = settings.colorCount
            }
            .alert("ゲーム設定の変更", isPresented: $showResetConfirmation) {
                Button("リセットする", role: .destructive) {
                    // 新しい設定でゲームをリセット
                    needsReset = true
                    dismiss()
                }
                Button("元に戻す", role: .cancel) {
                    // 設定を元に戻す
                    settings.gameAreaWidth = originalGameAreaWidth
                    settings.colorCount = originalColorCount
                    dismiss()
                }
            } message: {
                Text("ゲーム設定が変更されました。ゲームをリセットしますか？\n\n「元に戻す」を選ぶと、設定を変更前の状態に戻します。")
            }
        }
    }

    private func handleDismiss() {
        // ゲーム設定に変更があれば確認アラートを表示
        if hasGameSettingChanged {
            showResetConfirmation = true
        } else {
            dismiss()
        }
    }
}

#Preview {
    SettingsView(needsReset: .constant(false))
}
