import SwiftUI

struct AppItem: Identifiable, Hashable {
    let id: String
    let name: String
    let version: String
    let buildNumber: Int
    let iconSymbol: String
    let iconGradient: [Color]
    let readiness: Int
    let passRate: Int
    let reviewHours: String
    let aiScore: Int
    let status: String
}

enum Platform: String, CaseIterable, Identifiable {
    case iOS
    case iPadOS
    case macOS

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .iOS: "iphone"
        case .iPadOS: "ipad"
        case .macOS: "macbook"
        }
    }
}
