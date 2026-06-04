import Foundation

enum AIProviderConnectionStatus: String, Codable {
    case notConfigured
    case connected
    case missingAPIKey
    case connectionFailed

    var title: String {
        switch self {
        case .notConfigured: "未配置"
        case .connected: "已连接"
        case .missingAPIKey: "Missing API Key"
        case .connectionFailed: "连接失败"
        }
    }
}

struct AIProvider: Identifiable, Codable, Equatable {
    var id: UUID
    var type: AIProviderType
    var displayName: String
    var baseURL: String
    var defaultModel: String
    var isEnabled: Bool
    var isDefault: Bool
    var connectionStatus: AIProviderConnectionStatus

    init(
        id: UUID = UUID(),
        type: AIProviderType,
        displayName: String? = nil,
        baseURL: String? = nil,
        defaultModel: String? = nil,
        isEnabled: Bool = true,
        isDefault: Bool = false,
        connectionStatus: AIProviderConnectionStatus = .notConfigured
    ) {
        self.id = id
        self.type = type
        self.displayName = displayName ?? type.name
        self.baseURL = baseURL ?? type.defaultBaseURL
        self.defaultModel = defaultModel ?? type.defaultModel
        self.isEnabled = isEnabled
        self.isDefault = isDefault
        self.connectionStatus = connectionStatus
    }
}
