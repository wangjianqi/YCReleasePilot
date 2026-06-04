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
    var metadata: AppMetadata
    var builds: [BuildInfo]
    var screenshotsByDevice: [ScreenshotDevice: [ScreenshotItem]]
    var suggestions: [SuggestionItem]
    var releaseChecks: [ReleaseCheck]
    var copilotIssues: [CopilotIssue]

    var currentBuild: BuildInfo? {
        builds.first
    }
}
