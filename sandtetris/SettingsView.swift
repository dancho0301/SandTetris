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
                    Text(LocalizedStringKey("settings_touch_control_description"))
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
                    Text(LocalizedStringKey("settings_section_touch_control"))
                }

                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(LocalizedStringKey("settings_sensitivity_label"))
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
                            Text(LocalizedStringKey("settings_speed_slow"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(LocalizedStringKey("settings_speed_normal"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(LocalizedStringKey("settings_speed_fast"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)

                    Text(LocalizedStringKey("settings_sensitivity_description"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                } header: {
                    Text(LocalizedStringKey("settings_section_movement_sensitivity"))
                }

                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(LocalizedStringKey("settings_width_label"))
                                .font(.body)
                            Spacer()
                            Text("\(settings.gameAreaWidth)\(NSLocalizedString("settings_cells_unit", comment: ""))")
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
                            Text(LocalizedStringKey("settings_width_narrow"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(LocalizedStringKey("settings_speed_normal"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(LocalizedStringKey("settings_width_wide"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)

                    Text(LocalizedStringKey("settings_game_area_description"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                } header: {
                    Text(LocalizedStringKey("settings_section_game_area"))
                }

                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(LocalizedStringKey("settings_color_count_label"))
                                .font(.body)
                            Spacer()
                            Text("\(settings.colorCount)\(NSLocalizedString("settings_colors_unit", comment: ""))")
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
                            Text(LocalizedStringKey("settings_difficulty_easy"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(LocalizedStringKey("settings_speed_normal"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(LocalizedStringKey("settings_difficulty_hard"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)

                    Text(LocalizedStringKey("settings_color_count_description"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                } header: {
                    Text(LocalizedStringKey("settings_section_difficulty"))
                }

                Section {
                    HStack {
                        Text(LocalizedStringKey("settings_version_label"))
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text(LocalizedStringKey("settings_section_app_info"))
                }
            }
            .navigationTitle(LocalizedStringKey("settings_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedStringKey("settings_done")) {
                        handleDismiss()
                    }
                }
            }
            .onAppear {
                // 元の設定値を保存
                originalGameAreaWidth = settings.gameAreaWidth
                originalColorCount = settings.colorCount
            }
            .alert(LocalizedStringKey("settings_game_settings_changed_title"), isPresented: $showResetConfirmation) {
                Button(LocalizedStringKey("settings_reset_button"), role: .destructive) {
                    // 新しい設定でゲームをリセット
                    needsReset = true
                    dismiss()
                }
                Button(LocalizedStringKey("settings_revert_button"), role: .cancel) {
                    // 設定を元に戻す
                    settings.gameAreaWidth = originalGameAreaWidth
                    settings.colorCount = originalColorCount
                    dismiss()
                }
            } message: {
                Text(LocalizedStringKey("settings_game_settings_changed_message"))
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
