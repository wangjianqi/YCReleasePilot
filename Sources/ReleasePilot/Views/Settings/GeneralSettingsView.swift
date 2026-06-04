import SwiftUI

struct GeneralSettingsView: View {
    @Binding var settings: UserSettings

    var body: some View {
        SettingsDetailShell(title: "General", subtitle: "默认启动、平台和显示偏好") {
            GlassCard {
                VStack(spacing: 14) {
                    SettingsPickerRow(title: "默认启动页面") {
                        Picker("", selection: $settings.startupPage) {
                            ForEach(StartupPage.allCases) { page in
                                Text(page.rawValue).tag(page)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 190)
                    }
                    SettingsPickerRow(title: "默认平台") {
                        Picker("", selection: $settings.defaultPlatform) {
                            ForEach(Platform.allCases) { platform in
                                Text(platform.rawValue).tag(platform)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 190)
                    }
                    SettingsPickerRow(title: "语言") {
                        Picker("", selection: $settings.language) {
                            ForEach(AppLanguage.allCases) { language in
                                Text(language.rawValue).tag(language)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 190)
                    }
                    SettingsValueRow(title: "外观", value: "Dark Only")
                    Toggle("启动时自动检查版本", isOn: $settings.automaticallyChecksVersionOnLaunch)
                        .font(.caption.weight(.semibold))
                }
            }
        }
    }
}

struct SettingsDetailShell<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder var content: Content

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 26, weight: .bold))
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Theme.ColorToken.muted)
                }
                content
            }
            .padding(18)
        }
    }
}

struct SettingsPickerRow<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        HStack {
            Text(title)
                .font(.caption.weight(.semibold))
            Spacer()
            content
        }
    }
}

struct SettingsValueRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.caption.weight(.semibold))
            Spacer()
            Text(value)
                .font(.caption)
                .foregroundStyle(Theme.ColorToken.muted)
        }
    }
}
