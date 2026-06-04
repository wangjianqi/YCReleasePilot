import SwiftUI

struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat = Theme.Radius.large
    var padding: CGFloat = Theme.Spacing.card
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .background(Theme.cardGradient)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Theme.ColorToken.line, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.26), radius: 24, x: 0, y: 18)
    }
}

struct SectionTitle: View {
    let title: String
    var trailing: String?

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundStyle(Theme.ColorToken.text)
            Spacer()
            if let trailing {
                Text(trailing)
                    .font(.caption)
                    .foregroundStyle(Theme.ColorToken.muted)
            }
        }
    }
}
