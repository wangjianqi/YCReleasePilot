import Observation
import SwiftUI

@Observable
final class ReleaseDashboardViewModel {
    var appReleases: [String: AppReleaseMock] = MockData.releaseMap
    var selectedAppID: AppItem.ID
    var selectedPlatform: Platform = .iOS
    var selectedScreenshotDevice: ScreenshotDevice = .iPhone69
    var focusedModule: ReleaseModule?
    var copilotMessages: [CopilotMessage]
    var chatInput: String = ""
    var showingSubmitConfirmation = false
    var didSubmit = false
    var blockedSubmitMessage: String?

    init() {
        let first = MockData.releases[0]
        selectedAppID = first.app.id
        copilotMessages = MockData.initialCopilotMessages(for: first)
    }

    var apps: [AppItem] {
        MockData.apps
    }

    var selectedRelease: AppReleaseMock {
        appReleases[selectedAppID] ?? MockData.releases[0]
    }

    var selectedApp: AppItem {
        selectedRelease.app
    }

    var displayedReadiness: Int {
        let appReadiness = selectedRelease.app.readiness
        if canSubmit {
            return max(appReadiness, 96)
        }
        let completedRequired = requiredChecks.filter(\.isComplete).count
        let totalRequired = max(requiredChecks.count, 1)
        let calculated = 62 + Int((Double(completedRequired) / Double(totalRequired)) * 34)
        return min(max(appReadiness, calculated), 95)
    }

    var displayedStatus: String {
        canSubmit ? "Ready for Review" : selectedRelease.app.status
    }

    var builds: [BuildInfo] {
        selectedRelease.builds
    }

    var suggestions: [SuggestionItem] {
        selectedRelease.suggestions
    }

    var completionItems: [CompletionItem] {
        [
            CompletionItem(title: "元数据", percent: completionPercent(for: .metadata), tint: completionTint(for: .metadata)),
            CompletionItem(title: "截图", percent: completionPercent(for: .screenshots), tint: completionTint(for: .screenshots)),
            CompletionItem(title: "审核信息", percent: completionPercent(for: .reviewInfo), tint: completionTint(for: .reviewInfo)),
            CompletionItem(title: "隐私合规", percent: completionPercent(for: .privacy), tint: completionTint(for: .privacy)),
            CompletionItem(title: "本地化", percent: selectedRelease.app.id == "tuneflow" ? 72 : 85, tint: Theme.ColorToken.green)
        ]
    }

    var releaseSteps: [ReleaseStep] {
        ReleaseModule.allCases.map { module in
            let state: StepState
            if module == .release {
                state = canSubmit ? .done : .pending
            } else {
                state = check(for: module)?.isComplete == true ? .done : .warning
            }
            return ReleaseStep(id: module.id, title: module.title, subtitle: module.subtitle, state: state)
        }
    }

    var todoItems: [TodoItem] {
        selectedRelease.releaseChecks
            .filter { $0.id != .release && !$0.isComplete }
            .map { releaseCheck in
                TodoItem(
                    id: "\(selectedApp.id)-todo-\(releaseCheck.id.rawValue)",
                    title: todoTitle(for: releaseCheck.id),
                    subtitle: releaseCheck.warning,
                    symbol: todoSymbol(for: releaseCheck.id),
                    actionTitle: todoActionTitle(for: releaseCheck.id),
                    targetModule: releaseCheck.id,
                    severity: releaseCheck.id == .privacy || releaseCheck.id == .reviewInfo ? .high : .medium
                )
            }
    }

    var screenshots: [ScreenshotItem] {
        selectedRelease.screenshotsByDevice[selectedScreenshotDevice] ?? []
    }

    var canSubmit: Bool {
        requiredChecks.allSatisfy(\.isComplete)
    }

    var blockingWarnings: [String] {
        requiredChecks.filter { !$0.isComplete }.map(\.warning)
    }

