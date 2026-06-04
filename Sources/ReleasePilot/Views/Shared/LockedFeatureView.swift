import SwiftUI

struct LockedFeatureView: View {
    let title: String
    let subtitle: String
    let actionTitle: String
    let onUpgrade: () -> Void

    var body: some View {
        Button(action: onUpgrade) {
            HStack(spacing: 10) {
                Image(systemName: "lock.fill")
                    .foregroundStyle(Theme.ColorToken.purple)
                    .frame(width: 28, height: 28)
                    .background(Theme.ColorToken.purple.opacity(0.16))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.caption.weight(.semibold))
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(Theme.ColorToken.muted)
                }
                Spacer()
                Text(actionTitle)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Theme.ColorToken.purple)
            }
            .padding(10)
            .background(Color.white.opacity(0.045))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Theme.ColorToken.line, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}
