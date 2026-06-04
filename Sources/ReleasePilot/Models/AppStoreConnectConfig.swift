import Foundation

enum AppStoreConnectConnectionStatus: String, Codable {
    case notTested
    case connected
    case missingFields
    case failed

    var title: String {
        switch self {
        case .notTested: "未测试"
        case .connected: "已连接"
        case .missingFields: "缺少字段"
        case .failed: "连接失败"
        }
    }
}

struct AppStoreConnectConfig: Codable, Equatable {
    var apiKeyID: String
    var issuerID: String
    var privateKeyFileName: String
    var privateKeyFilePath: String
    var teamID: String
    var connectionStatus: AppStoreConnectConnectionStatus

    static let empty = AppStoreConnectConfig(
        apiKeyID: "",
        issuerID: "",
        privateKeyFileName: "",
        privateKeyFilePath: "",
        teamID: "",
        connectionStatus: .notTested
    )
}
