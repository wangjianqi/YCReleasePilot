import SwiftUI

struct SidebarView: View {
    var viewModel: ReleaseDashboardViewModel
    @Bindable var membershipViewModel: MembershipViewModel
    let onAddApp: () -> Void
    let onManagePlan: () -> Void
    let onAccountSettings: () -> Void
    let onMembershipSettings: () -> Void
    let onAIProviderSettings: () -> Void
    let onSignOut: () -> Void

    @State private var showingAccountMenu = false

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            header
            navigation
            Divider().overlay(Theme.ColorToken.line)
            if !viewModel.isSidebarCollapsed {
                appList
            } else {
                compactAppList
            }
            Spacer(minLength: 10)
            if !viewModel.isSidebarCollapsed {
                proPlan
                userInfo
            }
            collapseBar
        }
        .padding(14)
        .background(surface)
    }

    private var surface: some View {
        LinearGradient(colors: [Color(hex: 0x0A1628).opacity(0.92), Color(hex: 0x06101E).opacity(0.94)], startPoint: .top, endPoint: .bottom)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.surface, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.surface, style: .continuous)
                    .stroke(Theme.ColorToken.line, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.36), radius: 30, x: 0, y: 20)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Circle().fill(Color(hex: 0xFF5F57)).frame(width: 12, height: 12)
                Circle().fill(Color(hex: 0xFFBD2E)).frame(width: 12, height: 12)
                Circle().fill(Color(hex: 0x28C840)).frame(width: 12, height: 12)
            }

            HStack(spacing: 10) {
                ZStack {
                    LinearGradient(colors: [Theme.ColorToken.blue, Theme.ColorToken.purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                    Image(systemName: "paperplane.fill")
                        .foregroundStyle(.white)
                        .font(.system(size: 16, weight: .bold))
                }
                .frame(width: 34, height: 34)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                if !viewModel.isSidebarCollapsed {
                    Text(AppStrings.appName)
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(.white)

                    StatusBadge(title: AppStrings.versionPill, tint: Theme.ColorToken.blue)
                }
            }
        }
    }

    private var navigation: some View {
        VStack(spacing: 7) {
            ForEach(MainPage.allCases) { page in
                Button {
                    viewModel.selectPage(page)
                } label: {
                    SidebarNavItem(title: page.title, systemImage: page.symbol, isActive: viewModel.currentPage == page, isCompact: viewModel.isSidebarCollapsed)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var appList: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(AppStrings.yourApps.uppercased())
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Theme.ColorToken.muted)
                Spacer()
                Button(action: onAddApp) {
                    Image(systemName: "plus")
                        .font(.caption.weight(.bold))
                        .frame(width: 24, height: 24)
                        .background(Color.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 4)

            VStack(spacing: 8) {
                ForEach(viewModel.apps) { app in
                    Button {
                        viewModel.selectApp(app)
                    } label: {
                        AppListItemView(app: app, isSelected: app.id == viewModel.selectedAppID)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var compactAppList: some View {
        VStack(spacing: 8) {
            ForEach(viewModel.apps) { app in
                Button {
                    viewModel.selectApp(app)
                } label: {
                    AppIconView(app: app, size: 38)
                        .overlay(
                            RoundedRectangle(cornerRadius: 11, style: .continuous)
                                .stroke(app.id == viewModel.selectedAppID ? Theme.ColorToken.blue.opacity(0.8) : .clear, lineWidth: 2)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var proPlan: some View {
        GlassCard(cornerRadius: Theme.Radius.large, padding: 14) {
            VStack(alignment: .leading, spacing: 10) {
                Label(membershipViewModel.status.isPaid ? "\(membershipViewModel.status.title) Plan" : AppStrings.proPlan, systemImage: "diamond.fill")
                    .font(.headline)
                    .foregroundStyle(Color(hex: 0xFDE047))
                Text(membershipViewModel.status.isPaid ? "AI Copilot Unlimited" : "升级后解锁完整 AI Copilot")
                    .font(.caption)
                    .foregroundStyle(Theme.ColorToken.muted)
                SmallGlassButton(title: AppStrings.managePlan, systemImage: "arrow.right", action: onManagePlan)
            }
        }
    }

    private var userInfo: some View {
        Button {
            showingAccountMenu.toggle()
        } label: {
            HStack(spacing: 10) {
                ZStack {
                    Circle().fill(Theme.ColorToken.text)
                    Text(viewModel.accountAvatarText)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Theme.ColorToken.panel)
                }
                .frame(width: 38, height: 38)

                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.accountDisplayName)
                        .font(.system(size: 13, weight: .semibold))
                    Text(viewModel.accountDisplaySubtitle)
                        .font(.caption)
                        .foregroundStyle(Theme.ColorToken.muted)
                        .lineLimit(1)
                }
                Spacer()
                Image(systemName: showingAccountMenu ? "chevron.up" : "chevron.down")
                    .foregroundStyle(Theme.ColorToken.muted)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 4)
        .popover(isPresented: $showingAccountMenu, arrowEdge: .bottom) {
            AccountMenuView(
                onAccountSettings: {
                    showingAccountMenu = false
                    onAccountSettings()
                },
                onMembershipSettings: {
                    showingAccountMenu = false
                    onMembershipSettings()
                },
                onAIProviderSettings: {
                    showingAccountMenu = false
                    onAIProviderSettings()
                },
                onSignOut: {
                    showingAccountMenu = false
                    onSignOut()
                }
            )
        }
    }

    private var collapseBar: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.isSidebarCollapsed.toggle()
            }
        } label: {
            HStack {
                Image(systemName: "sidebar.left")
                if !viewModel.isSidebarCollapsed {
                    Spacer()
                    Image(systemName: "chevron.left.2")
                }
            }
            .font(.caption)
            .foregroundStyle(Theme.ColorToken.muted)
            .padding(12)
            .background(Color.white.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
