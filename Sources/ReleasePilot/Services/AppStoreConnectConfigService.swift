import Foundation

final class AppStoreConnectConfigService {
    private let defaults: UserDefaults
    private let apiService: AppStoreConnectAPIService
    private let snapshotCacheService: AppStoreConnectSnapshotCacheService
    private let storageKey = "releasepilot.appStoreConnectConfig"

    init(
        defaults: UserDefaults = .standard,
        apiService: AppStoreConnectAPIService = AppStoreConnectAPIService(),
        snapshotCacheService: AppStoreConnectSnapshotCacheService = AppStoreConnectSnapshotCacheService()
    ) {
        self.defaults = defaults
        self.apiService = apiService
        self.snapshotCacheService = snapshotCacheService
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
        if snapshotCacheService.loadValidSnapshot(for: config) != nil {
            return .connected
        }
        do {
            let snapshots = try await apiService.listApps(config: config, limit: 1)
            snapshotCacheService.save(snapshots, for: config)
            return .connected
        } catch AppStoreConnectAPIError.missingFields {
            return .missingFields
        } catch {
            return .failed
        }
    }
}
