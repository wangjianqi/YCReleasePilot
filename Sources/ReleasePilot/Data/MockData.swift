import SwiftUI

enum MockData {
    static let releases: [AppReleaseMock] = [
        appRelease(
            id: "faceblur",
            name: "FaceBlur",
            version: "2.1.0",
            build: 47,
            symbol: "person.crop.square.fill",
            gradient: [Color(hex: 0xF6C7A7), Theme.ColorToken.purple],
            baseReadiness: 92,
            passRate: 87,
            reviewHours: "24 – 48",
            aiScore: 85,
            status: "Ready for Review",
            keywords: ["AI", "portrait", "blur", "photo", "beauty", "blur"],
            incompleteByPlatform: [.iOS: [.screenshots, .reviewInfo], .iPadOS: [.screenshots, .reviewInfo], .macOS: [.reviewInfo]]
        ),
        appRelease(
            id: "snapedit",
            name: "SnapEdit",
            version: "1.8.3",
            build: 36,
            symbol: "camera.aperture",
            gradient: [Color(hex: 0x10B981), Color(hex: 0x22D3EE)],
            baseReadiness: 78,
            passRate: 76,
            reviewHours: "36 – 60",
            aiScore: 78,
            status: "Metadata Draft",
            keywords: ["camera", "retouch", "filter", "photo", "editor", "camera"],
            incompleteByPlatform: [.iOS: [.metadata, .screenshots, .reviewInfo], .iPadOS: [.metadata, .screenshots], .macOS: [.metadata, .reviewInfo]]
        ),
        appRelease(
            id: "videomagic",
            name: "VideoMagic",
            version: "3.2.1",
            build: 105,
            symbol: "play.rectangle.fill",
            gradient: [Color(hex: 0xFDE047), Color(hex: 0x7C3AED)],
            baseReadiness: 84,
            passRate: 81,
            reviewHours: "24 – 72",
            aiScore: 80,
            status: "Ready for Review",
            keywords: ["video", "template", "cut", "caption", "reels", "video"],
            incompleteByPlatform: [.iOS: [.screenshots], .iPadOS: [.screenshots], .macOS: []]
        ),
        appRelease(
            id: "tuneflow",
            name: "TuneFlow",
            version: "1.4.0",
            build: 23,
            symbol: "music.note.list",
            gradient: [Color(hex: 0x14B8A6), Color(hex: 0x0EA5E9)],
            baseReadiness: 68,
            passRate: 69,
            reviewHours: "48 – 72",
            aiScore: 73,
            status: "Needs Work",
            keywords: ["music", "playlist", "timer", "mix", "flow", "playlist"],
            incompleteByPlatform: [.iOS: [.metadata, .screenshots, .reviewInfo, .privacy], .iPadOS: [.metadata, .screenshots, .privacy], .macOS: [.metadata, .privacy]]
        ),
        appRelease(
            id: "chatlens",
            name: "ChatLens",
            version: "2.0.0",
            build: 51,
            symbol: "bubble.left.and.bubble.right.fill",
            gradient: [Color(hex: 0x6366F1), Color(hex: 0x8B5CF6)],
            baseReadiness: 88,
            passRate: 84,
            reviewHours: "24 – 48",
            aiScore: 82,
            status: "Ready for Review",
            keywords: ["chat", "ai", "summary", "insight", "reader", "ai"],
            incompleteByPlatform: [.iOS: [.reviewInfo], .iPadOS: [.screenshots, .reviewInfo], .macOS: [.reviewInfo]]
        )
    ]

    static var apps: [AppItem] {
        releases.map(\.app)
    }

    static var releaseMap: [String: AppReleaseMock] {
        Dictionary(uniqueKeysWithValues: releases.map { ($0.app.id, $0) })
    }

