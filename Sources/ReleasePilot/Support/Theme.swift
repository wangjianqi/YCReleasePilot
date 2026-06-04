import SwiftUI

enum Theme {
    enum ColorToken {
        static let background = Color(hex: 0x07111F)
        static let backgroundDeep = Color(hex: 0x050914)
        static let panel = Color(hex: 0x0B1220)
        static let panelRaised = Color(hex: 0x101827)
        static let panelSoft = Color(hex: 0x151F31)
        static let line = Color.white.opacity(0.08)
        static let lineStrong = Color.white.opacity(0.14)
        static let text = Color(hex: 0xF4F7FB)
        static let muted = Color(hex: 0x8C97AA)
        static let soft = Color(hex: 0xC7D0DF)
        static let blue = Color(hex: 0x2F7DFF)
        static let purple = Color(hex: 0x8B5CF6)
        static let green = Color(hex: 0x30D158)
        static let orange = Color(hex: 0xFF9F0A)
        static let red = Color(hex: 0xFF453A)
        static let cyan = Color(hex: 0x22D3EE)
    }

    enum Radius {
        static let surface: CGFloat = 26
        static let large: CGFloat = 18
        static let small: CGFloat = 12
        static let button: CGFloat = 10
    }

    enum Spacing {
        static let page: CGFloat = 12
        static let card: CGFloat = 16
    }

    static let cardGradient = LinearGradient(
        colors: [
            ColorToken.panelRaised.opacity(0.88),
            ColorToken.panel.opacity(0.88)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 8) & 0xff) / 255,
            blue: Double(hex & 0xff) / 255,
            opacity: alpha
        )
    }
}
