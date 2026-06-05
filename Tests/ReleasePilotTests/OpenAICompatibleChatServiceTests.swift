import Foundation
import Testing
@testable import ReleasePilot

struct OpenAICompatibleChatServiceTests {
    @Test
    func chatCompletionsEndpointAcceptsVersionedBaseURL() throws {
        let url = try OpenAICompatibleChatService.chatCompletionsEndpoint(from: "https://token-plan-sgp.xiaomimimo.com/v1")

        #expect(url.absoluteString == "https://token-plan-sgp.xiaomimimo.com/v1/chat/completions")
    }

    @Test
    func chatCompletionsEndpointKeepsFullEndpoint() throws {
        let url = try OpenAICompatibleChatService.chatCompletionsEndpoint(from: "https://token-plan-sgp.xiaomimimo.com/v1/chat/completions")

        #expect(url.absoluteString == "https://token-plan-sgp.xiaomimimo.com/v1/chat/completions")
    }

    @Test
    func assistantContentParsesOpenAICompatibleResponse() throws {
        let data = Data("""
        {
          "choices": [
            {
              "message": {
                "role": "assistant",
                "content": "连接成功"
              }
            }
          ]
        }
        """.utf8)

        let content = try OpenAICompatibleChatService.assistantContent(from: data)

        #expect(content == "连接成功")
    }

    @Test
    func errorMessageParsesOpenAICompatibleError() {
        let data = Data("""
        {
          "error": {
            "message": "invalid api key",
            "type": "invalid_request_error",
            "code": "unauthorized"
          }
        }
        """.utf8)

        #expect(OpenAICompatibleChatService.errorMessage(from: data) == "invalid api key")
    }
}