    static let copilotSuggestions: [CopilotSuggestion] = [
        CopilotSuggestion(
            title: "缺少 iPad 截图",
            risk: .medium,
            module: .screenshots,
            reason: "当前版本支持 iPad，但截图资源未完整上传",
            actionTitle: "前往截图管理"
        ),
        CopilotSuggestion(
            title: "审核备注为空",
            risk: .medium,
            module: .reviewInfo,
            reason: "本次版本新增了 AI 相关功能，建议提供清晰说明",
            actionTitle: "生成审核备注"
        ),
        CopilotSuggestion(
            title: "副标题未充分利用",
            risk: .low,
            module: .metadata,
            reason: "副标题还有 12 个字符空间，可加入核心关键词",
            actionTitle: "优化副标题"
        ),
        CopilotSuggestion(
            title: "关键词重复率较高",
            risk: .low,
            module: .aso,
            reason: "关键词中存在重复词，可能浪费字符空间",
            actionTitle: "优化关键词"
        )
    ]

    static let settingsSections: [SettingsSection] = [
        SettingsSection(id: "account", title: "账号", rows: [
            SettingsRow(id: "team", title: "当前团队", value: "ReleasePilot Team", symbol: "person.2.fill", isEnabled: true),
            SettingsRow(id: "plan", title: "会员状态", value: "Pro Plan Mock", symbol: "diamond.fill", isEnabled: true)
        ]),
        SettingsSection(id: "api", title: "API Key", rows: [
            SettingsRow(id: "openai", title: "OpenAI API Key", value: "未配置", symbol: "key.fill", isEnabled: false),
            SettingsRow(id: "claude", title: "Claude API Key", value: "未配置", symbol: "key.horizontal.fill", isEnabled: false),
            SettingsRow(id: "gemini", title: "Gemini API Key", value: "未配置", symbol: "sparkles", isEnabled: false)
        ]),
        SettingsSection(id: "models", title: "模型配置", rows: [
            SettingsRow(id: "default-model", title: "默认模型", value: "GPT-4o Mock", symbol: "brain.head.profile", isEnabled: true),
            SettingsRow(id: "fallback-model", title: "备用模型", value: "Claude Sonnet Mock", symbol: "arrow.triangle.branch", isEnabled: true),
            SettingsRow(id: "local-cache", title: "本地缓存分析结果", value: "开启", symbol: "internaldrive.fill", isEnabled: true)
        ]),
        SettingsSection(id: "asc", title: "App Store Connect", rows: [
            SettingsRow(id: "issuer", title: "Issuer ID", value: "Mock Issuer", symbol: "building.2.fill", isEnabled: true),
            SettingsRow(id: "keyid", title: "Key ID", value: "ABC123MOCK", symbol: "signature", isEnabled: true),
            SettingsRow(id: "sync", title: "自动同步", value: "关闭", symbol: "arrow.triangle.2.circlepath", isEnabled: false)
        ]),
        SettingsSection(id: "notify", title: "通知设置", rows: [
            SettingsRow(id: "mail", title: "邮件通知", value: "开启", symbol: "envelope.fill", isEnabled: true),
            SettingsRow(id: "slack", title: "Slack Webhook", value: "未配置", symbol: "message.fill", isEnabled: false)
        ])
    ]

    static func initialCopilotMessages(for release: AppReleaseMock, platform: Platform) -> [CopilotMessage] {
        let data = release.data(for: platform)
        return [
            CopilotMessage(
                role: .assistant,
                title: "我已分析 \(release.app.name) v\(release.app.version) 的 \(platform.rawValue) 发布状态，发现以下问题和优化建议：",
                body: "需要我帮你优化这些内容吗？",
                issues: data.copilotIssues
            ),
            CopilotMessage(role: .user, body: AppStrings.userPrompt),
            CopilotMessage(
                role: .assistant,
                title: "已为你生成审核备注：",
                body: reviewNote(for: release, platform: platform),
                showsReviewNoteActions: true
            )
        ]
    }

