import Foundation

enum AIProviderType: String, CaseIterable, Codable, Identifiable {
    case openAI
    case anthropic
    case gemini
    case deepSeek
    case qwen
    case openRouter
    case customOpenAICompatible

    var id: String { rawValue }

    var name: String {
        switch self {
        case .openAI: "OpenAI"
        case .anthropic: "Anthropic Claude"
        case .gemini: "Gemini"
        case .deepSeek: "DeepSeek"
        case .qwen: "Qwen"
        case .openRouter: "OpenRouter"
        case .customOpenAICompatible: "Custom OpenAI Compatible"
        }
    }

    var symbol: String {
        switch self {
        case .openAI: "sparkles"
        case .anthropic: "brain.head.profile"
        case .gemini: "diamond.fill"
        case .deepSeek: "waveform.path.ecg"
        case .qwen: "cloud.fill"
        case .openRouter: "point.3.connected.trianglepath.dotted"
        case .customOpenAICompatible: "slider.horizontal.3"
        }
    }

    var defaultBaseURL: String {
        switch self {
        case .openAI: "https://api.openai.com/v1"
        case .anthropic: "https://api.anthropic.com"
        case .gemini: "https://generativelanguage.googleapis.com/v1beta"
        case .deepSeek: "https://api.deepseek.com/v1"
        case .qwen: "https://dashscope.aliyuncs.com/compatible-mode/v1"
        case .openRouter: "https://openrouter.ai/api/v1"
        case .customOpenAICompatible: "https://api.example.com/v1"
        }
    }

    var defaultModel: String {
        switch self {
        case .openAI: "gpt-4o"
        case .anthropic: "claude-3-5-sonnet-latest"
        case .gemini: "gemini-1.5-pro"
        case .deepSeek: "deepseek-chat"
        case .qwen: "qwen-plus"
        case .openRouter: "openai/gpt-4o"
        case .customOpenAICompatible: "model-name"
        }
    }
}
