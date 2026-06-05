import Foundation
import Observation
import SwiftyChat

@MainActor
@Observable
final class AICopilotPanelViewModel {
    var messages: [AICopilotChatMessage]
    var input = ""
    var isStreaming = false
    var thinkingText = "Ready"
    var scrollToBottom = false

    private let user = AICopilotChatUser(id: "release-manager", userName: "You")
    private let assistant = AICopilotChatUser(id: "releasepilot-ai", userName: "ReleasePilot AI")
    private var streamingTask: Task<Void, Never>?

    init() {
        messages = [
            AICopilotChatMessage(
                user: assistant,
                messageKind: .custom(AICopilotMarkdownPayload(
                    text: """
                    我可以基于当前发布上下文优化副标题、关键词、审核备注和风险项。

                    这个面板使用 **SwiftyChat** 承载聊天列表与输入框，AI 回复使用 **LLMStream** 渲染 Markdown 和代码块。
                    """,
                    isStreaming: false
                )),
                isSender: false
            )
        ]
    }

    func sendCurrentInput() {
        let prompt = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty, !isStreaming else { return }
        input = ""
        send(prompt)
    }

    func send(_ messageKind: ChatMessageKind) {
        guard case .text(let text) = messageKind else { return }
        send(text)
    }

    func send(_ prompt: String, displayText: String? = nil) {
        guard !isStreaming else { return }
        messages.append(AICopilotChatMessage(user: user, messageKind: .text(displayText ?? prompt), isSender: true))
        let responseID = UUID()
        messages.append(AICopilotChatMessage(user: assistant, messageKind: .loading, isSender: false, date: Date()))
        scrollToBottom = true
        isStreaming = true
        thinkingText = "Thinking about release metadata..."

        streamingTask?.cancel()
        streamingTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(550))
            guard let self, !Task.isCancelled else { return }
            replaceLastAssistantMessage(
                id: responseID,
                text: "",
                isStreaming: true
            )

            var rendered = ""
            for chunk in Self.mockChunks(for: prompt) {
                guard !Task.isCancelled else { return }
                rendered += chunk
                replaceLastAssistantMessage(
                    id: responseID,
                    text: rendered,
                    isStreaming: true
                )
                try? await Task.sleep(for: .milliseconds(55))
            }

            replaceLastAssistantMessage(id: responseID, text: rendered, isStreaming: false)
            isStreaming = false
            thinkingText = "Ready"
            scrollToBottom = true
        }
    }

    func stopStreaming() {
        streamingTask?.cancel()
        streamingTask = nil
        isStreaming = false
        thinkingText = "Stopped"
        if let index = messages.lastIndex(where: { !$0.isSender }) {
            switch messages[index].messageKind {
            case .custom(let payload as AICopilotMarkdownPayload):
                messages[index].messageKind = .custom(AICopilotMarkdownPayload(text: payload.text, isStreaming: false))
            default:
                messages[index].messageKind = .custom(AICopilotMarkdownPayload(text: "已停止生成。", isStreaming: false))
            }
        }
    }

    private func replaceLastAssistantMessage(id: UUID, text: String, isStreaming: Bool) {
        guard let index = messages.lastIndex(where: { !$0.isSender }) else { return }
        messages[index] = AICopilotChatMessage(
            id: id,
            user: assistant,
            messageKind: .custom(AICopilotMarkdownPayload(text: text, isStreaming: isStreaming)),
            isSender: false,
            date: messages[index].date
        )
        scrollToBottom = true
    }

    private static func mockChunks(for prompt: String) -> [String] {
        let response = """
        <think>正在读取当前发布上下文，并检查副标题长度、关键词重复度和审核风险。</think>

        ### 建议结论

        你刚输入的是：**\(prompt)**。如果这是“优化副标题”，我会直接使用当前 App 元数据，而不是反问当前副标题。

        | 版本 | 副标题 | 说明 |
        | --- | --- | --- |
        | A | Smart Cleanup for Photos | 强调智能清理和照片场景 |
        | B | Free Space, Keep Memories | 强调释放空间和情感价值 |
        | C | Find Duplicates Fast | 强调去重效率 |

        推荐使用 **Free Space, Keep Memories**，它比单纯功能词更容易覆盖真实用户痛点。

        ```swift
        let subtitle = "Free Space, Keep Memories"
        let maxLength = 30
        assert(subtitle.count <= maxLength)
        ```

        下一步可以把推荐副标题写回 metadata draft，或继续生成 5 个 A/B 测试版本。
        """
        return response.split(separator: " ", omittingEmptySubsequences: false).map { "\($0) " }
    }
}
