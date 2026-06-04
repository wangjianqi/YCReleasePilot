import Foundation

enum StartupPage: String, CaseIterable, Codable, Identifiable {
    case dashboard = "Dashboard"
    case lastOpenedApp = "Last Opened App"

    var id: String { rawValue }
}

enum AppLanguage: String, CaseIterable, Codable, Identifiable {
    case simplifiedChinese = "简体中文"
    case english = "English"

    var id: String { rawValue }
}

struct UserSettings: Codable, Equatable {
    var startupPage: StartupPage
    var defaultPlatform: Platform
    var language: AppLanguage
    var automaticallyChecksVersionOnLaunch: Bool

    static let defaults = UserSettings(
        startupPage: .dashboard,
        defaultPlatform: .iOS,
        language: .simplifiedChinese,
        automaticallyChecksVersionOnLaunch: true
    )
}
