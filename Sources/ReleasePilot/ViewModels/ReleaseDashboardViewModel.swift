import AppKit
import Observation
import SwiftUI

@Observable
final class ReleaseDashboardViewModel {
    var appReleases: [String: AppReleaseMock] = MockData.releaseMap
    var appOrder: [String] = MockData.releases.map(\.app.id)
    var selectedAppID: AppItem.ID
    var selectedPlatform: Platform = .iOS
    var selectedScreenshotDevice: ScreenshotDevice = .iPhone69
    var currentPage: MainPage = .dashboard
    var focusedModule: ReleaseModule?
    var copilotMessages: [CopilotMessage]
    var chatInput: String = ""
    var showingSubmitConfirmation = false
    var didSubmit = false
    var blockedSubmitMessage: String?
    var activeDialog: ActiveDialog?
    var toastMessage: String?
    var appSearchText = ""
    var showingAddAppSheet = false
    var appDraft = AppDraft()

    var isSidebarCollapsed = false
    var isCopilotHidden = false
    var isCopilotExpanded = false
    var showAllTodos = false
    var showAllSuggestions = false
    var showAllBuilds = false
    var showReleaseDetails = false
    var isSyncingAppStoreConnect = false
    var appStoreConnectSyncMessage: String?
    var isUsingAppStoreConnectData = false
    var appStoreConnectAccountTitle: String?
    var appStoreConnectAccountSubtitle: String?

    private let appStoreConnectConfigService: AppStoreConnectConfigService
    private let appStoreConnectAPIService: AppStoreConnectAPIService
    private let appStoreConnectSnapshotCacheService: AppStoreConnectSnapshotCacheService

    var releasePlanDraft = ReleasePlan(
        releaseMode: .manualAfterApproval,
        timing: .immediate,
        scheduledAt: Date().addingTimeInterval(86400),
        releaseNotes: "",
        notifyTeam: true,
        monitorReview: true
    )

    init(
        appStoreConnectConfigService: AppStoreConnectConfigService = AppStoreConnectConfigService(),
        appStoreConnectAPIService: AppStoreConnectAPIService = AppStoreConnectAPIService(),
        appStoreConnectSnapshotCacheService: AppStoreConnectSnapshotCacheService = AppStoreConnectSnapshotCacheService()
    ) {
        self.appStoreConnectConfigService = appStoreConnectConfigService
        self.appStoreConnectAPIService = appStoreConnectAPIService
        self.appStoreConnectSnapshotCacheService = appStoreConnectSnapshotCacheService
        let first = MockData.releases[0]
        selectedAppID = first.app.id
        copilotMessages = MockData.initialCopilotMessages(for: first, platform: .iOS)
        releasePlanDraft = first.data(for: .iOS).releasePlan
    }

    var apps: [AppItem] {
        let ordered = appOrder.compactMap { appReleases[$0]?.app }
        let remaining = appReleases.values
            .filter { release in !appOrder.contains(release.app.id) }
            .map(\.app)
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        return ordered + remaining
    }

    var filteredApps: [AppItem] {
        let query = appSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return apps }
        return apps.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    var selectedRelease: AppReleaseMock {
        appReleases[selectedAppID] ?? MockData.releases[0]
    }

    var currentPlatformData: PlatformReleaseMock {
        selectedRelease.data(for: selectedPlatform)
    }

    var selectedApp: AppItem {
        selectedRelease.app
    }

    var dataSourceTitle: String {
        isUsingAppStoreConnectData ? "App Store Connect" : "本地 Mock"
    }

    var accountDisplayName: String {
        appStoreConnectAccountTitle ?? AppStrings.userName
    }

    var accountDisplaySubtitle: String {
        appStoreConnectAccountSubtitle ?? AppStrings.userEmail
    }

    var accountAvatarText: String {
        String(accountDisplayName.prefix(1)).uppercased()
    }

    var currentBuild: BuildInfo? {
        currentPlatformData.currentBuild
    }

