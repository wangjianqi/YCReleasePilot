import SwiftUI

struct HistoryPageView: View {
    var viewModel: ReleaseDashboardViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("History")
                        .font(.system(size: 26, weight: .bold))
                    Text(viewModel.isUsingAppStoreConnectData ? "来自 App Store Connect 同步的真实版本历史" : "本地演示发布历史，包含版本、平台、提交时间和审核状态")
                        .font(.caption)
                        .foregroundStyle(Theme.ColorToken.muted)
                }

                GlassCard {
                    VStack(spacing: 0) {
                        if viewModel.historyItems.isEmpty {
                            emptyState
                        } else {
                            historyHeader
                            ForEach(viewModel.historyItems) { item in
                                HStack {
                                    Text(item.appName).frame(width: 120, alignment: .leading)
                                    Text(item.platform.rawValue).frame(width: 80, alignment: .leading)
                                    Text(item.version).frame(width: 80, alignment: .leading)
                                    Text(item.build > 0 ? "#\(item.build)" : "暂无").frame(width: 70, alignment: .leading)
                                    StatusBadge(title: item.status, tint: tint(for: item.status))
                                    Spacer()
                                    Text(item.submittedAt)
                                        .foregroundStyle(Theme.ColorToken.muted)
                                }
                                .font(.caption)
                                .padding(.vertical, 11)
                                Divider().overlay(Theme.ColorToken.line)
                            }
                        }
                    }
                }
            }
            .padding(18)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(surface)
    }

    private var historyHeader: some View {
        HStack {
            Text("App").frame(width: 120, alignment: .leading)
            Text("平台").frame(width: 80, alignment: .leading)
            Text("版本").frame(width: 80, alignment: .leading)
            Text("Build").frame(width: 70, alignment: .leading)
            Text("状态")
            Spacer()
            Text("提交时间")
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(Theme.ColorToken.muted)
        .padding(.bottom, 10)
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("暂无 ASC 版本历史", systemImage: "clock")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Theme.ColorToken.soft)
            Text("App Store Connect 没有返回 appStoreVersions，ReleasePilot 不会生成模拟版本历史兜底。")
                .font(.caption2)
                .foregroundStyle(Theme.ColorToken.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 10)
    }

    private func tint(for status: String) -> Color {
        switch status {
        case "Approved", "Released": Theme.ColorToken.green
        case "Rejected": Theme.ColorToken.red
        default: Theme.ColorToken.orange
        }
    }

    private var surface: some View {
        LinearGradient(colors: [Color(hex: 0x0B1423).opacity(0.88), Color(hex: 0x07101D).opacity(0.9)], startPoint: .top, endPoint: .bottom)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.surface, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: Theme.Radius.surface, style: .continuous).stroke(Theme.ColorToken.line, lineWidth: 1))
    }
}
