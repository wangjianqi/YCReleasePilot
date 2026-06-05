import Foundation
import SwiftyChat

struct AICopilotChatUser: ChatUser, Equatable {
    let id: String
    let userName: String
    let avatar: PlatformImage?
    let avatarURL: URL?

    init(id: String, userName: String, avatar: PlatformImage? = nil, avatarURL: URL? = nil) {
        self.id = id
        self.userName = userName
        self.avatar = avatar
        self.avatarURL = avatarURL
    }
}

struct AICopilotMarkdownPayload {
    var text: String
    var isStreaming: Bool
}

struct AICopilotChatMessage: ChatMessage {
    let id: UUID
    var user: AICopilotChatUser
    var messageKind: ChatMessageKind
    var isSender: Bool
    var date: Date

    init(
        id: UUID = UUID(),
        user: AICopilotChatUser,
        messageKind: ChatMessageKind,
        isSender: Bool,
        date: Date = Date()
    ) {
        self.id = id
        self.user = user
        self.messageKind = messageKind
        self.isSender = isSender
        self.date = date
    }
}
