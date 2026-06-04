import SwiftUI

struct SubmitReviewCardView: View {
    let app: AppItem
    let readiness: Int
    let didSubmit: Bool
    let canSubmit: Bool
    let blockedMessage: String?
    let onSubmit: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            cta
                .frame(maxWidth: .infinity)
            submitInfo
                .frame(width: 270)
            plan
                .frame(width: 250)
        }
    }

    private var cta: some View {
        GlassCard(cornerRadius: 20, padding: 0) {
            HStack(spacing: 20) {
                RocketIllustration()
                    .frame(width: 150, height: 150)
                VStack(alignment: .leading, spacing: 9) {
                    Text(AppStrings.submitTitle)
                        .font(.title3.weight(.bold))
                    Text(AppStrings.submitSubtitle)
                        .font(.caption)
                        .foregroundStyle(Theme.ColorToken.muted)
                    PrimaryButton(title: didSubmit ? "已模拟提交" : AppStrings.submitReview, systemImage: "paperplane.fill", isEnabled: canSubmit, action: onSubmit)
                        .frame(width: 220)
                    Label(canSubmit ? "提交即表示同意遵守 App Store 审核指南" : (blockedMessage ?? "完成所有检查项后才能提交审核"), systemImage: canSubmit ? "lock.fill" : "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .foregroundStyle(canSubmit ? Theme.ColorToken.muted : Theme.ColorToken.orange)
                }
                Spacer()
            }
            .padding(18)
            .background(
                LinearGradient(colors: [Theme.ColorToken.purple.opacity(0.34), Theme.ColorToken.blue.opacity(0.34), Theme.ColorToken.panel.opacity(0.4)], startPoint: .leading, endPoint: .trailing)
            )
        }
    }

    private var submitInfo: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text(AppStrings.submitInfo)
                    .font(.headline)
                info("应用", app.name)
                info("版本", "\(app.version) (\(app.buildNumber))")
                info("平台", "iOS, iPadOS, macOS")
                info("语言", "5 种语言")
                info("构建", "\(app.buildNumber)")
                info("完成度", "\(readiness)%")
            }
        }
    }

    private var plan: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text(AppStrings.postReleasePlan)
                    .font(.headline)
                check("自动监控审核状态")
                check("审核通过后自动上线")
                check("发布成功后通知团队")
                Spacer()
                SmallGlassButton(title: "配置发布计划")
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func info(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(Theme.ColorToken.muted)
                .frame(width: 50, alignment: .leading)
            Text(value)
                .fontWeight(.semibold)
        }
        .font(.caption)
    }

    private func check(_ text: String) -> some View {
        Label(text, systemImage: "checkmark.circle.fill")
            .font(.caption)
            .foregroundStyle(Theme.ColorToken.soft)
            .labelStyle(.titleAndIcon)
    }
}

private struct RocketIllustration: View {
    var body: some View {
        ZStack {
            RadialGradient(colors: [Color.white.opacity(0.28), .clear], center: .bottomLeading, startRadius: 10, endRadius: 90)
            Image(systemName: "paperplane.circle.fill")
                .font(.system(size: 92, weight: .light))
                .foregroundStyle(LinearGradient(colors: [.white, Theme.ColorToken.blue, Theme.ColorToken.purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                .rotationEffect(.degrees(-18))
                .shadow(color: Theme.ColorToken.purple.opacity(0.45), radius: 18)
            Circle()
                .fill(Theme.ColorToken.purple.opacity(0.4))
                .frame(width: 34, height: 34)
                .blur(radius: 12)
                .offset(x: -36, y: 48)
        }
    }
}
