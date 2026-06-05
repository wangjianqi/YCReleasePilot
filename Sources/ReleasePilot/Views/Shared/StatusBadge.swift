import SwiftUI

struct StatusBadge: View {
    let title: String
    var tint: Color = Theme.ColorToken.green

    var body: some View {
        Text(title)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(tint.opacity(0.14))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(tint.opacity(0.24), lineWidth: 1))
    }
}

struct PlatformBadge: View {
    let platform: Platform

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: platform.symbol)
                .font(.caption2.weight(.semibold))
            Text(platform.rawValue)
                .font(.caption2.weight(.semibold))
        }
        .foregroundStyle(Theme.ColorToken.muted)
    }
}
