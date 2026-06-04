import Foundation

enum CopilotRole: String, Codable {
    case assistant
    case user
}

struct CopilotMessage: Codable, Identifiable {
    let id: UUID
    let role: CopilotRole
    let title: String?
    let body: String
    let issues: [CopilotIssue]
    let showsReviewNoteActions: Bool

    init(id: UUID = UUID(), role: CopilotRole, title: String? = nil, body: String, issues: [CopilotIssue] = [], showsReviewNoteActions: Bool = false) {
        self.id = id
        self.role = role
        self.title = title
        self.body = body
        self.issues = issues
        self.showsReviewNoteActions = showsReviewNoteActions
    }
}

struct CopilotIssue: Codable, Identifiable {
    let id: UUID
    let title: String
    let severity: String
    let colorName: String

    init(id: UUID = UUID(), title: String, severity: String, colorName: String) {
        self.id = id
        self.title = title
        self.severity = severity
        self.colorName = colorName
    }
}
