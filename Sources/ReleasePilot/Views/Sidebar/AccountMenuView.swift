import SwiftUI

struct AccountMenuView: View {
    let onAccountSettings: () -> Void
    let onMembershipSettings: () -> Void
    let onAIProviderSettings: () -> Void
    let onSignOut: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            menuButton("Account Settings", "person.crop.circle", onAccountSettings)
            menuButton("Membership", "diamond.fill", onMembershipSettings)
            menuButton("AI Providers", "sparkles", onAIProviderSettings)
            Divider()
            menuButton("Sign Out Mock", "rectangle.portrait.and.arrow.right", onSignOut)
        }
        .padding(10)
        .frame(width: 230)
        .background(Theme.ColorToken.panel)
    }

    private func menuButton(_ title: String, _ symbol: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Theme.ColorToken.soft)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 10)
                .frame(height: 32)
                .background(Color.white.opacity(0.045))
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
