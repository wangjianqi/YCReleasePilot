import SwiftUI

struct CopilotSessionHistoryView: View {
    let sessions: [CopilotSession]
    let selectedSessionID: UUID?
    let onSelect: (CopilotSession) -> Void
    let onDelete: (CopilotSession) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("历史对话")
                .font(.headline)
            if sessions.isEmpty {
                Text("暂无历史对话")
                    .font(.caption)
                    .foregroundStyle(Theme.ColorToken.muted)
                    .frame(maxWidth: .infinity, minHeight: 80)
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(sessions) { session in
                            row(session)
                        }
                    }
                }
                .frame(maxHeight: 320)
            }
        }
        .padding(12)
        .frame(width: 320)
        .background(Theme.ColorToken.panel)
    }

    private func row(_ session: CopilotSession) -> some View {
        HStack(spacing: 8) {
            Button {
                onSelect(session)
            } label: {
                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(session.title)
                            .font(.caption.weight(.semibold))
                            .lineLimit(1)
                        if session.id == selectedSessionID {
                            StatusBadge(title: "Current", tint: Theme.ColorToken.blue)
                        }
                    }
                    Text("\(session.platform.rawValue) · \(session.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption2)
                        .foregroundStyle(Theme.ColorToken.muted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            Button {
                onDelete(session)
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(Theme.ColorToken.muted)
            }
            .buttonStyle(.plain)
        }
        .padding(10)
        .background(session.id == selectedSessionID ? Color.white.opacity(0.075) : Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
