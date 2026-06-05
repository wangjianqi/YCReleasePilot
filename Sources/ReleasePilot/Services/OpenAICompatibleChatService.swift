import Foundation

enum OpenAICompatibleChatError: LocalizedError, Equatable {
    case invalidBaseURL(String)
    case unsupportedProvider(AIProviderType)
    case emptyResponse
    case httpError(Int, String)

    var errorDescription: String? {
        switch self {
        case .invalidBaseURL(let value):
            "Base URL 无效：\(value)"
        case .unsupportedProvider(let type):
            "\(type.name) 暂未接入真实聊天协议"
        case .emptyResponse:
            "AI 返回内容为空"
        case .httpError(let statusCode, let message):
            "请求失败（HTTP \(statusCode)）：\(message)"
        }
    }
}

struct OpenAICompatibleChatService {
    struct RequestMessage: Encodable {
        let role: String
        let content: String
    }

    struct ResponseMessage: Decodable {
        let role: String?
        let content: String?
    }

    struct Choice: Decodable {
        let message: ResponseMessage?
    }

    struct ChatResponse: Decodable {
        let choices: [Choice]
    }

    struct ErrorEnvelope: Decodable {
        struct ErrorBody: Decodable {
            let message: String?
            let type: String?
            let code: String?
        }

        let error: ErrorBody?
    }

    private struct ChatRequest: Encodable {
        let model: String
        let messages: [RequestMessage]
        let maxCompletionTokens: Int
        let temperature: Double
        let topP: Double
        let stream: Bool
        let thinking: Thinking

        enum CodingKeys: String, CodingKey {
            case model
            case messages
            case maxCompletionTokens = "max_completion_tokens"
            case temperature
            case topP = "top_p"
            case stream
            case thinking
        }
    }

    private struct Thinking: Encodable {
        let type: String
    }

    var session: URLSession = .shared
    var decoder = JSONDecoder()
    var encoder = JSONEncoder()

    func send(
        prompt: String,
        history: [CopilotMessage],
        provider: AIProvider,
        apiKey: String,
        model: String,
        appName: String,
        platform: Platform
    ) async throws -> CopilotMessage {
        guard supports(provider.type) else {
            throw OpenAICompatibleChatError.unsupportedProvider(provider.type)
        }

        let endpoint = try Self.chatCompletionsEndpoint(from: provider.baseURL)
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if provider.type == .xiaomi {
            request.setValue(apiKey, forHTTPHeaderField: "api-key")
        } else {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }

        let requestMessages = buildMessages(
            prompt: prompt,
            history: history,
            appName: appName,
            platform: platform
        )
        request.httpBody = try encoder.encode(ChatRequest(
            model: model.isEmpty ? provider.defaultModel : model,
            messages: requestMessages,
            maxCompletionTokens: 1024,
            temperature: 0.7,
            topP: 0.95,
            stream: false,
            thinking: Thinking(type: "disabled")
        ))

        let startedAt = Date()
        await MainActor.run {
            NetworkRequestLogger.shared.logRequestStart(endpoint: endpoint.path, method: "POST", queryItems: [])
        }
        do {
            let (data, response) = try await session.data(for: request)
            let duration = Date().timeIntervalSince(startedAt)
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            if (200..<300).contains(statusCode) {
                await MainActor.run {
                    NetworkRequestLogger.shared.logRequestComplete(endpoint: endpoint.path, method: "POST", queryItems: [], statusCode: statusCode, duration: duration)
                }
                let content = try Self.assistantContent(from: data, decoder: decoder)
                return CopilotMessage(role: .assistant, title: "AI 回复", body: content)
            } else {
                let message = Self.errorMessage(from: data, decoder: decoder)
                await MainActor.run {
                    NetworkRequestLogger.shared.logRequestError(endpoint: endpoint.path, method: "POST", queryItems: [], errorMessage: message, duration: duration)
                }
                throw OpenAICompatibleChatError.httpError(statusCode, message)
            }
        } catch let error as OpenAICompatibleChatError {
            throw error
        } catch {
            let duration = Date().timeIntervalSince(startedAt)
            await MainActor.run {
                NetworkRequestLogger.shared.logRequestError(endpoint: endpoint.path, method: "POST", queryItems: [], errorMessage: error.localizedDescription, duration: duration)
            }
            throw error
        }
    }

    func testConnection(provider: AIProvider, apiKey: String) async -> AIProviderConnectionStatus {
        do {
            _ = try await send(
                prompt: "请用一句话回复：连接成功。",
                history: [],
                provider: provider,
                apiKey: apiKey,
                model: provider.defaultModel,
                appName: "ReleasePilot",
                platform: .iOS
            )
            return .connected
        } catch {
            return .connectionFailed
        }
    }

    static func chatCompletionsEndpoint(from baseURL: String) throws -> URL {
        let trimmed = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard var components = URLComponents(string: trimmed), components.scheme != nil, components.host != nil else {
            throw OpenAICompatibleChatError.invalidBaseURL(baseURL)
        }

        let normalizedPath = components.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        if normalizedPath.hasSuffix("chat/completions") {
            return components.url!
        }
        if normalizedPath.isEmpty {
            components.path = "/v1/chat/completions"
        } else if normalizedPath.hasSuffix("v1") {
            components.path = "/\(normalizedPath)/chat/completions"
        } else {
            components.path = "/\(normalizedPath)/v1/chat/completions"
        }
        guard let url = components.url else {
            throw OpenAICompatibleChatError.invalidBaseURL(baseURL)
        }
        return url
    }

    static func assistantContent(from data: Data, decoder: JSONDecoder = JSONDecoder()) throws -> String {
        let response = try decoder.decode(ChatResponse.self, from: data)
        guard let content = response.choices.first?.message?.content?.trimmingCharacters(in: .whitespacesAndNewlines),
              !content.isEmpty else {
            throw OpenAICompatibleChatError.emptyResponse
        }
        return content
    }

    static func errorMessage(from data: Data, decoder: JSONDecoder = JSONDecoder()) -> String {
        if let envelope = try? decoder.decode(ErrorEnvelope.self, from: data),
           let message = envelope.error?.message,
           !message.isEmpty {
            return message
        }
        if let raw = String(data: data, encoding: .utf8), !raw.isEmpty {
            return raw
        }
        return "服务端未返回错误详情"
    }

    private func supports(_ type: AIProviderType) -> Bool {
        switch type {
        case .xiaomi, .openAI, .deepSeek, .qwen, .openRouter, .customOpenAICompatible:
            true
        case .anthropic, .gemini:
            false
        }
    }

    private func buildMessages(
        prompt: String,
        history: [CopilotMessage],
        appName: String,
        platform: Platform
    ) -> [RequestMessage] {
        let system = RequestMessage(
            role: "system",
            content: "你是 ReleasePilot 的发布 Copilot。请基于当前 App 发布上下文给出简洁、可执行的建议。当前 App：\(appName)，平台：\(platform.rawValue)。"
        )
        let recentHistory = history.suffix(10).compactMap { message -> RequestMessage? in
            switch message.role {
            case .user:
                RequestMessage(role: "user", content: message.body)
            case .assistant:
                RequestMessage(role: "assistant", content: message.body)
            }
        }
        return [system] + recentHistory + [RequestMessage(role: "user", content: prompt)]
    }
}
