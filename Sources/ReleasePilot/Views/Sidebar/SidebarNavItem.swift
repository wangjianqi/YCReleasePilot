import SwiftUI

struct SidebarNavItem: View {
    let title: String
    let systemImage: String
    var isActive: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .frame(width: 18)
            Text(title)
                .font(.system(size: 13, weight: .medium))
            Spacer()
        }
        .foregroundStyle(isActive ? .white : Theme.ColorToken.soft)
        .padding(.horizontal, 14)
        .frame(height: 42)
        .background(
            Group {
                if isActive {
                    LinearGradient(colors: [Theme.ColorToken.blue, Theme.ColorToken.purple.opacity(0.72)], startPoint: .leading, endPoint: .trailing)
                } else {
                    Color.clear
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous))
    }
}
