import Foundation

final class AppStoreConnectConfigService {
    private let defaults: UserDefaults
    private let storageKey = "releasepilot.appStoreConnectConfig"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadConfig() -> AppStoreConnectConfig {
        guard let data = defaults.data(forKey: storageKey),
              let config = try? JSONDecoder().decode(AppStoreConnectConfig.self, from: data) else {
            return .empty
        }
        return config
    }

    func saveConfig(_ config: AppStoreConnectConfig) {
        guard let data = try? JSONEncoder().encode(config) else { return }
        defaults.set(data, forKey: storageKey)
    }

    func clearConfig() {
        defaults.removeObject(forKey: storageKey)
    }

    func testConnection(_ config: AppStoreConnectConfig) async -> AppStoreConnectConnectionStatus {
        try? await Task.sleep(for: .seconds(1))
        let hasRequiredFields = !config.apiKeyID.isEmpty && !config.issuerID.isEmpty && !config.privateKeyFilePath.isEmpty && !config.teamID.isEmpty
        return hasRequiredFields ? .connected : .missingFields
    }
}
