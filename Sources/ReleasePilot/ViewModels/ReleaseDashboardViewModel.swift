import Observation
import SwiftUI

@Observable
final class ReleaseDashboardViewModel {
    var apps: [AppItem] = MockData.apps
    var selectedAppID: AppItem.ID
    var selectedPlatform: Platform = .iOS
    var selectedScreenshotDevice: ScreenshotDevice = .iPhone69
    var copilotMessages: [CopilotMessage] = MockData.initialCopilotMessages
    var chatInput: String = ""
    var showingSubmitConfirmation = false
    var didSubmit = false
    var reviewNoteApplied = false

    init() {
        selectedAppID = MockData.apps[0].id
    }

    var selectedApp: AppItem {
        apps.first(where: { $0.id == selectedAppID }) ?? apps[0]
    }

    var displayedReadiness: Int {
        reviewNoteApplied && selectedApp.name == "FaceBlur" ? 96 : selectedApp.readiness
    }

    var displayedStatus: String {
        selectedApp.status
    }

    var builds: [BuildInfo] {
        MockData.builds.map { build in
            guard selectedApp.name != "FaceBlur" else { return build }
            return BuildInfo(
                id: build.id - 4,
                version: selectedApp.version,
                uploadedAt: build.uploadedAt,
                size: selectedApp.name == "VideoMagic" ? "128.6 MB" : build.size,
                status: build.status
            )
        }
    }

    var completionItems: [CompletionItem] {
        MockData.completionItems(reviewNoteApplied: reviewNoteApplied)
    }

    var releaseSteps: [ReleaseStep] {
        MockData.releaseSteps(reviewNoteApplied: reviewNoteApplied)
    }

    var todoItems: [TodoItem] {
        MockData.todoItems(reviewNoteApplied: reviewNoteApplied)
    }

    var screenshots: [ScreenshotItem] {
        MockData.screenshots
    }

    func selectApp(_ app: AppItem) {
        selectedAppID = app.id
        if app.name != "FaceBlur" {
            reviewNoteApplied = false
        }
        copilotMessages = [
            CopilotMessage(role: .assistant, title: "已切换到 \(app.name)", body: "我会基于 \(app.version) (\(app.buildNumber)) 的本地 Mock 发布数据重新评估风险、截图和审核信息。")
        ] + MockData.initialCopilotMessages.dropFirst()
    }

    func sendChat() {
        let text = chatInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        copilotMessages.append(CopilotMessage(role: .user, body: text))
        copilotMessages.append(CopilotMessage(role: .assistant, title: "模拟 AI 回复", body: "我已收到你的问题：\(text)\n\n基于当前发布状态，建议优先完成 iPad 截图与审核备注，然后再优化关键词和副标题。"))
        chatInput = ""
    }

    func applyReviewNote() {
        reviewNoteApplied = true
        copilotMessages.append(CopilotMessage(role: .assistant, title: "审核备注已应用", body: "Review Info 已从警告改为完成，发布准备度已更新为 96%。"))
    }

    func requestSubmit() {
        showingSubmitConfirmation = true
    }

    func confirmSubmit() {
        didSubmit = true
        showingSubmitConfirmation = false
    }
}
