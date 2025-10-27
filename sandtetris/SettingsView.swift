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

    private var sensitivityLabel: String {
        String(format: "%.1f×", settings.movementSensitivity)
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
