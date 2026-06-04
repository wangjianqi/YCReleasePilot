import SwiftUI

struct PaywallSheet: View {
    @Bindable var membershipViewModel: MembershipViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Upgrade to ReleasePilot Pro")
                    .font(.title.weight(.bold))
                Text("解锁高级 AI Copilot、审核风险分析、批量翻译和 ASO 优化。")
                    .font(.caption)
                    .foregroundStyle(Theme.ColorToken.muted)
            }
            HStack(spacing: 12) {
                planButton(title: "Monthly", subtitle: "$9.99 / month") {
                    membershipViewModel.upgradeToPro()
                }
                planButton(title: "Yearly", subtitle: "$79.99 / year") {
                    membershipViewModel.upgradeToPro()
                }
                planButton(title: "Lifetime", subtitle: "$149 once") {
                    membershipViewModel.upgradeToLifetime()
                }
            }
            HStack {
                Button("Restore Purchases") {
                    membershipViewModel.restorePurchases()
                }
                Spacer()
                Button("Close") {
                    membershipViewModel.showingPaywall = false
                }
            }
        }
        .padding(24)
        .frame(width: 680)
        .background(Theme.ColorToken.panel)
    }

    private func planButton(title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Theme.ColorToken.muted)
                Spacer()
                Label("Choose", systemImage: "arrow.right.circle.fill")
                    .font(.caption.weight(.semibold))
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
            .background(Theme.cardGradient)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Theme.ColorToken.line, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}
