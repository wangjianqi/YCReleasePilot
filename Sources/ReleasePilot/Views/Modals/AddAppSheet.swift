import SwiftUI

struct AddAppSheet: View {
    @State private var draft: AppDraft
    let onSave: (AppDraft) -> Void
    let onCancel: () -> Void

    init(draft: AppDraft, onSave: @escaping (AppDraft) -> Void, onCancel: @escaping () -> Void) {
        _draft = State(initialValue: draft)
        self.onSave = onSave
        self.onCancel = onCancel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text("添加 App")
                    .font(.title2.weight(.bold))
                Text("创建本地演示 App，用于 ReleasePilot 发布流程预览。")
                    .font(.caption)
                    .foregroundStyle(Theme.ColorToken.muted)
            }

            Form {
                TextField("App 名称", text: $draft.name)
                TextField("Bundle ID", text: $draft.bundleID)
                HStack {
                    TextField("版本号", text: $draft.version)
                    TextField("Build", text: $draft.buildNumber)
                }
                Picker("默认平台", selection: $draft.primaryPlatform) {
                    ForEach(Platform.allCases) { platform in
                        Text(platform.rawValue).tag(platform)
                    }
                }
                Picker("图标", selection: $draft.iconSymbol) {
                    Text("App").tag("app.fill")
                    Text("Sparkles").tag("sparkles")
                    Text("Camera").tag("camera.aperture")
                    Text("Video").tag("play.rectangle.fill")
                    Text("Chat").tag("bubble.left.and.bubble.right.fill")
                    Text("Music").tag("music.note.list")
                }
                Picker("状态模板", selection: $draft.statusTemplate) {
                    ForEach(AppStatusTemplate.allCases) { template in
                        Text(template.rawValue).tag(template)
                    }
                }
            }
            .formStyle(.grouped)

            HStack {
                Spacer()
                Button("取消", action: onCancel)
                Button("保存") {
                    onSave(draft)
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!draft.canSave)
            }
        }
        .padding(24)
        .frame(width: 560)
        .background(Theme.ColorToken.panel)
    }
}
