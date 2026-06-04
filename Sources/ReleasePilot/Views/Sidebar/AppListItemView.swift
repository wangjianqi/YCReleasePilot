import SwiftUI

struct AppListItemView: View {
    let app: AppItem
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            AppIconView(app: app, size: 40)

            VStack(alignment: .leading, spacing: 3) {
                Text(app.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.ColorToken.text)
                    .lineLimit(1)
                Text("\(app.version) (\(app.buildNumber))")
                    .font(.caption)
                    .foregroundStyle(Theme.ColorToken.muted)
            }

            Spacer()

            Circle()
                .fill(isSelected ? Theme.ColorToken.blue : Color.white.opacity(0.18))
                .frame(width: 8, height: 8)
        }
        .padding(.horizontal, 10)
        .frame(height: 58)
        .background(isSelected ? Theme.ColorToken.blue.opacity(0.18) : Color.white.opacity(0.02))
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous)
                .stroke(isSelected ? Theme.ColorToken.blue.opacity(0.36) : Color.clear, lineWidth: 1)
        )
    }
}
