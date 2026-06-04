import AppKit
import Foundation
import Observation

enum CopilotTab: String, CaseIterable, Identifiable {
    case chat = "Chat"
    case suggestions = "Suggestions"

    var id: String { rawValue }
}

@Observable
final class CopilotViewModel {
    var selectedTab: CopilotTab = .chat
    var messages: [CopilotMessage]
    var input: String = ""
    var suggestions: [CopilotSuggestion]
    var selectedProviderID: UUID?
    var selectedModel: String = ""

    private let providerViewModel: AIProvidersViewModel
    private let membershipViewModel: MembershipViewModel
    private let mockService: CopilotMockService
    private let toastService: ToastService

    init(
        providerViewModel: AIProvidersViewModel,
        membershipViewModel: MembershipViewModel,
        mockService: CopilotMockService = CopilotMockService(),
        toastService: ToastService = ToastService(),
        initialMessages: [CopilotMessage] = []
    ) {
        self.providerViewModel = providerViewModel
        self.membershipViewModel = membershipViewModel
        self.mockService = mockService
        self.toastService = toastService
        messages = initialMessages
        suggestions = MockData.copilotSuggestions
        syncSelectedProvider()
    }

    var providers: [AIProvider] {
        providerViewModel.enabledProviders
    }

    var hasConfiguredProvider: Bool {
        !providers.isEmpty
    }

    var selectedProvider: AIProvider? {
        providers.first { $0.id == selectedProviderID } ?? providerViewModel.defaultProvider
    }

    var availableModels: [String] {
        let model = selectedProvider?.defaultModel ?? "gpt-4o"
        return Array(Set([model, "gpt-4o", "claude-3-5-sonnet-latest", "gemini-1.5-pro", "deepseek-chat"])).sorted()
    }

    var usageLabel: String {
        membershipViewModel.usageLabel
    }

    var canSendChat: Bool {
        membershipViewModel.canSendCopilotMessage
    }

    var visibleSuggestions: [CopilotSuggestion] {
        suggestions.filter { $0.state != .ignored }
    }

    func syncSelectedProvider() {
        if let selectedProviderID, providers.contains(where: { $0.id == selectedProviderID }) {
            selectedModel = selectedProvider?.defaultModel ?? selectedModel
            return
        }
        selectedProviderID = providerViewModel.defaultProvider?.id
        selectedModel = providerViewModel.defaultProvider?.defaultModel ?? "gpt-4o"
    }

    func replaceMessages(_ values: [CopilotMessage]) {
        messages = values
    }

    func clearHistory() {
        messages.removeAll()
    }

    func sendCurrentInput(appName: String, platform: Platform) {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        sendPrompt(text, appName: appName, platform: platform)
        input = ""
    }

    func sendPrompt(_ prompt: String, appName: String, platform: Platform) {
        guard hasConfiguredProvider else {
            toastService.show("请先配置 AI Provider")
            return
        }
        guard canSendChat else {
            membershipViewModel.openPaywall()
            return
        }
        messages.append(CopilotMessage(role: .user, body: prompt))
        messages.append(mockService.response(for: prompt, appName: appName, platform: platform))
        membershipViewModel.service.recordCopilotMessage()
    }

    func copyMessage(_ message: CopilotMessage) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(message.body, forType: .string)
        toastService.show("AI 回复已复制")
    }

    func applyReviewNote(_ apply: () -> Void) {
        apply()
    }

    func applySuggestion(_ suggestion: CopilotSuggestion) {
        guard let index = suggestions.firstIndex(where: { $0.id == suggestion.id }) else { return }
        suggestions[index].state = .applied
        toastService.show("建议已应用")
    }

    func ignoreSuggestion(_ suggestion: CopilotSuggestion) {
        guard let index = suggestions.firstIndex(where: { $0.id == suggestion.id }) else { return }
        suggestions[index].state = .ignored
        toastService.show("建议已忽略")
    }

    func askAI(about suggestion: CopilotSuggestion, appName: String, platform: Platform) {
        selectedTab = .chat
        sendPrompt("请帮我处理建议：\(suggestion.title)。原因：\(suggestion.reason)。建议操作：\(suggestion.actionTitle)。", appName: appName, platform: platform)
    }

    func openSettings(_ selectSettings: () -> Void) {
        selectSettings()
    }
}
