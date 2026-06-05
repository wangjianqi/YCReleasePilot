import AppKit
import LLMStream
import SwiftUI
import SwiftyChat

struct AICopilotPanelView: View {
    @State private var viewModel = AICopilotPanelViewModel()
    let isExpanded: Bool
    let onToggleExpanded: () -> Void
    let onClose: () -> Void
    let quickPrompt: (String) -> String

    init(
        isExpanded: Bool = false,
        onToggleExpanded: @escaping () -> Void = {},
        onClose: @escaping () -> Void = {},
        quickPrompt: @escaping (String) -> String = { $0 }
    ) {
        self.isExpanded = isExpanded
        self.onToggleExpanded = onToggleExpanded
        self.onClose = onClose
        self.quickPrompt = quickPrompt
    }

    var body: some View {
        VStack(spacing: 14) {
            header
            ChatView(
                messages: $viewModel.messages,
                scrollToBottom: $viewModel.scrollToBottom,
                shouldShowGroupChatHeaders: true,
                inputView: {
                    BasicInputView(
                        message: $viewModel.input,
                        placeholder: "Ask ReleasePilot AI...",
                        onCommit: { messageKind in
                            viewModel.send(messageKind)
                        }
                    )
                    .opacity(viewModel.isStreaming ? 0.6 : 1)
                    .disabled(viewModel.isStreaming)
                    .background(Color.clear)
                },
                inset: EdgeInsets(top: 10, leading: 4, bottom: 10, trailing: 4)
            )
            .registerCustomCell { payload in
                if let payload = payload as? AICopilotMarkdownPayload {
                    AICopilotMarkdownMessageView(payload: payload)
                } else {
                    Text("Unsupported AI message")
                        .font(.caption)
                        .foregroundStyle(Theme.ColorToken.muted)
                }
            }
            .messageCellContextMenu { message in
                if case .custom(let payload as AICopilotMarkdownPayload) = message.messageKind {
                    Button {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(payload.text, forType: .string)
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                }
            }
            .environment(\.chatStyle, releasePilotChatStyle)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            quickActions
        }
        .padding(16)
        .frame(minWidth: 340, idealWidth: 420, maxWidth: 520, minHeight: 560)
        .background(surface)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "sparkles")
                .foregroundStyle(Theme.ColorToken.purple)
                .frame(width: 30, height: 30)
                .background(Theme.ColorToken.purple.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text("AI Copilot")
                        .font(.title3.weight(.bold))
                    StatusBadge(title: "SwiftyChat + LLMStream", tint: Theme.ColorToken.blue)
                }
                Label(viewModel.thinkingText, systemImage: viewModel.isStreaming ? "brain.head.profile" : "checkmark.circle")
                    .font(.caption)
                    .foregroundStyle(viewModel.isStreaming ? Theme.ColorToken.orange : Theme.ColorToken.muted)
            }
            Spacer()
            if viewModel.isStreaming {
                Button {
                    viewModel.stopStreaming()
                } label: {
                    Image(systemName: "stop.circle.fill")
                }
                .buttonStyle(.plain)
                .foregroundStyle(Theme.ColorToken.orange)
            }
            Button(action: onToggleExpanded) {
                Image(systemName: isExpanded ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
            }
            .buttonStyle(.plain)
            Button(action: onClose) {
                Image(systemName: "xmark")
            }
            .buttonStyle(.plain)
        }
    }

    private var quickActions: some View {
        HStack(spacing: 8) {
            actionChip("优化副标题")
            actionChip("生成审核备注")
            actionChip("分析审核风险")
        }
    }

    private func actionChip(_ title: String) -> some View {
        Button {
            viewModel.send(quickPrompt(title), displayText: title)
        } label: {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(Theme.ColorToken.text)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .frame(height: 30)
                .background(Color.white.opacity(0.055))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(Theme.ColorToken.line, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isStreaming)
    }

    private var surface: some View {
        LinearGradient(
            colors: [Color(hex: 0x0A1628).opacity(0.92), Color(hex: 0x06101E).opacity(0.96)],
            startPoint: .top,
            endPoint: .bottom
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.surface, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Theme.Radius.surface, style: .continuous).stroke(Theme.ColorToken.line, lineWidth: 1))
        .shadow(color: .black.opacity(0.34), radius: 28, x: 0, y: 18)
    }

    private var releasePilotChatStyle: ChatMessageCellStyle {
        ChatMessageCellStyle(
            incomingTextStyle: TextCellStyle(
                textStyle: CommonTextStyle(textColor: Theme.ColorToken.text, font: .callout, fontWeight: .regular),
                textPadding: 11,
                cellBackgroundColor: Color.white.opacity(0.07),
                cellCornerRadius: 10,
                cellBorderColor: Theme.ColorToken.line,
                cellBorderWidth: 1,
                cellShadowRadius: 0,
                cellShadowColor: .clear
            ),
            outgoingTextStyle: TextCellStyle(
                textStyle: CommonTextStyle(textColor: .white, font: .callout, fontWeight: .regular),
                textPadding: 11,
                cellBackgroundColor: Theme.ColorToken.blue.opacity(0.78),
                cellCornerRadius: 10,
                cellBorderColor: Theme.ColorToken.blue.opacity(0.35),
                cellBorderWidth: 1,
                cellShadowRadius: 0,
                cellShadowColor: .clear
            ),
            incomingCellEdgeInsets: EdgeInsets(top: 4, leading: 2, bottom: 4, trailing: 24),
            outgoingCellEdgeInsets: EdgeInsets(top: 4, leading: 36, bottom: 4, trailing: 2)
        )
    }
}

