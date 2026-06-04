import Foundation

final class KeychainService {
    static let shared = KeychainService()

    private var mockAPIKeys: [UUID: String] = [:]
    private let lock = NSLock()

    private init() {}

    func saveAPIKey(_ apiKey: String, providerID: UUID) {
        lock.lock()
        defer { lock.unlock() }
        mockAPIKeys[providerID] = apiKey
    }

    func apiKey(for providerID: UUID) -> String {
        lock.lock()
        defer { lock.unlock() }
        return mockAPIKeys[providerID] ?? ""
    }

    func deleteAPIKey(for providerID: UUID) {
        lock.lock()
        defer { lock.unlock() }
        mockAPIKeys.removeValue(forKey: providerID)
    }

    func clearAllAPIKeys() {
        lock.lock()
        defer { lock.unlock() }
        mockAPIKeys.removeAll()
    }

    static func maskedKey(_ value: String) -> String {
        guard !value.isEmpty else { return "未配置" }
        guard value.count > 12 else { return "••••••" }
        return "\(value.prefix(6))••••••\(value.suffix(4))"
    }
}
