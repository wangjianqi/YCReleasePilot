import SwiftUI

struct RootView: View {
    @State private var viewModel: ReleaseDashboardViewModel
    @State private var toastService: ToastService
    @State private var membershipViewModel: MembershipViewModel
    @State private var copilotViewModel: CopilotViewModel
    @State private var settingsViewModel: SettingsViewModel

    init() {
        let dashboard = ReleaseDashboardViewModel()
        let toastService = ToastService()
        let membershipService = MembershipService()
        let membershipViewModel = MembershipViewModel(service: membershipService, toastService: toastService)
        let aiProvidersViewModel = AIProvidersViewModel(toastService: toastService)
        let copilotViewModel = CopilotViewModel(
            providerViewModel: aiProvidersViewModel,
            membershipViewModel: membershipViewModel,
            toastService: toastService,
            initialMessages: dashboard.copilotMessages
        )
        let settingsViewModel = SettingsViewModel(
            aiProvidersViewModel: aiProvidersViewModel,
            membershipViewModel: membershipViewModel,
            toastService: toastService,
            onClearChatHistory: {
                copilotViewModel.clearHistory()
            }
        )
        _viewModel = State(initialValue: dashboard)
        _toastService = State(initialValue: toastService)
        _membershipViewModel = State(initialValue: membershipViewModel)
        _copilotViewModel = State(initialValue: copilotViewModel)
        _settingsViewModel = State(initialValue: settingsViewModel)
    }

    var body: some View {
        ZStack {
            background

            HStack(spacing: Theme.Spacing.page) {
                SidebarView(viewModel: viewModel)
                    .frame(width: viewModel.isSidebarCollapsed ? 74 : 252)

                mainContent
                    .frame(maxWidth: .infinity)

                if !viewModel.isCopilotHidden {
                    CopilotPanelView(
                        viewModel: viewModel,
                        copilotViewModel: copilotViewModel,
                        membershipViewModel: membershipViewModel,
                        onOpenSettings: {
                            settingsViewModel.selectedSection = .aiProviders
                            viewModel.selectPage(.settings)
                        }
                    )
                        .frame(width: viewModel.isCopilotExpanded ? 460 : 360)
                } else {
                    Button {
                        viewModel.isCopilotHidden = false
                    } label: {
                        Image(systemName: "sparkles")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(width: 42, height: 42)
                            .background(LinearGradient(colors: [Theme.ColorToken.blue, Theme.ColorToken.purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(10)

            if let dialog = viewModel.activeDialog {
                dialogView(dialog)
            }

            if let toast = toastService.message ?? viewModel.toastMessage {
                ToastView(message: toast) {
                    toastService.clear()
                    viewModel.clearToast()
                }
            }
        }
        .foregroundStyle(Theme.ColorToken.text)
        .sheet(isPresented: Binding(
            get: { membershipViewModel.showingPaywall },
            set: { membershipViewModel.showingPaywall = $0 }
        )) {
            PaywallSheet(membershipViewModel: membershipViewModel)
        }
        .alert(AppStrings.confirmSubmitTitle, isPresented: Binding(
            get: { viewModel.showingSubmitConfirmation },
            set: { viewModel.showingSubmitConfirmation = $0 }
        )) {
            Button(AppStrings.cancel, role: .cancel) {}
            Button(AppStrings.confirmSubmit) {
                viewModel.confirmSubmit()
            }
        } message: {
            Text(AppStrings.confirmSubmitMessage)
        }
        .onChange(of: viewModel.selectedAppID) { _, _ in
            copilotViewModel.replaceMessages(MockData.initialCopilotMessages(for: viewModel.selectedRelease, platform: viewModel.selectedPlatform))
        }
        .onChange(of: viewModel.selectedPlatform) { _, platform in
            copilotViewModel.replaceMessages(MockData.initialCopilotMessages(for: viewModel.selectedRelease, platform: platform))
        }
    }

    private var background: some View {
        ZStack {
            LinearGradient(colors: [Theme.ColorToken.backgroundDeep, Theme.ColorToken.background, Theme.ColorToken.backgroundDeep], startPoint: .topLeading, endPoint: .bottomTrailing)
            RadialGradient(colors: [Theme.ColorToken.blue.opacity(0.18), .clear], center: .topLeading, startRadius: 40, endRadius: 520)
            RadialGradient(colors: [Theme.ColorToken.purple.opacity(0.14), .clear], center: .bottomTrailing, startRadius: 40, endRadius: 600)
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    private var mainContent: some View {
        switch viewModel.currentPage {
        case .dashboard:
            ReleaseCenterView(viewModel: viewModel, membershipViewModel: membershipViewModel)
        case .apps:
            AppsPageView(viewModel: viewModel, membershipViewModel: membershipViewModel)
        case .history:
            HistoryPageView(viewModel: viewModel)
        case .settings:
            SettingsPageView(settingsViewModel: settingsViewModel)
        }
    }

    @ViewBuilder
    private func dialogView(_ dialog: ActiveDialog) -> some View {
        switch dialog {
        case .buildDetail(let build):
            BuildDetailModalView(app: viewModel.selectedApp, build: build) {
                viewModel.closeDialog()
            }
        case .versionHistory:
            VersionHistoryModalView(builds: viewModel.builds, currentBuildID: viewModel.currentBuild?.id) { build in
                viewModel.showBuildDetail(build)
            } onClose: {
                viewModel.closeDialog()
            }
        case .releasePlan:
            ReleasePlanModalView(viewModel: viewModel)
        }
    }
}