private struct AICopilotMarkdownMessageView: View {
    let payload: AICopilotMarkdownPayload

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            LLMStreamView(
                text: payload.text,
                configuration: releasePilotLLMStreamConfiguration,
                onUrlClicked: { urlString in
                    guard let url = URL(string: urlString) else { return }
                    NSWorkspace.shared.open(url)
                },
                onCodeAction: { code in
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(code, forType: .string)
                }
            )
            if payload.isStreaming {
                HStack(spacing: 6) {
                    ProgressView()
                        .controlSize(.small)
                    Text("Streaming")
                        .font(.caption2.weight(.medium))
                }
                .foregroundStyle(Theme.ColorToken.orange)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(Theme.ColorToken.line, lineWidth: 1))
    }

    private var releasePilotLLMStreamConfiguration: LLMStreamConfiguration {
        LLMStreamConfiguration(
            colors: ColorConfiguration(
                textColor: Theme.ColorToken.text,
                backgroundColor: .clear,
                codeBackgroundColor: Color(hex: 0x0B1220),
                codeBorderColor: Theme.ColorToken.line,
                linkColor: Theme.ColorToken.blue,
                thoughtBackgroundColor: Color.white.opacity(0.055),
                tableHeaderBackgroundColor: Color.white.opacity(0.08),
                tableBorderColor: Theme.ColorToken.line,
                tableRowEvenColor: Color.white.opacity(0.03),
                tableRowHoverColor: Color.white.opacity(0.06),
                theoremBorderColor: Theme.ColorToken.blue,
                proofBorderColor: Theme.ColorToken.line
            ),
            layout: LayoutConfiguration(
                contentPadding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                codePadding: EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12),
                thoughtPadding: EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8),
                tablePadding: EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8),
                spacing: 8,
                cornerRadius: 8,
                tableCornerRadius: 6,
                theoremCornerRadius: 6
            ),
            codeBlock: CodeBlockConfiguration(
                showLanguage: true,
                showCopyButton: true,
                showActionButton: true,
                languageTextSize: 12,
                copyButtonSize: 14,
                actionButtonSize: 14,
                actionButtonIcon: Image(systemName: "doc.on.doc"),
                actionButtonTooltip: "Copy code"
            )
        )
    }
}

#Preview {
    AICopilotPanelView()
        .frame(width: 420, height: 720)
        .padding()
        .background(Color(hex: 0x020817))
}
