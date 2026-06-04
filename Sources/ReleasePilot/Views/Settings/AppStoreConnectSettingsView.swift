import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct AppStoreConnectSettingsView: View {
    @Bindable var viewModel: SettingsViewModel

    var body: some View {
        SettingsDetailShell(title: "App Store Connect", subtitle: "配置 App Store Connect API Key，不与 AI API Key 混用") {
            VStack(spacing: 14) {
                GlassCard {
                    VStack(spacing: 14) {
                        TextField("API Key ID", text: $viewModel.appStoreConnectConfig.apiKeyID)
                            .textFieldStyle(.roundedBorder)
                        TextField("Issuer ID", text: $viewModel.appStoreConnectConfig.issuerID)
                            .textFieldStyle(.roundedBorder)
                        TextField("Team ID", text: $viewModel.appStoreConnectConfig.teamID)
                            .textFieldStyle(.roundedBorder)
                        dropZone
                        HStack {
                            StatusBadge(title: viewModel.appStoreConnectConfig.connectionStatus.title, tint: statusColor(viewModel.appStoreConnectConfig.connectionStatus))
                            Spacer()
                            Button {
                                choosePrivateKey()
                            } label: {
                                Label("Choose .p8", systemImage: "doc.badge.plus")
                            }
                            Button {
                                viewModel.testAppStoreConnect()
                            } label: {
                                Label(viewModel.isTestingAppStoreConnect ? "Testing" : "Test Connection", systemImage: "bolt.horizontal")
                            }
                            .disabled(viewModel.isTestingAppStoreConnect)
                        }
                    }
                }
                helpCard
            }
        }
    }

    private var helpCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Label("如何配置 App Store Connect API Key", systemImage: "questionmark.circle.fill")
                    .font(.headline)
                    .foregroundStyle(Theme.ColorToken.text)

                helpStep(
                    title: "1. 生成 API Key",
                    body: "登录 App Store Connect，进入 Users and Access > Integrations > App Store Connect API。Account Holder 或 Admin 可以在 Team Keys 中生成团队 Key。"
                )
                helpStep(
                    title: "2. API Key ID",
                    body: "生成 Key 后，Apple 页面会显示 Key ID。这里填写这个 Key ID，它会作为 JWT header 的 kid。示例格式类似 2X9R4HXF34。"
                )
                helpStep(
                    title: "3. Issuer ID",
                    body: "Issuer ID 显示在 App Store Connect API Keys 页面，用于 JWT payload 的 iss。通常是 UUID 格式。"
                )
                helpStep(
                    title: "4. .p8 Private Key",
                    body: "点击 Download API Key 下载 .p8 文件。Apple 只允许下载一次，请妥善保存；本应用只保存本地文件路径并在本机签名 JWT。"
                )
                helpStep(
                    title: "5. Team ID",
                    body: "Team ID 是你的 Apple Developer 团队标识，通常可在 Apple Developer 账号 Membership 或证书页面看到。当前读取 App 列表主要依赖 Key ID、Issuer ID 和 .p8，Team ID 作为本地配置标识保留。"
                )

                Divider()
                    .overlay(Theme.ColorToken.line)

                Label("权限建议：如果只是测试同步 App 和构建信息，先给 API Key 分配只读或最低可用权限。不要把 .p8 提交到 Git，也不要分享给他人。", systemImage: "lock.shield.fill")
                    .font(.caption)
                    .foregroundStyle(Theme.ColorToken.soft)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func helpStep(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Theme.ColorToken.text)
            Text(body)
                .font(.caption)
                .foregroundStyle(Theme.ColorToken.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var dropZone: some View {
        VStack(spacing: 8) {
            Image(systemName: "tray.and.arrow.down.fill")
                .font(.title2)
                .foregroundStyle(Theme.ColorToken.blue)
            Text(viewModel.appStoreConnectConfig.privateKeyFileName.isEmpty ? "拖拽上传 .p8 Private Key 文件" : viewModel.appStoreConnectConfig.privateKeyFileName)
                .font(.caption.weight(.semibold))
            Text("仅保存本地文件路径，用于本机生成 App Store Connect JWT")
                .font(.caption2)
                .foregroundStyle(Theme.ColorToken.muted)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 132)
        .background(Color.white.opacity(0.045))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Theme.ColorToken.line, style: StrokeStyle(lineWidth: 1, dash: [6, 6])))
        .onDrop(of: [.fileURL], isTargeted: nil) { providers in
            guard let provider = providers.first else { return false }
            provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, _ in
                guard let data = item as? Data,
                      let url = URL(dataRepresentation: data, relativeTo: nil) else { return }
                Task { @MainActor in
                    viewModel.setPrivateKeyFile(path: url.path)
                }
            }
            return true
        }
    }

    private func choosePrivateKey() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.init(filenameExtension: "p8")!]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        if panel.runModal() == .OK, let url = panel.url {
            viewModel.setPrivateKeyFile(path: url.path)
        }
    }

    private func statusColor(_ status: AppStoreConnectConnectionStatus) -> Color {
        switch status {
        case .connected: Theme.ColorToken.green
        case .missingFields, .failed: Theme.ColorToken.orange
        case .notTested: Theme.ColorToken.muted
        }
    }
}