    static func reviewNote(for release: AppReleaseMock, platform: Platform) -> String {
        let data = release.data(for: platform)
        return "感谢审核团队的辛勤工作！\(release.app.name) \(release.app.version) \(platform.rawValue) 版本是一款面向桌面和移动端用户的效率应用。\n\n本次版本重点更新：\(data.metadata.releaseNotes)\n\n应用内功能均符合 App Store 规范，不包含虚假宣传或违规内容。需要访问的权限仅用于核心功能，用户数据默认在本地处理。"
    }

    private static func appRelease(
        id: String,
        name: String,
        version: String,
        build: Int,
        symbol: String,
        gradient: [Color],
        baseReadiness: Int,
        passRate: Int,
        reviewHours: String,
        aiScore: Int,
        status: String,
        keywords: [String],
        incompleteByPlatform: [Platform: Set<ReleaseModule>]
    ) -> AppReleaseMock {
        let app = AppItem(id: id, name: name, version: version, buildNumber: build, iconSymbol: symbol, iconGradient: gradient, readiness: baseReadiness, passRate: passRate, reviewHours: reviewHours, aiScore: aiScore, status: status)
        let platformData = Dictionary(uniqueKeysWithValues: Platform.allCases.map { platform in
            let incomplete = incompleteByPlatform[platform] ?? []
            return (
                platform,
                PlatformReleaseMock(
                    metadata: metadata(name: name, platform: platform, keywords: keywords),
                    builds: builds(appID: id, name: name, start: build + platformOffset(platform), version: version, size: size(for: platform)),
                    screenshotsByDevice: screenshots(appID: id, platform: platform, incomplete: incomplete),
                    suggestions: suggestions(name: name, incomplete: incomplete),
                    releaseChecks: ReleaseModule.allCases.map { module in
                        ReleaseCheck(id: module, isComplete: !incomplete.contains(module) && module != .release, warning: warning(for: module))
                    },
                    copilotIssues: issues(incomplete: incomplete, suggestions: suggestions(name: name, incomplete: incomplete)),
                    releasePlan: ReleasePlan(releaseMode: .manualAfterApproval, timing: .immediate, scheduledAt: Date().addingTimeInterval(86400), releaseNotes: "发布后逐步放量，监控审核状态。", notifyTeam: true, monitorReview: true)
                )
            )
        })
        return AppReleaseMock(app: app, platformData: platformData, history: history(app: app))
    }

    private static func metadata(name: String, platform: Platform, keywords: [String]) -> AppMetadata {
        AppMetadata(
            subtitle: "\(platform.rawValue) release workspace",
            keywords: keywords,
            description: "\(name) helps creators prepare release assets and metadata for \(platform.rawValue).",
            releaseNotes: "Improved \(platform.rawValue) release readiness checks and screenshot workflow.",
            reviewNote: ""
        )
    }

    private static func builds(appID: String, name: String, start: Int, version: String, size: String) -> [BuildInfo] {
        (0..<10).map { index in
            BuildInfo(
                id: start - index,
                version: index < 3 ? version : "2.\(max(0, 1 - index / 2)).\(max(0, 9 - index))",
                uploadedAt: "2024-05-\(String(format: "%02d", max(1, 20 - index * 2))) \(index % 2 == 0 ? "14:35" : "11:20")",
                size: size,
                status: index == 0 ? "Processing Complete" : "Ready",
                bundleID: "com.releasepilot.\(appID)",
                testFlightStatus: index == 0 ? "Ready to Test" : "Expired",
                validationResults: ["Info.plist 校验通过", "签名校验通过", "隐私清单已检查", "架构切片完整"],
                uploadLogs: [
                    "[10:21:04] Preparing \(name) build \(start - index)",
                    "[10:21:18] Uploading archive to App Store Connect",
                    "[10:22:05] Processing symbols and privacy manifest",
                    "[10:24:42] Build processing complete"
                ],
                submissionStatus: index == 0 ? "Current" : (index % 3 == 0 ? "Submitted" : "Archived")
            )
        }
    }

