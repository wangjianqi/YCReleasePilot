import SwiftUI

struct AppIconView: View {
    let app: AppItem
    var size: CGFloat = 40

    var body: some View {
        ZStack {
            if let image = LocalAssetCacheService.appIcon(for: app, size: size) {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                LinearGradient(colors: app.iconGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                Image(systemName: app.iconSymbol)
                    .font(.system(size: size * 0.45, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        )
    }
}
