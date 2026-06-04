import SwiftUI

enum MockData {
    static let releases: [AppReleaseMock] = [
        release(
            app: AppItem(id: "faceblur", name: "FaceBlur", version: "2.1.0", buildNumber: 47, iconSymbol: "person.crop.square.fill", iconGradient: [Color(hex: 0xF6C7A7), Theme.ColorToken.purple], readiness: 92, passRate: 87, reviewHours: "24 – 48", aiScore: 85, status: "Ready for Review"),
            metadata: AppMetadata(
                subtitle: "AI portrait blur editor",
                keywords: ["AI", "portrait", "blur", "photo", "beauty", "blur"],
                description: "FaceBlur helps creators blur portraits and refine background depth locally.",
                releaseNotes: "Improved portrait segmentation and screenshot workflow.",
                reviewNote: ""
            ),
            buildStart: 47,
            size: "38.4 MB",
            incomplete: [.screenshots, .reviewInfo],
            screenshotWarningSlot: 3,
            suggestions: [
                SuggestionItem(title: "第 3 张截图文案区域过大", impact: "低影响", tint: Theme.ColorToken.green),
                SuggestionItem(title: "关键词重复率较高", impact: "中影响", tint: Theme.ColorToken.orange),
                SuggestionItem(title: "副标题利用率只有 60%", impact: "中影响", tint: Theme.ColorToken.orange)
            ]
        ),
        release(
            app: AppItem(id: "snapedit", name: "SnapEdit", version: "1.8.3", buildNumber: 36, iconSymbol: "camera.aperture", iconGradient: [Color(hex: 0x10B981), Color(hex: 0x22D3EE)], readiness: 78, passRate: 76, reviewHours: "36 – 60", aiScore: 78, status: "Metadata Draft"),
            metadata: AppMetadata(
                subtitle: "Fast camera retouching",
                keywords: ["camera", "retouch", "filter", "photo", "editor", "camera"],
                description: "SnapEdit provides fast camera retouching and export presets.",
                releaseNotes: "Added faster export presets for social media.",
                reviewNote: ""
            ),
            buildStart: 36,
            size: "42.2 MB",
            incomplete: [.metadata, .screenshots, .reviewInfo],
            screenshotWarningSlot: 2,
            suggestions: [
                SuggestionItem(title: "关键词 camera 重复出现", impact: "中影响", tint: Theme.ColorToken.orange),
                SuggestionItem(title: "描述缺少隐私处理说明", impact: "高影响", tint: Theme.ColorToken.red),
                SuggestionItem(title: "截图缺少横向场景", impact: "低影响", tint: Theme.ColorToken.green)
            ]
        ),
        release(
            app: AppItem(id: "videomagic", name: "VideoMagic", version: "3.2.1", buildNumber: 105, iconSymbol: "play.rectangle.fill", iconGradient: [Color(hex: 0xFDE047), Color(hex: 0x7C3AED)], readiness: 84, passRate: 81, reviewHours: "24 – 72", aiScore: 80, status: "Ready for Review"),
            metadata: AppMetadata(
                subtitle: "Magic video templates",
                keywords: ["video", "template", "cut", "caption", "reels", "video"],
                description: "VideoMagic turns clips into polished templates with local previews.",
                releaseNotes: "New caption templates and faster timeline previews.",
                reviewNote: "Demo account is not required. All editing features can be tested with bundled sample media."
            ),
            buildStart: 105,
            size: "128.6 MB",
            incomplete: [.screenshots],
            screenshotWarningSlot: 4,
            suggestions: [
                SuggestionItem(title: "Mac 截图仍缺少编辑器全景", impact: "中影响", tint: Theme.ColorToken.orange),
                SuggestionItem(title: "副标题可强化模板卖点", impact: "低影响", tint: Theme.ColorToken.green)
            ]
        ),
        release(
            app: AppItem(id: "tuneflow", name: "TuneFlow", version: "1.4.0", buildNumber: 23, iconSymbol: "music.note.list", iconGradient: [Color(hex: 0x14B8A6), Color(hex: 0x0EA5E9)], readiness: 68, passRate: 69, reviewHours: "48 – 72", aiScore: 73, status: "Needs Work"),
            metadata: AppMetadata(
                subtitle: "Music planning workspace",
                keywords: ["music", "playlist", "timer", "mix", "flow", "playlist"],
                description: "TuneFlow organizes music planning and lightweight playlist notes.",
                releaseNotes: "Improved playlist planning and timeline markers.",
                reviewNote: ""
            ),
            buildStart: 23,
            size: "55.8 MB",
            incomplete: [.metadata, .screenshots, .reviewInfo, .privacy],
            screenshotWarningSlot: 1,
            suggestions: [
                SuggestionItem(title: "隐私合规说明缺少音频权限用途", impact: "高影响", tint: Theme.ColorToken.red),
                SuggestionItem(title: "关键词 playlist 重复率偏高", impact: "中影响", tint: Theme.ColorToken.orange),
                SuggestionItem(title: "更新说明过短", impact: "低影响", tint: Theme.ColorToken.green)
            ]
        ),
        release(
            app: AppItem(id: "chatlens", name: "ChatLens", version: "2.0.0", buildNumber: 51, iconSymbol: "bubble.left.and.bubble.right.fill", iconGradient: [Color(hex: 0x6366F1), Color(hex: 0x8B5CF6)], readiness: 88, passRate: 84, reviewHours: "24 – 48", aiScore: 82, status: "Ready for Review"),
            metadata: AppMetadata(
                subtitle: "AI chat insight reader",
                keywords: ["chat", "ai", "summary", "insight", "reader", "ai"],
                description: "ChatLens summarizes chat exports and highlights follow-up tasks.",
                releaseNotes: "Added local summary templates and review-ready screenshots.",
                reviewNote: "The app can be tested with included sample chat transcripts. No login is required."
            ),
            buildStart: 51,
            size: "64.1 MB",
            incomplete: [.reviewInfo],
            screenshotWarningSlot: nil,
            suggestions: [
                SuggestionItem(title: "AI 相关描述建议强调本地处理", impact: "中影响", tint: Theme.ColorToken.orange),
                SuggestionItem(title: "关键词 ai 重复率偏高", impact: "中影响", tint: Theme.ColorToken.orange)
            ]
        )
    ]