    private var requiredChecks: [ReleaseCheck] {
        selectedRelease.releaseChecks.filter { $0.id != .release }
    }

    func selectApp(_ app: AppItem) {
        selectedAppID = app.id
        selectedScreenshotDevice = .iPhone69
        focusedModule = nil
        didSubmit = false
        blockedSubmitMessage = nil
        copilotMessages = MockData.initialCopilotMessages(for: selectedRelease)
    }

    func handleTodo(_ todo: TodoItem) {
        focus(todo.targetModule)
        if todo.targetModule == .reviewInfo {
            generateReviewNote()
        }
        if todo.targetModule == .screenshots {
            selectedScreenshotDevice = .iPadPro
        }
    }

    func sendChat() {
        let text = chatInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        copilotMessages.append(CopilotMessage(role: .user, body: text))
        copilotMessages.append(CopilotMessage(role: .assistant, title: "模拟 AI 回复", body: "我已收到你的问题：\(text)\n\n基于 \(selectedApp.name) 当前发布状态，建议优先处理：\(blockingWarnings.first ?? "关键词和截图细节")。"))
        chatInput = ""
    }

    func generateReviewNote() {
        var release = selectedRelease
        let note = MockData.reviewNote(for: release)
        release.metadata.reviewNote = note
        setCheck(.reviewInfo, complete: true, in: &release)
        save(release)
        copilotMessages.append(CopilotMessage(role: .assistant, title: "\(selectedApp.name) 审核备注已生成", body: note, showsReviewNoteActions: true))
    }

    func optimizeKeywords() {
        let keywords = selectedRelease.metadata.keywords
        let unique = Array(Dictionary(grouping: keywords.map { $0.lowercased() }, by: { $0 }).keys).sorted()
        let additions = ["productivity", "creator", selectedApp.name.lowercased()].filter { !unique.contains($0) }
        let body = """
        当前关键词：\(keywords.joined(separator: ", "))

        建议去重后保留：\(unique.joined(separator: ", "))
        建议补充：\(additions.joined(separator: ", "))

        原因：当前关键词存在重复项，建议把高意图词放在前 100 字符内，并补充能表达核心使用场景的词。
        """
        copilotMessages.append(CopilotMessage(role: .assistant, title: "\(selectedApp.name) 关键词优化建议", body: body))
    }

    func quickCopilot(_ title: String) {
        copilotMessages.append(CopilotMessage(role: .assistant, title: title, body: "这是 \(selectedApp.name) 的本地 Mock 分析结果。后续可以接入 AI 网关，把结果写回 metadata 或检查项。"))
    }

    func applyReviewNote() {
        generateReviewNote()
    }

    func addScreenshot() {
        var release = selectedRelease
        var items = release.screenshotsByDevice[selectedScreenshotDevice] ?? []
        for index in items.indices {
            items[index].hasWarning = false
        }
        let nextSlot = (items.map(\.slot).max() ?? 0) + 1
        items.append(
            ScreenshotItem(
                id: "\(selectedApp.id)-\(selectedScreenshotDevice.id)-mock-\(nextSlot)",
                device: selectedScreenshotDevice,
                slot: nextSlot,
                title: "新增截图",
                subtitle: selectedScreenshotDevice.rawValue,
                hasWarning: false,
                isPlaceholder: false,
                styleIndex: nextSlot
            )
        )
        release.screenshotsByDevice[selectedScreenshotDevice] = items
        refreshScreenshotCheck(in: &release)
        save(release)
        focus(.screenshots)
    }

    func deleteScreenshot(_ screenshot: ScreenshotItem) {
        var release = selectedRelease
        var items = release.screenshotsByDevice[selectedScreenshotDevice] ?? []
        items.removeAll { $0.id == screenshot.id }
        release.screenshotsByDevice[selectedScreenshotDevice] = items
        refreshScreenshotCheck(in: &release)
        save(release)
        focus(.screenshots)
    }

