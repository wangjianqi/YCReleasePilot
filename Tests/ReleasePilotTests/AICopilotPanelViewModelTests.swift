import Testing
@testable import ReleasePilot

@MainActor
struct AICopilotPanelViewModelTests {
    @Test
    func sendAddsUserMessageAndStartsStreamingAssistantMessage() async throws {
        let viewModel = AICopilotPanelViewModel()
        let initialCount = viewModel.messages.count

        viewModel.send("优化副标题")
        try await Task.sleep(for: .milliseconds(700))

        #expect(viewModel.messages.count == initialCount + 2)
        #expect(viewModel.messages[initialCount].isSender)
        #expect(viewModel.isStreaming)
    }

    @Test
    func stopStreamingLeavesAssistantMarkdownPayload() async throws {
        let viewModel = AICopilotPanelViewModel()

        viewModel.send("生成审核备注")
        try await Task.sleep(for: .milliseconds(700))
        viewModel.stopStreaming()

        #expect(!viewModel.isStreaming)
        let last = viewModel.messages.last?.messageKind
        if case .custom(let payload as AICopilotMarkdownPayload) = last {
            #expect(!payload.isStreaming)
        } else {
            Issue.record("Expected assistant custom Markdown payload")
        }
    }
}