    var displayedReadiness: Int {
        if canSubmit { return max(selectedApp.readiness, 96) }
        let completedRequired = requiredChecks.filter(\.isComplete).count
        let totalRequired = max(requiredChecks.count, 1)
        let calculated = 62 + Int((Double(completedRequired) / Double(totalRequired)) * 34)
        return min(max(selectedApp.readiness, calculated), 95)
    }

    var displayedStatus: String {
        canSubmit ? "Ready for Review" : selectedApp.status
    }

    var builds: [BuildInfo] {
        currentPlatformData.builds
    }

    var historyItems: [ReleaseHistoryItem] {
        appReleases.values
            .flatMap(\.history)
            .sorted { $0.submittedAt > $1.submittedAt }
    }

    var suggestions: [SuggestionItem] {
        currentPlatformData.suggestions
    }

    var visibleTodos: [TodoItem] {
        showAllTodos ? todoItems : Array(todoItems.prefix(2))
    }

    var visibleSuggestions: [SuggestionItem] {
        showAllSuggestions ? suggestions : Array(suggestions.prefix(3))
    }

    var visibleBuilds: [BuildInfo] {
        showAllBuilds ? builds : Array(builds.prefix(4))
    }

    var completionItems: [CompletionItem] {
        [
            CompletionItem(title: "元数据", percent: completionPercent(for: .metadata), tint: completionTint(for: .metadata)),
            CompletionItem(title: "截图", percent: screenshotCompletionPercent, tint: completionTint(for: .screenshots)),
            CompletionItem(title: "审核信息", percent: completionPercent(for: .reviewInfo), tint: completionTint(for: .reviewInfo)),
            CompletionItem(title: "隐私合规", percent: completionPercent(for: .privacy), tint: completionTint(for: .privacy)),
            CompletionItem(title: "本地化", percent: selectedPlatform == .macOS ? 92 : 85, tint: Theme.ColorToken.green)
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
        currentPlatformData.releaseChecks
            .filter { $0.id != .release && !$0.isComplete }
            .map { releaseCheck in
                TodoItem(
                    id: "\(selectedApp.id)-\(selectedPlatform.id)-todo-\(releaseCheck.id.rawValue)",
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
        currentPlatformData.screenshotsByDevice[selectedScreenshotDevice] ?? []
    }

    var canSubmit: Bool {
        requiredChecks.allSatisfy(\.isComplete)
    }

    var blockingWarnings: [String] {
        requiredChecks.filter { !$0.isComplete }.map(\.warning)
    }

    var releasePlan: ReleasePlan {
        currentPlatformData.releasePlan
    }

    var selectedBundleID: String {
        guard isUsingAppStoreConnectData else { return "iOS, iPadOS, macOS" }
        return valueFromMetadataSubtitle(at: 1) ?? "Unknown Bundle ID"
    }

    var selectedPrimaryLocale: String {
        guard isUsingAppStoreConnectData else { return "5 种语言" }
        return valueFromMetadataSubtitle(at: 0) ?? "Unknown Locale"
    }

    var settingsSections: [SettingsSection] {
        MockData.settingsSections
    }

    private var requiredChecks: [ReleaseCheck] {
        currentPlatformData.releaseChecks.filter { $0.id != .release }
    }

    private var screenshotCompletionPercent: Int {
        let devices = ScreenshotDevice.allCases
        let completed = devices.filter { device in
            let items = currentPlatformData.screenshotsByDevice[device] ?? []
            return !items.isEmpty && !items.contains(where: \.hasWarning)
        }.count
        return Int(Double(completed) / Double(max(devices.count, 1)) * 100)
    }

    func selectPage(_ page: MainPage) {
        currentPage = page
    }

    func selectApp(_ app: AppItem) {
        selectedAppID = app.id
        selectedScreenshotDevice = .iPhone69
        focusedModule = nil
        didSubmit = false
        blockedSubmitMessage = nil
        copilotMessages = MockData.initialCopilotMessages(for: selectedRelease, platform: selectedPlatform)
        releasePlanDraft = releasePlan
    }

    func requestAddApp() {
        appDraft = AppDraft()
        showingAddAppSheet = true
    }

    func cancelAddApp() {
        showingAddAppSheet = false
    }

    func addAppFromDraft(_ draft: AppDraft) {
        guard draft.canSave else { return }
        let release = MockData.makeRelease(from: draft, existingIDs: Set(appReleases.keys))
        isUsingAppStoreConnectData = false
        appStoreConnectAccountTitle = nil
        appStoreConnectAccountSubtitle = nil
        appReleases[release.app.id] = release
        appOrder.append(release.app.id)
        selectedAppID = release.app.id
        selectedPlatform = draft.primaryPlatform
        selectedScreenshotDevice = defaultScreenshotDevice(for: draft.primaryPlatform)
        focusedModule = nil
        didSubmit = false
        blockedSubmitMessage = nil
        copilotMessages = MockData.initialCopilotMessages(for: release, platform: draft.primaryPlatform)
        releasePlanDraft = release.data(for: draft.primaryPlatform).releasePlan
        currentPage = .dashboard
        showingAddAppSheet = false
        showToast("\(release.app.name) 已添加")
    }

    func selectPlatform(_ platform: Platform) {
        selectedPlatform = platform
        selectedScreenshotDevice = defaultScreenshotDevice(for: platform)
        focusedModule = nil
        didSubmit = false
        blockedSubmitMessage = nil
        copilotMessages = MockData.initialCopilotMessages(for: selectedRelease, platform: platform)
        releasePlanDraft = releasePlan
    }

    func syncAppStoreConnect() {
        guard !isSyncingAppStoreConnect else { return }
        isSyncingAppStoreConnect = true
        appStoreConnectSyncMessage = nil
        Task { @MainActor in
            do {
                let config = appStoreConnectConfigService.loadConfig()
                if let cachedSnapshots = appStoreConnectSnapshotCacheService.loadValidSnapshot(for: config) {
                    applyAppStoreConnectSnapshots(cachedSnapshots, config: config)
                    appStoreConnectSyncMessage = "已使用本地缓存，避免重复请求 App Store Connect"
                    showToast(appStoreConnectSyncMessage ?? "已使用本地缓存")
                } else {
                    let snapshots = try await appStoreConnectAPIService.listApps(config: config, limit: 20)
                    guard !snapshots.isEmpty else {
                        appStoreConnectSyncMessage = "App Store Connect 没有返回可见 App。"
                        isSyncingAppStoreConnect = false
                        showToast(appStoreConnectSyncMessage ?? "同步失败")
                        return
                    }
                    appStoreConnectSnapshotCacheService.save(snapshots, for: config)
                    applyAppStoreConnectSnapshots(snapshots, config: config)
                    appStoreConnectSyncMessage = "已同步 \(snapshots.count) 个 App Store Connect App"
                    showToast(appStoreConnectSyncMessage ?? "同步成功")
                }
            } catch {
                let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                appStoreConnectSyncMessage = message
                showToast(message)
            }
            isSyncingAppStoreConnect = false
        }
    }

    private func applyAppStoreConnectSnapshots(_ snapshots: [AppStoreConnectAppSnapshot], config: AppStoreConnectConfig) {
        let releases = snapshots.map { MockData.makeRelease(from: $0) }
        guard let firstRelease = releases.first, let firstSnapshot = snapshots.first else {
            appStoreConnectSyncMessage = "App Store Connect 没有返回可见 App。"
            return
        }
        let firstPlatform = defaultPlatform(from: firstSnapshot.platform)
        appReleases = Dictionary(uniqueKeysWithValues: releases.map { ($0.app.id, $0) })
        appOrder = releases.map(\.app.id)
        isUsingAppStoreConnectData = true
        appStoreConnectAccountTitle = config.teamID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "ASC 已连接" : "Team \(config.teamID)"
        appStoreConnectAccountSubtitle = config.issuerID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "App Store Connect" : "Issuer \(String(config.issuerID.prefix(8)))..."
        selectedPlatform = firstPlatform
        selectedScreenshotDevice = defaultScreenshotDevice(for: firstPlatform)
        focusedModule = nil
        didSubmit = false
        blockedSubmitMessage = nil
        releasePlanDraft = firstRelease.data(for: firstPlatform).releasePlan
        copilotMessages = MockData.initialCopilotMessages(for: firstRelease, platform: firstPlatform)
        selectedAppID = firstRelease.app.id
    }

    func handleTodo(_ todo: TodoItem) {
        currentPage = .dashboard
        focus(todo.targetModule)
        if todo.targetModule == .reviewInfo {
            generateReviewNote()
        }
        if todo.targetModule == .screenshots {
            selectedScreenshotDevice = firstMissingScreenshotDevice() ?? selectedScreenshotDevice
        }
    }

    func sendChat() {
        let text = chatInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        copilotMessages.append(CopilotMessage(role: .user, body: text))
        copilotMessages.append(CopilotMessage(role: .assistant, title: "模拟 AI 回复", body: "我已收到你的问题：\(text)\n\n基于 \(selectedApp.name) \(selectedPlatform.rawValue) 当前发布状态，建议优先处理：\(blockingWarnings.first ?? "关键词和截图细节")。"))
        chatInput = ""
    }

    func generateReviewNote() {
        var release = selectedRelease
        var data = release.data(for: selectedPlatform)
        let note = MockData.reviewNote(for: release, platform: selectedPlatform)
        data.metadata.reviewNote = note
        setCheck(.reviewInfo, complete: true, in: &data)
        save(data, in: &release)
        copilotMessages.append(CopilotMessage(role: .assistant, title: "\(selectedApp.name) \(selectedPlatform.rawValue) 审核备注已生成", body: note, showsReviewNoteActions: true))
        showToast("审核备注已生成")
    }

    func optimizeKeywords() {
        let keywords = currentPlatformData.metadata.keywords
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
        copilotMessages.append(CopilotMessage(role: .assistant, title: title, body: "这是 \(selectedApp.name) \(selectedPlatform.rawValue) 的本地 Mock 分析结果。后续可以接入 AI 网关，把结果写回 metadata 或检查项。"))
    }

    func applyReviewNote() {
        generateReviewNote()
    }

    func addScreenshot() {
        guard let url = chooseImageURL() else { return }
        let cachedURL: URL
        do {
            cachedURL = try LocalAssetCacheService.cacheImportedImage(from: url, namespace: "\(selectedApp.id)-\(selectedPlatform.id)-\(selectedScreenshotDevice.id)")
        } catch {
            showToast("截图缓存失败：\(error.localizedDescription)")
            return
        }
        mutateScreenshots { items in
            let nextSlot = (items.map(\.slot).max() ?? 0) + 1
            items.append(
                ScreenshotItem(
                    id: "\(selectedApp.id)-\(selectedPlatform.id)-\(selectedScreenshotDevice.id)-local-\(UUID().uuidString)",
                    device: selectedScreenshotDevice,
                    slot: nextSlot,
                    title: url.deletingPathExtension().lastPathComponent,
                    subtitle: "本地缓存",
                    hasWarning: false,
                    styleIndex: nextSlot,
                    localImagePath: cachedURL.path
                )
            )
        }
        focus(.screenshots)
        showToast("截图已添加")
    }

    func deleteScreenshot(_ screenshot: ScreenshotItem) {
        mutateScreenshots { items in
            items.removeAll { $0.id == screenshot.id }
        }
        focus(.screenshots)
        showToast("截图已删除")
    }

    func replaceScreenshot(_ screenshot: ScreenshotItem) {
        guard let url = chooseImageURL() else { return }
        let cachedURL: URL
        do {
            cachedURL = try LocalAssetCacheService.cacheImportedImage(from: url, namespace: screenshot.id)
        } catch {
            showToast("截图缓存失败：\(error.localizedDescription)")
            return
        }
        mutateScreenshots { items in
            guard let index = items.firstIndex(where: { $0.id == screenshot.id }) else { return }
            items[index].title = url.deletingPathExtension().lastPathComponent
            items[index].subtitle = "已缓存"
            items[index].hasWarning = false
            items[index].isPlaceholder = false
            items[index].styleIndex += 1
            items[index].localImagePath = cachedURL.path
        }
        focus(.screenshots)
        showToast("截图已替换")
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
        var data = release.data(for: selectedPlatform)
        setCheck(.release, complete: true, in: &data)
        save(data, in: &release)
        didSubmit = true
        showingSubmitConfirmation = false
        showToast("已模拟提交审核")
    }

    func showBuildDetail(_ build: BuildInfo) {
        activeDialog = .buildDetail(build)
    }

    func showVersionHistory() {
        activeDialog = .versionHistory
    }

    func showReleasePlanDialog() {
        releasePlanDraft = releasePlan
        activeDialog = .releasePlan
    }

    func saveReleasePlan() {
        var release = selectedRelease
        var data = release.data(for: selectedPlatform)
        data.releasePlan = releasePlanDraft
        save(data, in: &release)
        activeDialog = nil
        showToast("发布计划已保存")
    }

    func closeDialog() {
        activeDialog = nil
    }

    func showToast(_ message: String) {
        toastMessage = message
    }

    func clearToast() {
        toastMessage = nil
    }

    private func check(for module: ReleaseModule) -> ReleaseCheck? {
        currentPlatformData.releaseChecks.first { $0.id == module }
    }

    private func completionPercent(for module: ReleaseModule) -> Int {
        check(for: module)?.isComplete == true ? 100 : (module == .metadata ? 68 : module == .screenshots ? screenshotCompletionPercent : 70)
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

    private func firstMissingScreenshotDevice() -> ScreenshotDevice? {
        ScreenshotDevice.allCases.first { device in
            let items = currentPlatformData.screenshotsByDevice[device] ?? []
            return items.isEmpty || items.contains(where: \.hasWarning)
        }
    }

    private func defaultScreenshotDevice(for platform: Platform) -> ScreenshotDevice {
        switch platform {
        case .iOS: .iPhone69
        case .iPadOS: .iPadPro
        case .macOS: .mac
        }
    }

    private func defaultPlatform(from value: String?) -> Platform {
        switch value {
        case "IOS": .iOS
        case "MAC_OS": .macOS
        default: .iOS
        }
    }

    private func valueFromMetadataSubtitle(at index: Int) -> String? {
        let parts = currentPlatformData.metadata.subtitle
            .split(separator: "·")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        guard parts.indices.contains(index), !parts[index].isEmpty else { return nil }
        return parts[index]
    }

    private func save(_ data: PlatformReleaseMock, in release: inout AppReleaseMock) {
        release.platformData[selectedPlatform] = data
        appReleases[release.app.id] = release
    }

    private func setCheck(_ module: ReleaseModule, complete: Bool, in data: inout PlatformReleaseMock) {
        guard let index = data.releaseChecks.firstIndex(where: { $0.id == module }) else { return }
        data.releaseChecks[index].isComplete = complete
    }

    private func mutateScreenshots(_ mutation: (inout [ScreenshotItem]) -> Void) {
        var release = selectedRelease
        var data = release.data(for: selectedPlatform)
        var items = data.screenshotsByDevice[selectedScreenshotDevice] ?? []
        mutation(&items)
        data.screenshotsByDevice[selectedScreenshotDevice] = items
        refreshScreenshotCheck(in: &data)
        save(data, in: &release)
    }

    private func refreshScreenshotCheck(in data: inout PlatformReleaseMock) {
        let complete = ScreenshotDevice.allCases.allSatisfy { device in
            let items = data.screenshotsByDevice[device] ?? []
            return !items.isEmpty && !items.contains(where: \.hasWarning)
        }
        setCheck(.screenshots, complete: complete, in: &data)
    }

    private func chooseImageURL() -> URL? {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.png, .jpeg, .heic, .tiff]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        return panel.runModal() == .OK ? panel.url : nil
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
