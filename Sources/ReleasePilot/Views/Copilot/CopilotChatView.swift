import SwiftUI

struct CopilotChatView: View {
    @Bindable var dashboardViewModel: ReleaseDashboardViewModel
    @Bindable var copilotViewModel: CopilotViewModel
    @Bindable var membershipViewModel: MembershipViewModel
    let onOpenSettings: () -> Void
    let onApplyReviewNote: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            if !copilotViewModel.hasConfiguredProvider {
                emptyProviderState
            } else if !copilotViewModel.canSendChat {
                limitState
            } else {
                modelSelectors
                messages
                quickActions
                composer
            }
        }
        .frame(maxHeight: .infinity)
        .onAppear {
            copilotViewModel.syncSelectedProvider()
        }
    }

    private var emptyProviderState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "key.fill")
                .font(.largeTitle)
                .foregroundStyle(Theme.ColorToken.purple)
            Text("还没有配置 AI Provider")
                .font(.headline)
            Text("添加 OpenAI、Claude、Gemini、DeepSeek 或 OpenRouter API Key 后即可使用 AI Copilot。")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(Theme.ColorToken.muted)
            Button("去设置", action: onOpenSettings)
                .buttonStyle(.borderedProminent)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var limitState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "lock.fill")
                .font(.largeTitle)
                .foregroundStyle(Theme.ColorToken.orange)
            Text("今日免费 AI 对话次数已用完")
                .font(.headline)
            Text("升级 Pro 后可无限制使用 AI Copilot。")
                .font(.caption)
                .foregroundStyle(Theme.ColorToken.muted)
            Button("升级 Pro") {
                membershipViewModel.openPaywall()
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var modelSelectors: some View {
        HStack(spacing: 8) {
            Picker("Provider", selection: $copilotViewModel.selectedProviderID) {
                ForEach(copilotViewModel.providers) { provider in
                    Text(provider.displayName).tag(Optional(provider.id))
                }
            }
            .labelsHidden()
            Picker("Model", selection: $copilotViewModel.selectedModel) {
                ForEach(copilotViewModel.availableModels, id: \.self) { model in
                    Text(model).tag(model)
                }
            }
            .labelsHidden()
        }
    }

    private var messages: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    ForEach(copilotViewModel.messages) { message in
                        CopilotMessageView(message: message, onCopy: {
                            copilotViewModel.copyMessage(message)
                        }, onApplyReviewNote: {
                            copilotViewModel.applyReviewNote(onApplyReviewNote)
                        })
                        .id(message.id)
                    }
                }
                .padding(.vertical, 2)
            }
            .onChange(of: copilotViewModel.messages.count) { _, _ in
                if let lastID = copilotViewModel.messages.last?.id {
                    withAnimation(.easeOut(duration: 0.2)) {
                        proxy.scrollTo(lastID, anchor: .bottom)
                    }
                }
            }
        }
        .frame(maxHeight: .infinity)
    }

    private var quickActions: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
            quickAction("生成审核备注", "doc.text.fill")
            quickAction("优化副标题", "textformat")
            quickAction("优化关键词", "key.fill")
            quickAction("翻译新增内容", "globe")
            quickAction("分析审核风险", "chart.line.uptrend.xyaxis")
        }
    }

    private func quickAction(_ title: String, _ symbol: String) -> some View {
        let lockedFeature = lockedFeature(for: title)
        return CopilotQuickActionView(title: title, systemImage: symbol) {
            if let lockedFeature, !membershipViewModel.isAllowed(lockedFeature) {
                membershipViewModel.openPaywall()
                return
            }
            copilotViewModel.sendPrompt(title, appName: dashboardViewModel.selectedApp.name, platform: dashboardViewModel.selectedPlatform)
        }
    }

    private func lockedFeature(for title: String) -> FeatureFlag? {
        if title.contains("翻译") { return .batchTranslation }
        if title.contains("关键词") { return .asoKeywordOptimization }
        if title.contains("风险") { return .advancedReviewRisk }
        return nil
    }

    private var composer: some View {
        HStack(spacing: 8) {
            TextField("让 AI 帮你优化本次发布…", text: $copilotViewModel.input, axis: .vertical)
                .textFieldStyle(.plain)
                .font(.caption)
                .foregroundStyle(Theme.ColorToken.text)
                .lineLimit(1...4)
                .onSubmit {
                    copilotViewModel.sendCurrentInput(appName: dashboardViewModel.selectedApp.name, platform: dashboardViewModel.selectedPlatform)
                }

            Button {
                copilotViewModel.sendCurrentInput(appName: dashboardViewModel.selectedApp.name, platform: dashboardViewModel.selectedPlatform)
            } label: {
                Image(systemName: copilotViewModel.isSending ? "hourglass" : "paperplane.fill")
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .background(LinearGradient(colors: [Theme.ColorToken.blue, Theme.ColorToken.purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(copilotViewModel.isSending)
        }
        .padding(10)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 17, style: .continuous).stroke(Theme.ColorToken.line, lineWidth: 1))
    }
}
