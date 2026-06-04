import SwiftUI

struct MembershipSettingsView: View {
    @Bindable var viewModel: MembershipViewModel

    private let proFeatures = [
        "AI Copilot 高级对话",
        "AI 审核风险分析",
        "多语言批量翻译",
        "ASO 关键词优化",
        "批量 App 管理",
        "发布历史分析"
    ]

    var body: some View {
        SettingsDetailShell(title: "Membership", subtitle: "当前会员状态：\(viewModel.status.title)") {
            HStack(spacing: 12) {
                membershipCard(title: "Free", subtitle: "每日 5 次 AI Copilot 对话", isActive: viewModel.status == .free) {
                    Text("高级风险分析、批量翻译和 ASO 优化已锁定。")
                        .font(.caption)
                        .foregroundStyle(Theme.ColorToken.muted)
                }
                membershipCard(title: "Pro", subtitle: "解锁所有高级能力", isActive: viewModel.status == .pro) {
                    featureList(proFeatures)
                    Button("Upgrade to Pro") {
                        viewModel.upgradeToPro()
                    }
                    .buttonStyle(.borderedProminent)
                }
                membershipCard(title: "Lifetime", subtitle: "一次购买永久使用", isActive: viewModel.status == .lifetime) {
                    featureList(["包含 Pro 全部能力", "一次购买永久使用"])
                    Button("Lifetime") {
                        viewModel.upgradeToLifetime()
                    }
                    .buttonStyle(.bordered)
                }
            }

            GlassCard {
                VStack(alignment: .leading, spacing: 10) {
                    SectionTitle(title: "权限控制", trailing: viewModel.usageLabel)
                    ForEach(FeatureFlag.allCases) { feature in
                        HStack {
                            Image(systemName: viewModel.isAllowed(feature) ? "checkmark.circle.fill" : "lock.fill")
                                .foregroundStyle(viewModel.isAllowed(feature) ? Theme.ColorToken.green : Theme.ColorToken.orange)
                            Text(feature.title)
                                .font(.caption.weight(.semibold))
                            Spacer()
                            Text(viewModel.isAllowed(feature) ? "Available" : "Locked")
                                .font(.caption2)
                                .foregroundStyle(Theme.ColorToken.muted)
                        }
                    }
                    Button("Open Paywall Preview") {
                        viewModel.openPaywall()
                    }
                }
            }
        }
    }

    private func membershipCard<Content: View>(title: String, subtitle: String, isActive: Bool, @ViewBuilder content: () -> Content) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(title)
                        .font(.title3.weight(.bold))
                    Spacer()
                    if isActive {
                        StatusBadge(title: "Current", tint: Theme.ColorToken.green)
                    }
                }
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Theme.ColorToken.muted)
                content()
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, minHeight: 210, alignment: .topLeading)
        }
    }

    private func featureList(_ values: [String]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(values, id: \.self) { value in
                Label(value, systemImage: "checkmark")
                    .font(.caption)
                    .foregroundStyle(Theme.ColorToken.soft)
            }
        }
    }
}
