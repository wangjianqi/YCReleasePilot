import Foundation

enum CopilotSuggestionRisk: String, CaseIterable, Codable {
    case low = "低"
    case medium = "中"
    case high = "高"
}

enum CopilotSuggestionModule: String, CaseIterable, Codable {
    case metadata = "Metadata"
    case screenshots = "Screenshots"
    case reviewInfo = "Review Info"
    case privacy = "Privacy"
    case aso = "ASO"
}

enum CopilotSuggestionState: String, Codable {
    case open
    case applied
    case ignored
}

struct CopilotSuggestion: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var risk: CopilotSuggestionRisk
    var module: CopilotSuggestionModule
    var reason: String
    var actionTitle: String
    var state: CopilotSuggestionState

    init(
        id: UUID = UUID(),
        title: String,
        risk: CopilotSuggestionRisk,
        module: CopilotSuggestionModule,
        reason: String,
        actionTitle: String,
        state: CopilotSuggestionState = .open
    ) {
        self.id = id
        self.title = title
        self.risk = risk
        self.module = module
        self.reason = reason
        self.actionTitle = actionTitle
        self.state = state
    }
}