    func replaceScreenshot(_ screenshot: ScreenshotItem) {
        var release = selectedRelease
        var items = release.screenshotsByDevice[selectedScreenshotDevice] ?? []
        guard let index = items.firstIndex(where: { $0.id == screenshot.id }) else { return }
        items[index].title = "已替换"
        items[index].subtitle = "审核就绪"
        items[index].hasWarning = false
        items[index].isPlaceholder = false
        items[index].styleIndex += 1
        release.screenshotsByDevice[selectedScreenshotDevice] = items
        refreshScreenshotCheck(in: &release)
        save(release)
        focus(.screenshots)
    }

    func requestSubmit() {
        guard canSubmit else {
            blockedSubmitMessage = "仍有 \(blockingWarnings.count) 项未完成：\(blockingWarnings.joined(separator: "、"))"
            focus(firstBlockingModule() ?? .release)
            copilotMessages.append(CopilotMessage(role: .assistant, title: "暂不能提交审核", body: blockedSubmitMessage ?? "仍有检查项未完成。"))
            return
        }
        blockedSubmitMessage = nil
        showingSubmitConfirmation = true
    }

    func confirmSubmit() {
        var release = selectedRelease
        setCheck(.release, complete: true, in: &release)
        save(release)
        didSubmit = true
        showingSubmitConfirmation = false
    }

    private func check(for module: ReleaseModule) -> ReleaseCheck? {
        selectedRelease.releaseChecks.first { $0.id == module }
    }

    private func completionPercent(for module: ReleaseModule) -> Int {
        check(for: module)?.isComplete == true ? 100 : (module == .metadata ? 68 : module == .screenshots ? 80 : 70)
    }

    private func completionTint(for module: ReleaseModule) -> Color {
        check(for: module)?.isComplete == true ? Theme.ColorToken.green : Theme.ColorToken.orange
    }

    private func focus(_ module: ReleaseModule) {
        focusedModule = module
    }

    private func firstBlockingModule() -> ReleaseModule? {
        requiredChecks.first { !$0.isComplete }?.id
    }

    private func save(_ release: AppReleaseMock) {
        appReleases[release.app.id] = release
    }

    private func setCheck(_ module: ReleaseModule, complete: Bool, in release: inout AppReleaseMock) {
        guard let index = release.releaseChecks.firstIndex(where: { $0.id == module }) else { return }
        release.releaseChecks[index].isComplete = complete
    }

    private func refreshScreenshotCheck(in release: inout AppReleaseMock) {
        let currentDeviceScreenshots = release.screenshotsByDevice[selectedScreenshotDevice] ?? []
        let hasRequiredScreenshots = !currentDeviceScreenshots.isEmpty
        let hasWarnings = currentDeviceScreenshots.contains { $0.hasWarning }
        setCheck(.screenshots, complete: hasRequiredScreenshots && !hasWarnings, in: &release)
    }

    private func todoTitle(for module: ReleaseModule) -> String {
        switch module {
        case .build: "缺少可用 Build"
        case .metadata: "元数据需要完善"
        case .screenshots: "缺少或需替换截图"
        case .reviewInfo: "缺少审核备注"
        case .privacy: "隐私合规待确认"
        case .release: "发布提交未完成"
        }
    }

    private func todoSymbol(for module: ReleaseModule) -> String {
        switch module {
        case .build: "shippingbox.fill"
        case .metadata: "text.quote"
        case .screenshots: "rectangle.stack.badge.plus"
        case .reviewInfo: "sparkles"
        case .privacy: "hand.raised.fill"
        case .release: "paperplane.fill"
        }
    }

    private func todoActionTitle(for module: ReleaseModule) -> String {
        switch module {
        case .reviewInfo: "AI 生成"
        case .screenshots: "去处理"
        case .metadata: "查看"
        case .privacy: "检查"
        case .build: "查看"
        case .release: "查看"
        }
    }
}
