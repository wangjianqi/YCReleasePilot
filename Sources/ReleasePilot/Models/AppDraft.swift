import Foundation

enum AppStatusTemplate: String, CaseIterable, Identifiable {
    case readyForReview = "Ready for Review"
    case metadataDraft = "Metadata Draft"
    case needsWork = "Needs Work"

    var id: String { rawValue }

    var incompleteModules: Set<ReleaseModule> {
        switch self {
        case .readyForReview: [.screenshots, .reviewInfo]
        case .metadataDraft: [.metadata, .screenshots, .reviewInfo]
        case .needsWork: [.metadata, .screenshots, .reviewInfo, .privacy]
        }
    }

    var readiness: Int {
        switch self {
        case .readyForReview: 86
        case .metadataDraft: 74
        case .needsWork: 62
        }
    }
}

struct AppDraft {
    var name: String = ""
    var bundleID: String = ""
    var version: String = "1.0.0"
    var buildNumber: String = "1"
    var primaryPlatform: Platform = .iOS
    var iconSymbol: String = "app.fill"
    var statusTemplate: AppStatusTemplate = .metadataDraft

    var sanitizedID: String {
        let source = bundleID.isEmpty ? name : bundleID
        let allowed = source.lowercased().map { character in
            character.isLetter || character.isNumber ? character : "-"
        }
        let value = String(allowed).split(separator: "-").joined(separator: "-")
        return value.isEmpty ? "new-app" : value
    }

    var parsedBuildNumber: Int {
        Int(buildNumber) ?? 1
    }

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
