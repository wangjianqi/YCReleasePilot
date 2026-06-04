import SwiftUI

struct VersionHistoryModalView: View {
    let builds: [BuildInfo]
    let currentBuildID: Int?
    let onSelect: (BuildInfo) -> Void
    let onClose: () -> Void

    var body: some View {
        ModalShell(title: "完整版本历史", onClose: onClose) {
            VStack(spacing: 0) {
                header
                ForEach(builds) { build in
                    Button {
                        onSelect(build)
                    } label: {
                        HStack {
                            Text(build.version).frame(width: 90, alignment: .leading)
                            Text("#\(build.id)").frame(width: 70, alignment: .leading)
                            StatusBadge(title: build.status, tint: build.id == currentBuildID ? Theme.ColorToken.blue : Theme.ColorToken.green)
                            Text(build.uploadedAt).frame(width: 130, alignment: .leading)
                            Text(build.size).frame(width: 80, alignment: .leading)
                            Spacer()
                            Text(build.submissionStatus).foregroundStyle(Theme.ColorToken.muted)
                        }
                        .font(.caption)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 8)
                        .background(build.id == currentBuildID ? Theme.ColorToken.blue.opacity(0.14) : Color.clear)
                    }
                    .buttonStyle(.plain)
                    Divider().overlay(Theme.ColorToken.line)
                }
            }
        }
    }

    private var header: some View {
        HStack {
            Text("版本号").frame(width: 90, alignment: .leading)
            Text("Build").frame(width: 70, alignment: .leading)
            Text("状态").frame(width: 130, alignment: .leading)
            Text("上传时间").frame(width: 130, alignment: .leading)
            Text("大小").frame(width: 80, alignment: .leading)
            Spacer()
            Text("提交状态")
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(Theme.ColorToken.muted)
        .padding(.bottom, 8)
    }
}
