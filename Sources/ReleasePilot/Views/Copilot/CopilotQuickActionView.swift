import SwiftUI

struct CopilotQuickActionView: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.caption.weight(.medium))
                .foregroundStyle(Theme.ColorToken.soft)
                .padding(.horizontal, 11)
                .frame(height: 34)
                .background(Theme.ColorToken.purple.opacity(0.16))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Theme.ColorToken.purple.opacity(0.26), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
