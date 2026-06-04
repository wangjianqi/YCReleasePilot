import Foundation

enum MembershipStatus: String, CaseIterable, Codable, Identifiable {
    case free
    case pro
    case lifetime

    var id: String { rawValue }

    var title: String {
        switch self {
        case .free: "Free"
        case .pro: "Pro"
        case .lifetime: "Lifetime"
        }
    }

    var isPaid: Bool {
        self == .pro || self == .lifetime
    }
}
