import Foundation

enum CopilotRole {
    case assistant
    case user
}

struct CopilotMessage: Identifiable {
    let id = UUID()
    let role: CopilotRole
    let title: String?
    let body: String
    let issues: [CopilotIssue]
    let showsReviewNoteActions: Bool

    init(role: CopilotRole, title: String? = nil, body: String, issues: [CopilotIssue] = [], showsReviewNoteActions: Bool = false) {
        self.role = role
        self.title = title
        self.body = body
        self.issues = issues
        self.showsReviewNoteActions = showsReviewNoteActions
    }
}

struct CopilotIssue: Identifiable {
    let id = UUID()
    let title: String
    let severity: String
    let colorName: String
}
