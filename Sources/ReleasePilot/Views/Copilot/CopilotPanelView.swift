import SwiftUI

struct CopilotPanelView: View {
    @Bindable var viewModel: ReleaseDashboardViewModel
    @Bindable var copilotViewModel: CopilotViewModel
    @Bindable var membershipViewModel: MembershipViewModel
    let onOpenSettings: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            header
            tabs
            Group {
                switch copilotViewModel.selectedTab {
                case .chat:
                    CopilotChatView(
                        dashboardViewModel: viewModel,
                        copilotViewModel: copilotViewModel,
                        membershipViewModel: membershipViewModel,
                        onOpenSettings: onOpenSettings,
                        onApplyReviewNote: {
                            viewModel.applyReviewNote()
                        }
                    )
                case .suggestions:
                    CopilotSuggestionsView(
                        dashboardViewModel: viewModel,
                        copilotViewModel: copilotViewModel
                    )
                }
            }
            footer
        }
        .padding(16)
        .background(surface)
        .onAppear {
            copilotViewModel.syncSelectedProvider()
        }
    }

    private var surface: some View {
        LinearGradient(colors: [Color(hex: 0x0A1628).opacity(0.9), Color(hex: 0x06101E).opacity(0.94)], startPoint: .top, endPoint: .bottom)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.surface, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: Theme.Radius.surface, style: .continuous).stroke(Theme.ColorToken.line, lineWidth: 1))
            .shadow(color: .black.opacity(0.36), radius: 30, x: 0, y: 20)
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(Theme.ColorToken.purple)
                    Text(AppStrings.copilotTitle)
                        .font(.title3.weight(.bold))
                    StatusBadge(title: AppStrings.copilotBeta, tint: Theme.ColorToken.purple)
                }
                Text(copilotViewModel.usageLabel)
                    .font(.caption)
                    .foregroundStyle(Theme.ColorToken.muted)
            }
            Spacer()
            Button {
                copilotViewModel.newSession(appID: viewModel.selectedApp.id, platform: viewModel.selectedPlatform)
            } label: {
                Image(systemName: "square.and.pencil")
            }
            .buttonStyle(.plain)
            Button {
                copilotViewModel.showingSessionHistory.toggle()
            } label: {
                Image(systemName: "clock.arrow.circlepath")
            }
            .buttonStyle(.plain)
            .popover(isPresented: $copilotViewModel.showingSessionHistory, arrowEdge: .bottom) {
                CopilotSessionHistoryView(
                    sessions: copilotViewModel.historySessions,
                    selectedSessionID: copilotViewModel.selectedSessionID,
                    onSelect: { session in
                        copilotViewModel.showingSessionHistory = false
                        copilotViewModel.selectSession(session)
                    },
                    onDelete: { session in
                        copilotViewModel.deleteSession(
                            session,
                            fallbackAppID: viewModel.selectedApp.id,
                            fallbackPlatform: viewModel.selectedPlatform
                        )
                    }
                )
            }
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.isCopilotExpanded.toggle()
                }
            } label: {
                Image(systemName: viewModel.isCopilotExpanded ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
            }
            .buttonStyle(.plain)
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.isCopilotHidden = true
                }
            } label: {
                Image(systemName: "xmark")
            }
            .buttonStyle(.plain)
        }
        .font(.caption)
        .foregroundStyle(Theme.ColorToken.muted)
    }

    private var tabs: some View {
        HStack(spacing: 4) {
            tabButton("Chat", tab: .chat)
            tabButton("Suggestions (\(copilotViewModel.visibleSuggestions.count))", tab: .suggestions)
        }
        .padding(4)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
    }

    private func tabButton(_ title: String, tab: CopilotTab) -> some View {
        Button {
            copilotViewModel.selectedTab = tab
        } label: {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(copilotViewModel.selectedTab == tab ? .white : Theme.ColorToken.muted)
                .frame(maxWidth: .infinity)
                .frame(height: 32)
                .background(copilotViewModel.selectedTab == tab ? Color.white.opacity(0.08) : .clear)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var footer: some View {
        Label("当前阶段使用本地 Mock 回复，后续可替换为真实 Provider 请求", systemImage: "info.circle")
            .font(.caption2)
            .foregroundStyle(Theme.ColorToken.muted)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
