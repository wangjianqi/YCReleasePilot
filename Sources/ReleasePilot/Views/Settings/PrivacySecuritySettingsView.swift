import SwiftUI

struct PrivacySecuritySettingsView: View {
    @Bindable var viewModel: SettingsViewModel

    var body: some View {
        SettingsDetailShell(title: "Privacy & Security", subtitle: "本地保存、Keychain 和数据清理") {
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    Label("设置和 Provider 配置保存在本机。", systemImage: "internaldrive.fill")
                    Label("API Key 保存在 KeychainService，不写入 UserDefaults 明文。", systemImage: "key.fill")
                    Label("不上传用户 Key 到服务器。", systemImage: "lock.shield.fill")
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(Theme.ColorToken.soft)
            }

            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    SectionTitle(title: "危险操作")
                    Button(role: .destructive) {
                        viewModel.showingClearAllDataConfirmation = true
                    } label: {
                        Label("清空所有本地数据", systemImage: "trash.fill")
                    }
                    Button(role: .destructive) {
                        viewModel.showingClearChatHistoryConfirmation = true
                    } label: {
                        Label("清空 AI 对话历史", systemImage: "bubble.left.and.bubble.right")
                    }
                    Button(role: .destructive) {
                        viewModel.showingClearProvidersConfirmation = true
                    } label: {
                        Label("清空 Provider 配置", systemImage: "key.slash.fill")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
