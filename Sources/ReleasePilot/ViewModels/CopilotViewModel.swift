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
    var sessions: [CopilotSession]
    var selectedProviderID: UUID?
    var selectedModel: String = ""
    var selectedSessionID: UUID?
    var showingSessionHistory = false

    private let providerViewModel: AIProvidersViewModel
    private let membershipViewModel: MembershipViewModel
    private let mockService: CopilotMockService
    private let sessionService: CopilotSessionService
    private let toastService: ToastService

    init(
        providerViewModel: AIProvidersViewModel,
        membershipViewModel: MembershipViewModel,
        mockService: CopilotMockService = CopilotMockService(),
        sessionService: CopilotSessionService = CopilotSessionService(),
        toastService: ToastService = ToastService(),
        initialMessages: [CopilotMessage] = []
    ) {
        self.providerViewModel = providerViewModel
        self.membershipViewModel = membershipViewModel
        self.mockService = mockService
        self.sessionService = sessionService
        self.toastService = toastService
        sessions = sessionService.loadSessions()
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

    var currentSession: CopilotSession? {
        guard let selectedSessionID else { return nil }
        return sessions.first { $0.id == selectedSessionID }
    }

    var historySessions: [CopilotSession] {
        sessions.sorted { $0.updatedAt > $1.updatedAt }
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
        sessions.removeAll()
        selectedSessionID = nil
        messages.removeAll()
        sessionService.clearSessions()
    }

    func loadSession(for appID: String, platform: Platform, initialMessages: [CopilotMessage]) {
        syncSelectedProvider()
        if let currentSession, currentSession.appID == appID, currentSession.platform == platform {
            messages = currentSession.messages
            return
        }
        if let recent = historySessions.first(where: { $0.appID == appID && $0.platform == platform }) {
            selectSession(recent)
            return
        }
        newSession(appID: appID, platform: platform, initialMessages: initialMessages)
    }

    func newSession(appID: String, platform: Platform, initialMessages: [CopilotMessage] = []) {
        syncSelectedProvider()
        let session = CopilotSession(
            appID: appID,
            platform: platform,
            providerID: selectedProviderID,
            model: selectedModel,
            messages: initialMessages
        )
        sessions.insert(session, at: 0)
        selectedSessionID = session.id
        messages = initialMessages
        persistCurrentSession()
    }

    func selectSession(_ session: CopilotSession) {
        selectedSessionID = session.id
        selectedProviderID = session.providerID ?? selectedProviderID
        selectedModel = session.model
        messages = session.messages
        selectedTab = .chat
    }

    func deleteSession(_ session: CopilotSession, fallbackAppID: String, fallbackPlatform: Platform) {
        sessions.removeAll { $0.id == session.id }
        if selectedSessionID == session.id {
            selectedSessionID = nil
            messages.removeAll()
            newSession(appID: fallbackAppID, platform: fallbackPlatform)
        } else {
            persistSessions()
        }
        toastService.show("对话已删除")
    }

    func renameSession(_ session: CopilotSession, title: String) {
        guard let index = sessions.firstIndex(where: { $0.id == session.id }) else { return }
        sessions[index].title = title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "New Chat" : title
        sessions[index].updatedAt = Date()
        persistSessions()
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
        persistCurrentSession()
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

    func persistCurrentSession() {
        guard let selectedSessionID,
              let index = sessions.firstIndex(where: { $0.id == selectedSessionID }) else { return }
        sessions[index].messages = messages
        sessions[index].providerID = selectedProviderID
        sessions[index].model = selectedModel
        sessions[index].updatedAt = Date()
        sessions[index].title = title(for: messages)
        persistSessions()
    }

    private func persistSessions() {
        sessions.sort { $0.updatedAt > $1.updatedAt }
        sessionService.saveSessions(sessions)
    }

    private func title(for messages: [CopilotMessage]) -> String {
        guard let firstUserMessage = messages.first(where: { $0.role == .user })?.body.trimmingCharacters(in: .whitespacesAndNewlines),
              !firstUserMessage.isEmpty else {
            return "New Chat"
        }
        return firstUserMessage.count > 18 ? "\(firstUserMessage.prefix(18))..." : firstUserMessage
    }
}
