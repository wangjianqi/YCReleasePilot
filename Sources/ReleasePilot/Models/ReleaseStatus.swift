import SwiftUI

enum StepState: String {
    case done
    case warning
    case pending
}

struct ReleaseStep: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    var state: StepState
}

struct CompletionItem: Identifiable {
    let id = UUID()
    let title: String
    var percent: Int
    var tint: Color
}

struct TodoItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let symbol: String
    let actionTitle: String
    var severity: Severity
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
