import SwiftUI

struct SettingsView: View {
    @Bindable var viewModel: SettingsViewModel

    var body: some View {
        HStack(spacing: 0) {
            SettingsSidebar(selection: $viewModel.selectedSection)
                .frame(width: 210)
            Rectangle()
                .fill(Theme.ColorToken.line)
                .frame(width: 1)
            detail
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(surface)
        .sheet(item: Binding(
            get: { viewModel.aiProvidersViewModel.editingDraft },
            set: { viewModel.aiProvidersViewModel.editingDraft = $0 }
        )) { draft in
            AIProviderEditSheet(draft: draft) { updatedDraft in
                viewModel.aiProvidersViewModel.saveDraft(updatedDraft)
            } onCancel: {
                viewModel.aiProvidersViewModel.editingDraft = nil
            }
        }
        .alert("删除 Provider？", isPresented: Binding(
            get: { viewModel.aiProvidersViewModel.providerPendingDeletion != nil },
            set: { if !$0 { viewModel.aiProvidersViewModel.providerPendingDeletion = nil } }
        )) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                viewModel.aiProvidersViewModel.confirmDeleteProvider()
            }
        } message: {
            Text("删除后会同时清空该 Provider 的本地 API Key。")
        }
        .alert("清空所有本地数据？", isPresented: $viewModel.showingClearAllDataConfirmation) {
            Button("取消", role: .cancel) {}
            Button("清空", role: .destructive) {
                viewModel.clearAllLocalData()
            }
        } message: {
            Text("这会清空本地设置、Provider 配置、App Store Connect 配置和 AI 对话历史。")
        }
        .alert("清空 AI 对话历史？", isPresented: $viewModel.showingClearChatHistoryConfirmation) {
            Button("取消", role: .cancel) {}
            Button("清空", role: .destructive) {
                viewModel.clearChatHistory()
            }
        }
        .alert("清空 Provider 配置？", isPresented: $viewModel.showingClearProvidersConfirmation) {
            Button("取消", role: .cancel) {}
            Button("清空", role: .destructive) {
                viewModel.clearProviderConfig()
            }
        } message: {
            Text("AI API Key 也会从 KeychainService 中移除。")
        }
    }

    @ViewBuilder
    private var detail: some View {
        switch viewModel.selectedSection {
        case .general:
            GeneralSettingsView(settings: $viewModel.userSettings)
        case .aiProviders:
            AIProvidersSettingsView(viewModel: viewModel.aiProvidersViewModel)
        case .membership:
            MembershipSettingsView(viewModel: viewModel.membershipViewModel)
        case .appStoreConnect:
            AppStoreConnectSettingsView(viewModel: viewModel)
        case .privacySecurity:
            PrivacySecuritySettingsView(viewModel: viewModel)
        case .about:
            AboutSettingsView(viewModel: viewModel)
        }
    }

    private var surface: some View {
        LinearGradient(colors: [Color(hex: 0x0B1423).opacity(0.88), Color(hex: 0x07101D).opacity(0.9)], startPoint: .top, endPoint: .bottom)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.surface, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: Theme.Radius.surface, style: .continuous).stroke(Theme.ColorToken.line, lineWidth: 1))
    }
}
