enum ScreenshotDevice: String, CaseIterable, Identifiable {
    case iPhone65 = "iPhone 6.5\""
    case iPhone69 = "iPhone 6.9\""
    case iPadPro = "iPad Pro 12.9\""
    case iPad109 = "iPad 10.9\""
    case mac = "Mac"

    var id: String { rawValue }
}

struct ScreenshotItem: Identifiable, Hashable {
    let id: String
    let device: ScreenshotDevice
    var slot: Int
    var title: String
    var subtitle: String
    var hasWarning: Bool
    var isPlaceholder: Bool
    var styleIndex: Int
    var localImagePath: String?

    init(id: String, device: ScreenshotDevice, slot: Int, title: String, subtitle: String, hasWarning: Bool = false, isPlaceholder: Bool = false, styleIndex: Int = 0, localImagePath: String? = nil) {
        self.id = id
        self.device = device
        self.slot = slot
        self.title = title
        self.subtitle = subtitle
        self.hasWarning = hasWarning
        self.isPlaceholder = isPlaceholder
        self.styleIndex = styleIndex
        self.localImagePath = localImagePath
    }
}
