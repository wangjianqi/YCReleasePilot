import Foundation

enum FeatureFlag: String, CaseIterable, Identifiable {
    case aiCopilotChat
    case advancedReviewRisk
    case batchTranslation
    case asoKeywordOptimization
    case multipleApps
    case releaseHistoryAnalytics

    var id: String { rawValue }

    var title: String {
        switch self {
        case .aiCopilotChat: "AI Copilot 高级对话"
        case .advancedReviewRisk: "AI 审核风险分析"
        case .batchTranslation: "多语言批量翻译"
        case .asoKeywordOptimization: "ASO 关键词优化"
        case .multipleApps: "批量 App 管理"
        case .releaseHistoryAnalytics: "发布历史分析"
        }
    }
}
