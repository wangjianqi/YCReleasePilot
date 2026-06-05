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
        copilotViewModel.loadSession(
            for: dashboard.selectedApp.id,
            platform: dashboard.selectedPlatform,
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
                SidebarView(
                    viewModel: viewModel,
                    membershipViewModel: membershipViewModel,
                    onAddApp: {
                        if !membershipViewModel.status.isPaid && viewModel.apps.count >= 2 {
                            membershipViewModel.openPaywall()
                        } else {
                            viewModel.requestAddApp()
                        }
                    },
                    onManagePlan: {
                        membershipViewModel.openPaywall()
                    },
                    onAccountSettings: {
                        settingsViewModel.selectedSection = .general
                        viewModel.selectPage(.settings)
                    },
                    onMembershipSettings: {
                        settingsViewModel.selectedSection = .membership
                        viewModel.selectPage(.settings)
                    },
                    onAIProviderSettings: {
                        settingsViewModel.selectedSection = .aiProviders
                        viewModel.selectPage(.settings)
                    },
                    onSignOut: {
                        toastService.show("Sign Out Mock")
                    }
                )
                    .frame(width: viewModel.isSidebarCollapsed ? 74 : 252)
                    .frame(maxHeight: .infinity)

                mainContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

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
                        .frame(maxHeight: .infinity)
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)

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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: Binding(
            get: { membershipViewModel.showingPaywall },
            set: { membershipViewModel.showingPaywall = $0 }
        )) {
            PaywallSheet(membershipViewModel: membershipViewModel)
        }
        .sheet(isPresented: Binding(
            get: { viewModel.showingAddAppSheet },
            set: { viewModel.showingAddAppSheet = $0 }
        )) {
            AddAppSheet(draft: viewModel.appDraft) { draft in
                viewModel.addAppFromDraft(draft)
            } onCancel: {
                viewModel.cancelAddApp()
            }
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
            copilotViewModel.loadSession(
                for: viewModel.selectedApp.id,
                platform: viewModel.selectedPlatform,
                initialMessages: viewModel.copilotMessages
            )
        }
        .onChange(of: viewModel.selectedPlatform) { _, platform in
            copilotViewModel.loadSession(
                for: viewModel.selectedApp.id,
                platform: platform,
                initialMessages: viewModel.copilotMessages
            )
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
        case .debug:
            DebugPageView()
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
