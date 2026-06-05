import Foundation

final class AIProviderService {
    private let defaults: UserDefaults
    private let keychain: KeychainService
    private let environment: [String: String]
    private let chatService: OpenAICompatibleChatService
    private let storageKey = "releasepilot.aiProviders"

    init(
        defaults: UserDefaults = .standard,
        keychain: KeychainService = .shared,
        environment: [String: String] = ProcessInfo.processInfo.environment,
        chatService: OpenAICompatibleChatService = OpenAICompatibleChatService()
    ) {
        self.defaults = defaults
        self.keychain = keychain
        self.environment = environment
        self.chatService = chatService
    }

    func loadProviders() -> [AIProvider] {
        guard let data = defaults.data(forKey: storageKey),
              let providers = try? JSONDecoder().decode([AIProvider].self, from: data) else {
            return defaultEnvironmentProviders()
        }
        return providersWithEnvironmentDefaults(providers)
    }

    func saveProviders(_ providers: [AIProvider]) {
        guard let data = try? JSONEncoder().encode(providers) else { return }
        defaults.set(data, forKey: storageKey)
    }

    func saveAPIKey(_ apiKey: String, for providerID: UUID) {
        keychain.saveAPIKey(apiKey, providerID: providerID)
    }

    func apiKey(for providerID: UUID) -> String {
        keychain.apiKey(for: providerID)
    }

    func resolvedAPIKey(for provider: AIProvider) -> String {
        let savedKey = apiKey(for: provider.id).trimmingCharacters(in: .whitespacesAndNewlines)
        if !savedKey.isEmpty {
            return savedKey
        }
        guard provider.type == .xiaomi else { return "" }
        return environment["XIAO_API_KEY"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    func maskedAPIKey(for providerID: UUID) -> String {
        KeychainService.maskedKey(apiKey(for: providerID))
    }

    func deleteAPIKey(for providerID: UUID) {
        keychain.deleteAPIKey(for: providerID)
    }

    func clearAllProviders() {
        loadProviders().forEach { keychain.deleteAPIKey(for: $0.id) }
        defaults.removeObject(forKey: storageKey)
    }

    func testConnection(for provider: AIProvider) async -> AIProviderConnectionStatus {
        let apiKey = resolvedAPIKey(for: provider)
        guard !apiKey.isEmpty else { return .missingAPIKey }
        return await chatService.testConnection(provider: provider, apiKey: apiKey)
    }

    func sendChat(
        prompt: String,
        history: [CopilotMessage],
        provider: AIProvider,
        model: String,
        appName: String,
        platform: Platform
    ) async throws -> CopilotMessage {
        let apiKey = resolvedAPIKey(for: provider)
        guard !apiKey.isEmpty else {
            throw OpenAICompatibleChatError.httpError(401, "Missing API Key")
        }
        return try await chatService.send(
            prompt: prompt,
            history: history,
            provider: provider,
            apiKey: apiKey,
            model: model,
            appName: appName,
            platform: platform
        )
    }

    private func defaultEnvironmentProviders() -> [AIProvider] {
        guard let key = environment["XIAO_API_KEY"]?.trimmingCharacters(in: .whitespacesAndNewlines),
              !key.isEmpty else {
            return []
        }
        return [
            AIProvider(
                type: .xiaomi,
                displayName: "Xiaomi MiMo",
                baseURL: AIProviderType.xiaomi.defaultBaseURL,
                defaultModel: AIProviderType.xiaomi.defaultModel,
                isEnabled: true,
                isDefault: true,
                connectionStatus: .notConfigured
            )
        ]
    }

    private func providersWithEnvironmentDefaults(_ providers: [AIProvider]) -> [AIProvider] {
        guard !defaultEnvironmentProviders().isEmpty,
              !providers.contains(where: { $0.type == .xiaomi }) else {
            return providers
        }
        var values = providers
        var xiaomi = AIProvider(
            type: .xiaomi,
            displayName: "Xiaomi MiMo",
            baseURL: AIProviderType.xiaomi.defaultBaseURL,
            defaultModel: AIProviderType.xiaomi.defaultModel,
            isEnabled: true,
            isDefault: !providers.contains(where: \.isDefault),
            connectionStatus: .notConfigured
        )
        if providers.isEmpty {
            xiaomi.isDefault = true
        }
        values.append(xiaomi)
        return values
    }
}
