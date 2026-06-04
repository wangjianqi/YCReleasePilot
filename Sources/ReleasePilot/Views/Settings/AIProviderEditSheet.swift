import AppKit
import SwiftUI

struct AIProviderEditSheet: View {
    @State private var draft: AIProviderDraft
    let onSave: (AIProviderDraft) -> Void
    let onCancel: () -> Void

    init(draft: AIProviderDraft, onSave: @escaping (AIProviderDraft) -> Void, onCancel: @escaping () -> Void) {
        _draft = State(initialValue: draft)
        self.onSave = onSave
        self.onCancel = onCancel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(draft.providerID == nil ? "Add Provider" : "Edit Provider")
                        .font(.title2.weight(.bold))
                    Text("API Key 将通过 KeychainService 保存，不写入 Provider 配置。")
                        .font(.caption)
                        .foregroundStyle(Theme.ColorToken.muted)
                }
                Spacer()
            }

            Form {
                Picker("Provider Type", selection: $draft.type) {
                    ForEach(AIProviderType.allCases) { type in
                        Text(type.name).tag(type)
                    }
                }
                .onChange(of: draft.type) { _, _ in
                    draft.applyTypeDefaults()
                }
                TextField("Display Name", text: $draft.displayName)
                apiKeyRow
                TextField("Base URL", text: $draft.baseURL)
                TextField("Default Model", text: $draft.defaultModel)
                Toggle("Enable Provider", isOn: $draft.isEnabled)
                Toggle("Use as Default", isOn: $draft.useAsDefault)
            }
            .formStyle(.grouped)

            HStack {
                Spacer()
                Button("Cancel", action: onCancel)
                Button("Save") {
                    onSave(draft)
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(22)
        .frame(width: 560)
        .background(Theme.ColorToken.panel)
    }

    private var apiKeyRow: some View {
        HStack {
            if draft.showsAPIKey {
                TextField("API Key", text: $draft.apiKey)
            } else {
                SecureField("API Key", text: $draft.apiKey)
            }
            Button {
                draft.showsAPIKey.toggle()
            } label: {
                Image(systemName: draft.showsAPIKey ? "eye.slash" : "eye")
            }
            Button {
                guard !draft.apiKey.isEmpty else { return }
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(draft.apiKey, forType: .string)
            } label: {
                Image(systemName: "doc.on.doc")
            }
            Button {
                draft.apiKey = ""
            } label: {
                Image(systemName: "xmark.circle")
            }
        }
    }
}
