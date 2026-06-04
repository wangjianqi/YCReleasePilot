enum ScreenshotDevice: String, CaseIterable, Identifiable {
    case iPhone69 = "iPhone 6.9\""
    case iPhone65 = "iPhone 6.5\""
    case iPadPro = "iPad Pro 12.9\""
    case mac = "Mac"

    var id: String { rawValue }
}

struct ScreenshotItem: Identifiable {
    let id: Int
    let title: String
    let subtitle: String
    let hasWarning: Bool
}
