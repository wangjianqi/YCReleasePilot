import SwiftUI

struct BuildCardView: View {
    let builds: [BuildInfo]

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(AppStrings.currentBuild)
                        .font(.headline)
                    Spacer()
                    SmallGlassButton(title: "查看全部")
                }

                if let current = builds.first {
                    currentBuild(current)
                }

                Text("版本历史")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.ColorToken.soft)
                    .padding(.top, 2)

                ForEach(builds.dropFirst()) { build in
                    HStack {
                        Text("\(build.id)")
                            .font(.caption.weight(.bold))
                            .frame(width: 30, alignment: .leading)
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
                    .padding(.vertical, 5)
                }

                SmallGlassButton(title: "查看更多版本", systemImage: "arrow.right")
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func currentBuild(_ build: BuildInfo) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Build \(build.id)", systemImage: "sparkles")
                    .font(.headline)
                    .foregroundStyle(.white)
                StatusBadge(title: "最新构建", tint: Theme.ColorToken.blue)
                Spacer()
            }
            infoRow("上传时间", build.uploadedAt)
            infoRow("大小", build.size)
            infoRow("处理状态", build.status, tint: Theme.ColorToken.green)
            SmallGlassButton(title: "查看构建详情")
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
