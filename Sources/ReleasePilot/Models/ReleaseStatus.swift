import SwiftUI

enum StepState: String {
    case done
    case warning
    case pending
}

struct ReleaseStep: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    var state: StepState

    init(id: String = UUID().uuidString, title: String, subtitle: String, state: StepState) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.state = state
    }
}

struct CompletionItem: Identifiable {
    let id = UUID()
    let title: String
    var percent: Int
    var tint: Color
}

struct TodoItem: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let symbol: String
    let actionTitle: String
    let targetModule: ReleaseModule
    var severity: Severity

    init(id: String = UUID().uuidString, title: String, subtitle: String, symbol: String, actionTitle: String, targetModule: ReleaseModule, severity: Severity) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.symbol = symbol
        self.actionTitle = actionTitle
        self.targetModule = targetModule
        self.severity = severity
    }
}

struct SuggestionItem: Identifiable {
    let id = UUID()
    let title: String
    let impact: String
    let tint: Color
}

enum Severity {
    case high
    case medium
    case low
}

enum ReleaseModule: String, CaseIterable, Identifiable {
    case build
    case metadata
    case screenshots
    case reviewInfo
    case privacy
    case release

    var id: String { rawValue }

    var title: String {
        switch self {
        case .build: "Build"
        case .metadata: "Metadata"
        case .screenshots: "Screenshots"
        case .reviewInfo: "Review Info"
        case .privacy: "Privacy"
        case .release: "Release"
        }
    }

    var subtitle: String {
        switch self {
        case .build: "构建版本"
        case .metadata: "元数据"
        case .screenshots: "截图管理"
        case .reviewInfo: "审核信息"
        case .privacy: "隐私合规"
        case .release: "发布提交"
        }
    }
}

struct ReleaseCheck: Identifiable {
    let id: ReleaseModule
    var isComplete: Bool
    var warning: String

    var title: String { id.title }
    var subtitle: String { id.subtitle }
}
