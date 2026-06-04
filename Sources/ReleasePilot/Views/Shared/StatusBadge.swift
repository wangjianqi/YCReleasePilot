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
