import Foundation

enum MainPage: String, CaseIterable, Identifiable {
    case dashboard
    case apps
    case history
    case settings
    case debug

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard: "Dashboard"
        case .apps: "Apps"
        case .history: "History"
        case .settings: "Settings"
        case .debug: "Debug"
        }
    }

    var symbol: String {
        switch self {
        case .dashboard: "house.fill"
        case .apps: "app.dashed"
        case .history: "clock"
        case .settings: "gearshape"
        case .debug: "ladybug"
        }
    }
}

enum ActiveDialog: Identifiable {
    case buildDetail(BuildInfo)
    case versionHistory
    case releasePlan

    var id: String {
        switch self {
        case .buildDetail(let build): "build-\(build.id)"
        case .versionHistory: "version-history"
        case .releasePlan: "release-plan"
        }
    }
}

struct SettingsSection: Identifiable {
    let id: String
    let title: String
    let rows: [SettingsRow]
}

struct SettingsRow: Identifiable {
    let id: String
    let title: String
    let value: String
    let symbol: String
    let isEnabled: Bool
}
