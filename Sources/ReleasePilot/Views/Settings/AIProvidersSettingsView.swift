import SwiftUI

struct AIProvidersSettingsView: View {
    @Bindable var viewModel: AIProvidersViewModel

    var body: some View {
        SettingsDetailShell(title: "AI Providers", subtitle: "添加自己的 AI API Key，选择默认模型和兼容接口") {
            HStack {
                Button {
                    viewModel.addProvider()
                } label: {
                    Label("Add Provider", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
                Spacer()
            }

            if viewModel.providers.isEmpty {
                GlassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Image(systemName: "key.fill")
                            .font(.title2)
                            .foregroundStyle(Theme.ColorToken.purple)
                        Text("还没有配置 AI Provider")
                            .font(.headline)
                        Text("添加 OpenAI、Claude、Gemini、DeepSeek、Qwen、OpenRouter 或 OpenAI Compatible API Key 后即可使用 AI Copilot。")
                            .font(.caption)
                            .foregroundStyle(Theme.ColorToken.muted)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                VStack(spacing: 10) {
                    ForEach(viewModel.providers) { provider in
                        providerRow(provider)
                    }
                }
            }
        }
    }

    private func providerRow(_ provider: AIProvider) -> some View {
        GlassCard(cornerRadius: 16, padding: 12) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: provider.type.symbol)
                        .foregroundStyle(Theme.ColorToken.purple)
                        .frame(width: 32, height: 32)
                        .background(Theme.ColorToken.purple.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 8) {
                            Text(provider.displayName)
                                .font(.headline)
                            if provider.isDefault {
                                StatusBadge(title: "Default", tint: Theme.ColorToken.blue)
                            }
                            StatusBadge(title: provider.connectionStatus.title, tint: statusColor(provider.connectionStatus))
                        }
                        Text("\(provider.baseURL) · \(provider.defaultModel)")
                            .font(.caption)
                            .foregroundStyle(Theme.ColorToken.muted)
                    }
                    Spacer()
                    Toggle("", isOn: .constant(provider.isEnabled))
                        .labelsHidden()
                        .disabled(true)
                }
                HStack(spacing: 8) {
                    Text("API Key: \(viewModel.maskedAPIKey(for: provider))")
                        .font(.caption2)
                        .foregroundStyle(Theme.ColorToken.muted)
                    Spacer()
                    SmallGlassButton(title: "Edit", systemImage: "pencil") {
                        viewModel.editProvider(provider)
                    }
                    SmallGlassButton(title: viewModel.testingProviderIDs.contains(provider.id) ? "Testing" : "Test Connection", systemImage: "bolt.horizontal") {
                        viewModel.testConnection(provider)
                    }
                    .disabled(viewModel.testingProviderIDs.contains(provider.id))
                    SmallGlassButton(title: "Set Default", systemImage: "checkmark.seal") {
                        viewModel.setDefault(provider)
                    }
                    .disabled(provider.isDefault)
                    SmallGlassButton(title: "Delete", systemImage: "trash") {
                        viewModel.requestDelete(provider)
                    }
                }
            }
        }
    }

    private func statusColor(_ status: AIProviderConnectionStatus) -> Color {
        switch status {
        case .connected: Theme.ColorToken.green
        case .missingAPIKey, .connectionFailed: Theme.ColorToken.orange
        case .notConfigured: Theme.ColorToken.muted
        }
    }
}
