import SwiftUI

struct RootView: View {
    @State private var viewModel = ReleaseDashboardViewModel()

    var body: some View {
        ZStack {
            background

            HStack(spacing: Theme.Spacing.page) {
                SidebarView(viewModel: viewModel)
                    .frame(width: viewModel.isSidebarCollapsed ? 74 : 252)

                mainContent
                    .frame(maxWidth: .infinity)

                if !viewModel.isCopilotHidden {
                    CopilotPanelView(viewModel: viewModel)
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

            if let toast = viewModel.toastMessage {
                VStack {
                    Spacer()
                    Text(toast)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 16)
                        .frame(height: 38)
                        .background(Color.black.opacity(0.7))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Theme.ColorToken.lineStrong, lineWidth: 1))
                        .padding(.bottom, 28)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                                viewModel.clearToast()
                            }
                        }
                }
            }
        }
        .foregroundStyle(Theme.ColorToken.text)
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
            ReleaseCenterView(viewModel: viewModel)
        case .apps:
            AppsPageView(viewModel: viewModel)
        case .history:
            HistoryPageView(viewModel: viewModel)
        case .settings:
            SettingsPageView(viewModel: viewModel)
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
