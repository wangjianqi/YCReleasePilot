import SwiftUI

struct BuildCardView: View {
    let builds: [BuildInfo]
    let showAllBuilds: Bool
    let isRefreshing: Bool
    let onToggleBuilds: () -> Void
    let onRefresh: () -> Void
    let onShowAllVersions: () -> Void
    let onShowBuildDetail: (BuildInfo) -> Void

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(AppStrings.currentBuild)
                        .font(.headline)
                    Spacer()
                    SmallGlassButton(
                        title: isRefreshing ? "更新中" : "同步构建",
                        systemImage: isRefreshing ? "arrow.triangle.2.circlepath" : "arrow.clockwise",
                        action: onRefresh
                    )
                    .disabled(isRefreshing)
                    SmallGlassButton(title: showAllBuilds ? "收起" : "查看全部", action: onToggleBuilds)
                }

                if let current = builds.first {
                    currentBuild(current)
                } else {
                    emptyBuildState
                }

                Text("版本历史")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.ColorToken.soft)
                    .padding(.top, 2)

                ForEach(builds.dropFirst()) { build in
                    Button {
                        onShowBuildDetail(build)
                    } label: {
                        HStack {
                            Text("#\(build.buildNumber)")
                                .font(.caption.weight(.bold))
                                .frame(width: 70, alignment: .leading)
                            Text(build.version)
                                .font(.caption)
                            Spacer()
                            Text(build.uploadedAt)
                                .font(.caption2)
                                .foregroundStyle(Theme.ColorToken.muted)
                            Text(build.size)
                                .font(.caption2)
                                .foregroundStyle(Theme.ColorToken.muted)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 5)
                }

                SmallGlassButton(title: "查看更多构建", systemImage: "arrow.right", action: onShowAllVersions)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func currentBuild(_ build: BuildInfo) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Build \(build.buildNumber)", systemImage: "shippingbox.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                StatusBadge(title: "最新构建", tint: Theme.ColorToken.blue)
                Spacer()
            }
            infoRow("上传时间", build.uploadedAt)
            infoRow("大小", build.size)
            infoRow("处理状态", build.status, tint: Theme.ColorToken.green)
            SmallGlassButton(title: "查看构建详情") {
                onShowBuildDetail(build)
            }
                .frame(maxWidth: .infinity)
        }
        .padding(12)
        .background(Theme.ColorToken.blue.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous)
                .stroke(Theme.ColorToken.lineStrong, lineWidth: 1)
        )
    }

    private var emptyBuildState: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("当前 App 暂无 ASC 构建记录", systemImage: "shippingbox")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Theme.ColorToken.soft)
            Text("同步成功但 App Store Connect 没有返回 builds；ReleasePilot 不会生成模拟构建兜底。")
                .font(.caption2)
                .foregroundStyle(Theme.ColorToken.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Theme.ColorToken.panel.opacity(0.26))
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous)
                .stroke(Theme.ColorToken.line, lineWidth: 1)
        )
    }

    private func infoRow(_ label: String, _ value: String, tint: Color = Theme.ColorToken.soft) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(Theme.ColorToken.muted)
                .frame(width: 62, alignment: .leading)
            Text(value)
                .font(.caption)
                .foregroundStyle(tint)
        }
    }
}
