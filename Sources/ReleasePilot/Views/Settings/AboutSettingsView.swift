import SwiftUI

struct AboutSettingsView: View {
    @Bindable var viewModel: SettingsViewModel

    var body: some View {
        SettingsDetailShell(title: "About", subtitle: "ReleasePilot 应用信息") {
            GlassCard {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(LinearGradient(colors: [Theme.ColorToken.blue, Theme.ColorToken.purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                            Image(systemName: "paperplane.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                        }
                        .frame(width: 58, height: 58)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("ReleasePilot")
                                .font(.title2.weight(.bold))
                            Text("Version 0.1.0 · Build 1")
                                .font(.caption)
                                .foregroundStyle(Theme.ColorToken.muted)
                        }
                    }
                    Divider()
                    HStack {
                        SmallGlassButton(title: "官网", systemImage: "globe") {}
                        SmallGlassButton(title: "隐私政策", systemImage: "hand.raised.fill") {}
                        SmallGlassButton(title: "用户协议", systemImage: "doc.text.fill") {}
                        Spacer()
                        Button("检查更新") {}
                    }
                }
            }
        }
    }
}
