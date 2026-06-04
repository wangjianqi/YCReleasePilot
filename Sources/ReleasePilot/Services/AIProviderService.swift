import Foundation

final class AIProviderService {
    private let defaults: UserDefaults
    private let keychain: KeychainService
    private let storageKey = "releasepilot.aiProviders"

    init(defaults: UserDefaults = .standard, keychain: KeychainService = .shared) {
        self.defaults = defaults
        self.keychain = keychain
    }

    func loadProviders() -> [AIProvider] {
        guard let data = defaults.data(forKey: storageKey),
              let providers = try? JSONDecoder().decode([AIProvider].self, from: data) else {
            return []
        }
        return providers
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
        try? await Task.sleep(for: .seconds(1))
        return apiKey(for: provider.id).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .missingAPIKey : .connected
    }
}
