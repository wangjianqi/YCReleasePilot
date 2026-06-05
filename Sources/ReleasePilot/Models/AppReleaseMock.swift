import Foundation

struct AppMetadata: Hashable {
    var subtitle: String
    var keywords: [String]
    var description: String
    var releaseNotes: String
    var reviewNote: String
}

struct AppReleaseMock: Identifiable {
    var id: String { app.id }
    var app: AppItem
    var platformData: [Platform: PlatformReleaseMock]
    var history: [ReleaseHistoryItem]

    func data(for platform: Platform) -> PlatformReleaseMock {
        platformData[platform] ?? platformData[.iOS]!
    }
}

struct PlatformReleaseMock {
    var metadata: AppMetadata
    var builds: [BuildInfo]
    var screenshotsByDevice: [ScreenshotDevice: [ScreenshotItem]]
    var suggestions: [SuggestionItem]
    var releaseChecks: [ReleaseCheck]
    var copilotIssues: [CopilotIssue]
    var releasePlan: ReleasePlan

    var currentBuild: BuildInfo? {
        builds.first
    }
}

struct ReleaseHistoryItem: Identifiable, Hashable {
    let id: String
    let appName: String
    let platform: Platform
    let version: String
    let build: Int
    let status: String
    let submittedAt: String
    var sortKey: String

    init(
        id: String,
        appName: String,
        platform: Platform,
        version: String,
        build: Int,
        status: String,
        submittedAt: String,
        sortKey: String? = nil
    ) {
        self.id = id
        self.appName = appName
        self.platform = platform
        self.version = version
        self.build = build
        self.status = status
        self.submittedAt = submittedAt
        self.sortKey = sortKey ?? submittedAt
    }
}

struct ReleasePlan: Hashable {
    var releaseMode: ReleaseMode
    var timing: ReleaseTiming
    var scheduledAt: Date
    var releaseNotes: String
    var notifyTeam: Bool
    var monitorReview: Bool

    var summary: String {
        let mode = releaseMode == .manualAfterApproval ? "审核通过后手动发布" : "审核通过后自动发布"
        let time = timing == .immediate ? "立即" : scheduledAt.formatted(date: .abbreviated, time: .shortened)
        return "\(mode) · \(time)"
    }
}

enum ReleaseMode: String, CaseIterable, Identifiable, Hashable {
    case manualAfterApproval
    case automaticAfterApproval

    var id: String { rawValue }

    var title: String {
        switch self {
        case .manualAfterApproval: "审核通过后手动发布"
        case .automaticAfterApproval: "审核通过后自动发布"
        }
    }
}

enum ReleaseTiming: String, CaseIterable, Identifiable, Hashable {
    case immediate
    case scheduled

    var id: String { rawValue }

    var title: String {
        switch self {
        case .immediate: "立即"
        case .scheduled: "指定时间"
        }
    }
}
