import SwiftUI

struct AppListItemView: View {
    let app: AppItem
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            AppIconView(app: app, size: 34)

            VStack(alignment: .leading, spacing: 2) {
                Text(app.name)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.ColorToken.text)
                    .lineLimit(1)
                Text("\(app.version) (\(app.buildNumber))")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(Theme.ColorToken.muted)
            }

            Spacer()

            Circle()
                .fill(isSelected ? Theme.ColorToken.blue : Color.white.opacity(0.18))
                .frame(width: 6, height: 6)
        }
        .padding(.horizontal, 8)
        .frame(height: 48)
        .background(isSelected ? Theme.ColorToken.blue.opacity(0.18) : Color.white.opacity(0.02))
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous)
                .stroke(isSelected ? Theme.ColorToken.blue.opacity(0.36) : Color.clear, lineWidth: 1)
        )
    }
}