    static var apps: [AppItem] {
        releases.map(\.app)
    }

    static var releaseMap: [String: AppReleaseMock] {
        Dictionary(uniqueKeysWithValues: releases.map { ($0.app.id, $0) })
    }

    static func initialCopilotMessages(for release: AppReleaseMock) -> [CopilotMessage] {
        [
            CopilotMessage(
                role: .assistant,
                title: "我已分析 \(release.app.name) v\(release.app.version) 的发布状态，发现以下问题和优化建议：",
                body: "需要我帮你优化这些内容吗？",
                issues: release.copilotIssues
            ),
            CopilotMessage(role: .user, body: AppStrings.userPrompt),
            CopilotMessage(
                role: .assistant,
                title: "已为你生成审核备注：",
                body: reviewNote(for: release),
                showsReviewNoteActions: true
            )
        ]
    }

    static func reviewNote(for release: AppReleaseMock) -> String {
        "感谢审核团队的辛勤工作！\(release.app.name) \(release.app.version) 是一款面向桌面和移动端用户的效率应用。\n\n本次版本重点更新：\(release.metadata.releaseNotes)\n\n应用内功能均符合 App Store 规范，不包含虚假宣传或违规内容。需要访问的权限仅用于核心功能，用户数据默认在本地处理。"
    }

    private static func release(app: AppItem, metadata: AppMetadata, buildStart: Int, size: String, incomplete: Set<ReleaseModule>, screenshotWarningSlot: Int?, suggestions: [SuggestionItem]) -> AppReleaseMock {
        AppReleaseMock(
            app: app,
            metadata: metadata,
            builds: builds(start: buildStart, version: app.version, size: size),
            screenshotsByDevice: screenshots(appID: app.id, warningSlot: screenshotWarningSlot),
            suggestions: suggestions,
            releaseChecks: ReleaseModule.allCases.map { module in
                ReleaseCheck(id: module, isComplete: !incomplete.contains(module) && module != .release, warning: warning(for: module))
            },
            copilotIssues: issues(incomplete: incomplete, suggestions: suggestions)
        )
    }

    private static func builds(start: Int, version: String, size: String) -> [BuildInfo] {
        [
            BuildInfo(id: start, version: version, uploadedAt: "2024-05-20 14:35", size: size, status: "Processing Complete"),
            BuildInfo(id: start - 1, version: version, uploadedAt: "2024-05-18 11:20", size: size, status: "Processing Complete"),
            BuildInfo(id: start - 2, version: version, uploadedAt: "2024-05-15 09:40", size: size, status: "Processing Complete"),
            BuildInfo(id: start - 3, version: version, uploadedAt: "2024-05-10 16:30", size: size, status: "Processing Complete")
        ]
    }

    private static func screenshots(appID: String, warningSlot: Int?) -> [ScreenshotDevice: [ScreenshotItem]] {
        Dictionary(uniqueKeysWithValues: ScreenshotDevice.allCases.map { device in
            let items = (1...5).map { slot in
                ScreenshotItem(
                    id: "\(appID)-\(device.id)-\(slot)",
                    device: device,
                    slot: slot,
                    title: slotTitle(slot),
                    subtitle: slotSubtitle(slot),
                    hasWarning: warningSlot == slot,
                    styleIndex: slot
                )
            }
            return (device, items)
        })
    }

    private static func slotTitle(_ slot: Int) -> String {
        ["AI 智能", "专业级", "光斑效果", "智能识别", "多种滤镜"][max(0, min(slot - 1, 4))]
    }

    private static func slotSubtitle(_ slot: Int) -> String {
        ["人像美化", "模糊效果", "一键展示", "精准分割", "风格融合"][max(0, min(slot - 1, 4))]
    }

    private static func warning(for module: ReleaseModule) -> String {
        switch module {
        case .build: "需要上传可用构建版本"
        case .metadata: "元数据仍有字段需要优化"
        case .screenshots: "截图数量或质量未满足提交要求"
        case .reviewInfo: "审核备注缺失"
        case .privacy: "隐私合规信息未完成"
        case .release: "仍有检查项未完成"
        }
    }

    private static func issues(incomplete: Set<ReleaseModule>, suggestions: [SuggestionItem]) -> [CopilotIssue] {
        var issues: [CopilotIssue] = incomplete.map { module in
            let title: String
            switch module {
            case .screenshots: title = "缺少或需替换截图"
            case .reviewInfo: title = "缺少审核备注信息"
            case .metadata: title = "元数据需要补充"
            case .privacy: title = "隐私合规信息待确认"
            case .build: title = "Build 状态未完成"
            case .release: title = "发布提交尚未就绪"
            }
            return CopilotIssue(title: title, severity: module == .privacy || module == .reviewInfo ? "高影响" : "中影响", colorName: module == .privacy || module == .reviewInfo ? "red" : "orange")
        }
        issues += suggestions.prefix(2).map { suggestion in
            CopilotIssue(title: suggestion.title, severity: suggestion.impact, colorName: suggestion.impact == "高影响" ? "red" : "orange")
        }
        return issues
    }
}
