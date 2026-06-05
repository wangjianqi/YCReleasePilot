import CryptoKit
import Foundation

final class AppStoreConnectSnapshotCacheService {
    private struct CachedPayload: Codable {
        let configFingerprint: String
        let storedAt: Date
        let snapshots: [AppStoreConnectAppSnapshot]
    }

    private let cacheTTL: TimeInterval
    private let cacheURL: URL

    init(cacheTTL: TimeInterval = 10 * 60) {
        self.cacheTTL = cacheTTL
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let directory = base.appendingPathComponent("ReleasePilotAssetCache", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        cacheURL = directory.appendingPathComponent("app-store-connect-snapshots.json")
    }

    func loadValidSnapshot(for config: AppStoreConnectConfig, now: Date = Date()) -> [AppStoreConnectAppSnapshot]? {
        guard
            let data = try? Data(contentsOf: cacheURL),
            let payload = try? JSONDecoder().decode(CachedPayload.self, from: data),
            payload.configFingerprint == fingerprint(for: config),
            now.timeIntervalSince(payload.storedAt) <= cacheTTL
        else {
            return nil
        }
        return payload.snapshots
    }

    func save(_ snapshots: [AppStoreConnectAppSnapshot], for config: AppStoreConnectConfig, now: Date = Date()) {
        let payload = CachedPayload(
            configFingerprint: fingerprint(for: config),
            storedAt: now,
            snapshots: snapshots
        )
        guard let data = try? JSONEncoder().encode(payload) else { return }
        try? data.write(to: cacheURL, options: [.atomic])
    }

    private func fingerprint(for config: AppStoreConnectConfig) -> String {
        let raw = [
            config.apiKeyID.trimmingCharacters(in: .whitespacesAndNewlines),
            config.issuerID.trimmingCharacters(in: .whitespacesAndNewlines),
            config.teamID.trimmingCharacters(in: .whitespacesAndNewlines)
        ].joined(separator: "|")
        return SHA256.hash(data: Data(raw.utf8)).map { String(format: "%02x", $0) }.joined()
    }
}
