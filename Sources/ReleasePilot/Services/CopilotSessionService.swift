import Foundation

final class CopilotSessionService {
    private let defaults: UserDefaults
    private let storageKey = "releasepilot.copilotSessions"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadSessions() -> [CopilotSession] {
        guard let data = defaults.data(forKey: storageKey),
              let sessions = try? JSONDecoder().decode([CopilotSession].self, from: data) else {
            return []
        }
        return sessions.sorted { $0.updatedAt > $1.updatedAt }
    }

    func saveSessions(_ sessions: [CopilotSession]) {
        guard let data = try? JSONEncoder().encode(sessions) else { return }
        defaults.set(data, forKey: storageKey)
    }

    func clearSessions() {
        defaults.removeObject(forKey: storageKey)
    }
}
