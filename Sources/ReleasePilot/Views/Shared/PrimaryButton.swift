import SwiftUI

struct PrimaryButton: View {
    let title: String
    var systemImage: String?
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(
                LinearGradient(colors: [Theme.ColorToken.blue, Theme.ColorToken.purple], startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.button, style: .continuous))
            .shadow(color: Theme.ColorToken.blue.opacity(0.26), radius: 18, x: 0, y: 10)
        }
        .buttonStyle(.plain)
    }
}

struct SmallGlassButton: View {
    let title: String
    var systemImage: String?
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
            }
            .font(.caption.weight(.medium))
            .foregroundStyle(Theme.ColorToken.soft)
            .padding(.horizontal, 11)
            .frame(height: 32)
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .stroke(Theme.ColorToken.line, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
