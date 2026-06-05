import SwiftUI

struct AppsPageView: View {
    @Bindable var viewModel: ReleaseDashboardViewModel
    @Bindable var membershipViewModel: MembershipViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                pageHeader
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 240), spacing: 12)], spacing: 12) {
                    ForEach(Array(viewModel.filteredApps.enumerated()), id: \.element.id) { index, app in
                        let isLocked = !membershipViewModel.status.isPaid && index >= 2
                        Button {
                            guard !isLocked else {
                                membershipViewModel.openPaywall()
                                return
                            }
                            viewModel.selectApp(app)
                            viewModel.selectPage(.dashboard)
                        } label: {
                            GlassCard {
                                HStack(spacing: 12) {
                                    AppIconView(app: app, size: 52)
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(app.name)
                                            .font(.headline)
                                        Text("v\(app.version) (\(app.buildNumber))")
                                            .font(.caption)
                                            .foregroundStyle(Theme.ColorToken.muted)
                                        StatusBadge(title: app.status, tint: app.id == viewModel.selectedAppID ? Theme.ColorToken.blue : Theme.ColorToken.green)
                                    }
                                    Spacer()
                                    if isLocked {
                                        Image(systemName: "lock.fill")
                                            .foregroundStyle(Theme.ColorToken.orange)
                                    }
                                }
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                                    .stroke(app.id == viewModel.selectedAppID ? Theme.ColorToken.blue.opacity(0.8) : .clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(18)
        }
        .background(surface)
    }

    private var pageHeader: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Apps")
                    .font(.system(size: 26, weight: .bold))
                Text(viewModel.isUsingAppStoreConnectData ? "来自 App Store Connect 的真实 App 列表，选择 App 后返回 Dashboard 查看发布状态" : "管理本地 Mock App 列表，选择 App 后返回 Dashboard 查看发布状态")
                    .font(.caption)
                    .foregroundStyle(Theme.ColorToken.muted)
            }
            Spacer()
            TextField("搜索 App", text: $viewModel.appSearchText)
                .textFieldStyle(.plain)
                .padding(.horizontal, 12)
                .frame(width: 220, height: 36)
                .background(Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            SmallGlassButton(title: "添加 App", systemImage: "plus") {
                if !membershipViewModel.status.isPaid && viewModel.apps.count >= 2 {
                    membershipViewModel.openPaywall()
                } else {
                    viewModel.requestAddApp()
                }
            }
        }
    }

    private var surface: some View {
        LinearGradient(colors: [Color(hex: 0x0B1423).opacity(0.88), Color(hex: 0x07101D).opacity(0.9)], startPoint: .top, endPoint: .bottom)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.surface, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: Theme.Radius.surface, style: .continuous).stroke(Theme.ColorToken.line, lineWidth: 1))
    }
}
