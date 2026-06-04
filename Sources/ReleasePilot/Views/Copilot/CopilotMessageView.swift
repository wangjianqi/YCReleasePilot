import AppKit
import SwiftUI

struct CopilotMessageView: View {
    let message: CopilotMessage
    let onApplyReviewNote: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if message.role == .assistant {
                avatar
            }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 10) {
                bubble
                if message.showsReviewNoteActions {
                    actionRow
                }
            }
            .frame(maxWidth: .infinity, alignment: message.role == .user ? .trailing : .leading)

            if message.role == .user {
                userAvatar
            }
        }
    }

    private var bubble: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let title = message.title {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.ColorToken.text)
            }
            if !message.issues.isEmpty {
                ForEach(message.issues) { issue in
                    HStack(spacing: 8) {
                        Image(systemName: issue.colorName == "red" ? "exclamationmark.octagon.fill" : "exclamationmark.circle.fill")
                            .foregroundStyle(issue.colorName == "red" ? Theme.ColorToken.red : Theme.ColorToken.orange)
                        Text(issue.title)
                            .font(.caption)
                            .foregroundStyle(Theme.ColorToken.soft)
                        Spacer()
                        StatusBadge(title: issue.severity, tint: issue.colorName == "red" ? Theme.ColorToken.red : Theme.ColorToken.orange)
                    }
                    .padding(8)
                    .background(Color.white.opacity(0.035))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
            Text(message.body)
                .font(.caption)
                .lineSpacing(4)
                .foregroundStyle(Theme.ColorToken.soft)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(13)
        .frame(maxWidth: message.role == .user ? 245 : .infinity, alignment: .leading)
        .background(message.role == .user ? userBubbleGradient : AnyShapeStyle(Color.white.opacity(0.055)))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Theme.ColorToken.line, lineWidth: 1)
        )
    }

    private var actionRow: some View {
        HStack(spacing: 8) {
            SmallGlassButton(title: AppStrings.copy, systemImage: "doc.on.doc") {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(message.body, forType: .string)
            }
            SmallGlassButton(title: AppStrings.applyReviewNote, systemImage: "checkmark.circle", action: onApplyReviewNote)
        }
    }

    private var avatar: some View {
        ZStack {
            Circle().fill(LinearGradient(colors: [Theme.ColorToken.blue, Theme.ColorToken.purple], startPoint: .topLeading, endPoint: .bottomTrailing))
            Image(systemName: "sparkles")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
        }
        .frame(width: 26, height: 26)
    }

    private var userAvatar: some View {
        ZStack {
            Circle().fill(Theme.ColorToken.text)
            Text("张")
                .font(.caption.weight(.bold))
                .foregroundStyle(Theme.ColorToken.panel)
        }
        .frame(width: 26, height: 26)
    }

    private var userBubbleGradient: AnyShapeStyle {
        AnyShapeStyle(LinearGradient(colors: [Theme.ColorToken.purple.opacity(0.82), Theme.ColorToken.blue.opacity(0.68)], startPoint: .topLeading, endPoint: .bottomTrailing))
    }
}
