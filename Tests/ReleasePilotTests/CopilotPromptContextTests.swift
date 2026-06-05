import Testing
@testable import ReleasePilot

@MainActor
struct CopilotPromptContextTests {
    @Test
    func subtitleQuickActionIncludesExistingMetadataContext() {
        let viewModel = ReleaseDashboardViewModel()

        let prompt = viewModel.copilotPrompt(for: "优化副标题")

        #expect(prompt.contains("当前副标题：iOS release workspace"))
        #expect(prompt.contains("当前关键词：AI, portrait, blur, photo, beauty, blur"))
        #expect(prompt.contains("不要反问我已有字段是什么"))
        #expect(prompt.contains("每个不超过 30 个字符"))
    }
}
