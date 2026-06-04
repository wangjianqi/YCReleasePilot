import SwiftUI

struct SettingsPageView: View {
    var viewModel: ReleaseDashboardViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Settings")
                        .font(.system(size: 26, weight: .bold))
                    Text("账号、API Key、模型配置和 App Store Connect 连接预留项")
                        .font(.caption)
                        .foregroundStyle(Theme.ColorToken.muted)
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(viewModel.settingsSections) { section in
                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(section.title)
                                    .font(.headline)
                                ForEach(section.rows) { row in
                                    HStack(spacing: 10) {
                                        Image(systemName: row.symbol)
                                            .foregroundStyle(row.isEnabled ? Theme.ColorToken.blue : Theme.ColorToken.muted)
                                            .frame(width: 22)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(row.title)
                                                .font(.caption.weight(.semibold))
                                            Text(row.value)
                                                .font(.caption2)
                                                .foregroundStyle(Theme.ColorToken.muted)
                                        }
                                        Spacer()
                                        Toggle("", isOn: .constant(row.isEnabled))
                                            .labelsHidden()
                                            .disabled(true)
                                    }
                                    .padding(.vertical, 6)
                                }
                            }
                        }
                    }
                }
            }
            .padding(18)
        }
        .background(surface)
    }

    private var surface: some View {
        LinearGradient(colors: [Color(hex: 0x0B1423).opacity(0.88), Color(hex: 0x07101D).opacity(0.9)], startPoint: .top, endPoint: .bottom)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.surface, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: Theme.Radius.surface, style: .continuous).stroke(Theme.ColorToken.line, lineWidth: 1))
    }
}
