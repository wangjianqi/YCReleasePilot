import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct AppStoreConnectSettingsView: View {
    @Bindable var viewModel: SettingsViewModel

    var body: some View {
        SettingsDetailShell(title: "App Store Connect", subtitle: "配置 App Store Connect API Key，不与 AI API Key 混用") {
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
        }
    }

    private var dropZone: some View {
        VStack(spacing: 8) {
            Image(systemName: "tray.and.arrow.down.fill")
                .font(.title2)
                .foregroundStyle(Theme.ColorToken.blue)
            Text(viewModel.appStoreConnectConfig.privateKeyFileName.isEmpty ? "拖拽上传 .p8 Private Key 文件" : viewModel.appStoreConnectConfig.privateKeyFileName)
                .font(.caption.weight(.semibold))
            Text("仅保存本地文件路径用于 Mock 配置")
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
