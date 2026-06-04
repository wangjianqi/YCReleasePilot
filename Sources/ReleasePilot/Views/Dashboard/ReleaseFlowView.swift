import SwiftUI

struct ReleaseFlowView: View {
    let steps: [ReleaseStep]

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(AppStrings.releaseFlow)
                        .font(.headline)
                    Spacer()
                    SmallGlassButton(title: "流程视图", systemImage: "point.3.connected.trianglepath.dotted")
                }

                HStack(spacing: 0) {
                    ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                        FlowStepView(step: step)
                            .frame(maxWidth: .infinity)
                        if index < steps.count - 1 {
                            Rectangle()
                                .fill(step.state == .done ? Theme.ColorToken.green : Color.white.opacity(0.16))
                                .frame(height: 2)
                                .frame(width: 28)
                                .offset(y: -12)
                        }
                    }
                }
            }
        }
    }
}

private struct FlowStepView: View {
    let step: ReleaseStep

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle().fill(tint.opacity(0.18))
                Circle().stroke(tint.opacity(0.35), lineWidth: 1)
                Image(systemName: symbol)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(tint)
            }
            .frame(width: 38, height: 38)

            VStack(alignment: .leading, spacing: 3) {
                Text(step.title)
                    .font(.caption.weight(.semibold))
                Text(step.subtitle)
                    .font(.caption2)
                    .foregroundStyle(Theme.ColorToken.muted)
            }
        }
    }

    private var tint: Color {
        switch step.state {
        case .done: Theme.ColorToken.green
        case .warning: Theme.ColorToken.orange
        case .pending: Theme.ColorToken.soft
        }
    }

    private var symbol: String {
        switch step.state {
        case .done: "checkmark"
        case .warning: "exclamationmark"
        case .pending: "6.circle"
        }
    }
}
