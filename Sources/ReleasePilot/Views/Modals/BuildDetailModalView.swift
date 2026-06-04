import SwiftUI

struct BuildDetailModalView: View {
    let app: AppItem
    let build: BuildInfo
    let onClose: () -> Void

    var body: some View {
        ModalShell(title: "构建详情", onClose: onClose) {
            VStack(alignment: .leading, spacing: 14) {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    info("App 名称", app.name)
                    info("当前版本", build.version)
                    info("Build 号", "\(build.id)")
                    info("Bundle ID", build.bundleID)
                    info("上传时间", build.uploadedAt)
                    info("文件大小", build.size)
                    info("处理状态", build.status)
                    info("TestFlight", build.testFlightStatus)
                }
                Divider().overlay(Theme.ColorToken.line)
                Text("构建校验结果").font(.headline)
                ForEach(build.validationResults, id: \.self) { result in
                    Label(result, systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(Theme.ColorToken.green)
                }
                Text("上传日志").font(.headline)
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(build.uploadLogs, id: \.self) { log in
                        Text(log)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundStyle(Theme.ColorToken.soft)
                    }
                }
                .padding(12)
                .background(Color.black.opacity(0.22))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }

    private func info(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption2).foregroundStyle(Theme.ColorToken.muted)
            Text(value).font(.caption.weight(.semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
