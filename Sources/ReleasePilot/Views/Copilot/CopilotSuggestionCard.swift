import SwiftUI

struct CopilotSuggestionCard: View {
    let suggestion: CopilotSuggestion
    let onApply: () -> Void
    let onIgnore: () -> Void
    let onAskAI: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(suggestion.title)
                    .font(.caption.weight(.bold))
                Spacer()
                StatusBadge(title: "风险 \(suggestion.risk.rawValue)", tint: riskColor)
            }
            HStack(spacing: 8) {
                StatusBadge(title: suggestion.module.rawValue, tint: Theme.ColorToken.blue)
                if suggestion.state == .applied {
                    StatusBadge(title: "Applied", tint: Theme.ColorToken.green)
                }
            }
            Text(suggestion.reason)
                .font(.caption)
                .foregroundStyle(Theme.ColorToken.soft)
            Text("建议操作：\(suggestion.actionTitle)")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Theme.ColorToken.muted)
            HStack(spacing: 8) {
                SmallGlassButton(title: suggestion.state == .applied ? "Applied" : "Apply", systemImage: "checkmark.circle", action: onApply)
                    .disabled(suggestion.state == .applied)
                SmallGlassButton(title: "Ignore", systemImage: "xmark.circle", action: onIgnore)
                SmallGlassButton(title: "Ask AI", systemImage: "sparkles", action: onAskAI)
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Theme.ColorToken.line, lineWidth: 1))
    }

    private var riskColor: Color {
        switch suggestion.risk {
        case .low: Theme.ColorToken.green
        case .medium: Theme.ColorToken.orange
        case .high: Theme.ColorToken.red
        }
    }
}