    private static func screenshots(appID: String, platform: Platform, incomplete: Set<ReleaseModule>) -> [ScreenshotDevice: [ScreenshotItem]] {
        Dictionary(uniqueKeysWithValues: ScreenshotDevice.allCases.map { device in
            let count = screenshotCount(platform: platform, device: device, incomplete: incomplete)
            let items = count > 0 ? (1...count).map { slot in
                ScreenshotItem(
                    id: "\(appID)-\(platform.id)-\(device.id)-\(slot)",
                    device: device,
                    slot: slot,
                    title: slotTitle(slot),
                    subtitle: slotSubtitle(slot),
                    hasWarning: incomplete.contains(.screenshots) && slot == min(3, max(1, count)),
                    styleIndex: slot
                )
            } : []
            return (device, items)
        })
    }

    private static func screenshotCount(platform: Platform, device: ScreenshotDevice, incomplete: Set<ReleaseModule>) -> Int {
        if incomplete.contains(.screenshots) {
            if device == .iPad109 || device == .iPadPro { return 0 }
            return device == .mac ? 2 : 3
        }
        switch (platform, device) {
        case (.macOS, .mac): return 5
        case (.iPadOS, .iPadPro), (.iPadOS, .iPad109): return 4
        case (_, .iPhone69), (_, .iPhone65): return 5
        default: return 3
        }
    }

    private static func suggestions(name: String, incomplete: Set<ReleaseModule>) -> [SuggestionItem] {
        var values = [
            SuggestionItem(title: "\(name) 关键词重复率较高", impact: "中影响", tint: Theme.ColorToken.orange),
            SuggestionItem(title: "副标题利用率只有 60%", impact: "中影响", tint: Theme.ColorToken.orange),
            SuggestionItem(title: "第 3 张截图文案区域过大", impact: "低影响", tint: Theme.ColorToken.green)
        ]
        if incomplete.contains(.privacy) {
            values.insert(SuggestionItem(title: "隐私合规说明缺少权限用途", impact: "高影响", tint: Theme.ColorToken.red), at: 0)
        }
        return values
    }

    private static func history(app: AppItem) -> [ReleaseHistoryItem] {
        (0..<12).map { index in
            ReleaseHistoryItem(
                id: "\(app.id)-history-\(index)",
                appName: app.name,
                platform: Platform.allCases[index % Platform.allCases.count],
                version: index == 0 ? app.version : "2.\(max(0, 1 - index / 3)).\(max(0, 9 - index))",
                build: app.buildNumber - index,
                status: ["Ready for Review", "Approved", "Rejected", "Released"][index % 4],
                submittedAt: "2024-05-\(String(format: "%02d", max(1, 25 - index)))"
            )
        }
    }

    private static func issues(incomplete: Set<ReleaseModule>, suggestions: [SuggestionItem]) -> [CopilotIssue] {
        var issues: [CopilotIssue] = incomplete.map { module in
            let isHigh = module == .privacy || module == .reviewInfo
            return CopilotIssue(title: warning(for: module), severity: isHigh ? "高影响" : "中影响", colorName: isHigh ? "red" : "orange")
        }
        issues += suggestions.prefix(2).map { suggestion in
            CopilotIssue(title: suggestion.title, severity: suggestion.impact, colorName: suggestion.impact == "高影响" ? "red" : "orange")
        }
        return issues
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

    private static func slotTitle(_ slot: Int) -> String {
        ["AI 智能", "专业级", "光斑效果", "智能识别", "多种滤镜", "全新体验"][max(0, min(slot - 1, 5))]
    }

    private static func slotSubtitle(_ slot: Int) -> String {
        ["人像美化", "模糊效果", "一键展示", "精准分割", "风格融合", "发布就绪"][max(0, min(slot - 1, 5))]
    }

    private static func platformOffset(_ platform: Platform) -> Int {
        switch platform {
        case .iOS: 0
        case .iPadOS: 100
        case .macOS: 200
        }
    }

    private static func size(for platform: Platform) -> String {
        switch platform {
        case .iOS: "38.4 MB"
        case .iPadOS: "44.8 MB"
        case .macOS: "128.6 MB"
        }
    }
}
