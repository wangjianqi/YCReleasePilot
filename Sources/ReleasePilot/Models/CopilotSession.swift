import Foundation

struct CopilotSession: Codable, Identifiable {
    var id: UUID
    var title: String
    var appID: String
    var platform: Platform
    var providerID: UUID?
    var model: String
    var messages: [CopilotMessage]
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String = "New Chat",
        appID: String,
        platform: Platform,
        providerID: UUID? = nil,
        model: String = "gpt-4o",
        messages: [CopilotMessage] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.appID = appID
        self.platform = platform
        self.providerID = providerID
        self.model = model
        self.messages = messages
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
