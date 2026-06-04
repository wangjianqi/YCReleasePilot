import Foundation
import Observation

enum SettingsSectionID: String, CaseIterable, Identifiable {
    case general
    case aiProviders
    case membership
    case appStoreConnect
    case privacySecurity
    case about

    var id: String { rawValue }

    var title: String {
        switch self {
        case .general: "General"
        case .aiProviders: "AI Providers"
        case .membership: "Membership"
        case .appStoreConnect: "App Store Connect"
        case .privacySecurity: "Privacy & Security"
        case .about: "About"
        }
    }

    var symbol: String {
        switch self {
        case .general: "gearshape.fill"
        case .aiProviders: "sparkles"
        case .membership: "diamond.fill"
        case .appStoreConnect: "app.badge.fill"
        case .privacySecurity: "lock.shield.fill"
        case .about: "info.circle.fill"
        }
    }
}

@Observable
final class SettingsViewModel {
    var selectedSection: SettingsSectionID = .general
    var userSettings: UserSettings {
        didSet { saveUserSettings() }
    }
    var appStoreConnectConfig: AppStoreConnectConfig {
        didSet { appStoreConnectService.saveConfig(appStoreConnectConfig) }
    }
    var isTestingAppStoreConnect = false
    var showingClearAllDataConfirmation = false
    var showingClearChatHistoryConfirmation = false
    var showingClearProvidersConfirmation = false

    let aiProvidersViewModel: AIProvidersViewModel
    let membershipViewModel: MembershipViewModel

    private let defaults: UserDefaults
    private let settingsKey = "releasepilot.userSettings"
    private let appStoreConnectService: AppStoreConnectConfigService
    private let toastService: ToastService
    private let onClearChatHistory: () -> Void

    init(
        aiProvidersViewModel: AIProvidersViewModel,
        membershipViewModel: MembershipViewModel,
        appStoreConnectService: AppStoreConnectConfigService = AppStoreConnectConfigService(),
        toastService: ToastService = ToastService(),
        defaults: UserDefaults = .standard,
        onClearChatHistory: @escaping () -> Void = {}
    ) {
        self.aiProvidersViewModel = aiProvidersViewModel
        self.membershipViewModel = membershipViewModel
        self.appStoreConnectService = appStoreConnectService
        self.toastService = toastService
        self.defaults = defaults
        self.onClearChatHistory = onClearChatHistory
        if let data = defaults.data(forKey: settingsKey),
           let settings = try? JSONDecoder().decode(UserSettings.self, from: data) {
            userSettings = settings
        } else {
            userSettings = .defaults
        }
        appStoreConnectConfig = appStoreConnectService.loadConfig()
    }

    func setPrivateKeyFile(path: String) {
        guard path.hasSuffix(".p8") else {
            toastService.show("请选择 .p8 文件")
            return
        }
        appStoreConnectConfig.privateKeyFilePath = path
        appStoreConnectConfig.privateKeyFileName = URL(fileURLWithPath: path).lastPathComponent
        toastService.show("Private Key 已选择")
    }

    func testAppStoreConnect() {
        isTestingAppStoreConnect = true
        Task {
            let status = await appStoreConnectService.testConnection(appStoreConnectConfig)
            appStoreConnectConfig.connectionStatus = status
            isTestingAppStoreConnect = false
            toastService.show(status == .connected ? "App Store Connect 连接成功" : status.title)
        }
    }

    func clearAllLocalData() {
        defaults.removeObject(forKey: settingsKey)
        appStoreConnectService.clearConfig()
        aiProvidersViewModel.clearAllProviders()
        membershipViewModel.service.reset()
        onClearChatHistory()
        userSettings = .defaults
        appStoreConnectConfig = .empty
        toastService.show("所有本地数据已清空")
    }

    func clearChatHistory() {
        onClearChatHistory()
        toastService.show("AI 对话历史已清空")
    }

    func clearProviderConfig() {
        aiProvidersViewModel.clearAllProviders()
    }

    private func saveUserSettings() {
        guard let data = try? JSONEncoder().encode(userSettings) else { return }
        defaults.set(data, forKey: settingsKey)
    }
}
