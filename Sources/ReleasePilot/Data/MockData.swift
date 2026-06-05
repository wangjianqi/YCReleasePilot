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

    static func makeRelease(from draft: AppDraft, existingIDs: Set<String>) -> AppReleaseMock {
        var id = draft.sanitizedID
        var suffix = 2
        while existingIDs.contains(id) {
            id = "\(draft.sanitizedID)-\(suffix)"
            suffix += 1
        }
        let template = draft.statusTemplate
        let incomplete = Dictionary(uniqueKeysWithValues: Platform.allCases.map { platform in
            let modules = platform == draft.primaryPlatform ? template.incompleteModules : template.incompleteModules.union([.screenshots])
            return (platform, modules)
        })
        return appRelease(
            id: id,
            name: draft.name.trimmingCharacters(in: .whitespacesAndNewlines),
            version: draft.version.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "1.0.0" : draft.version,
            build: draft.parsedBuildNumber,
            symbol: draft.iconSymbol,
            gradient: [Theme.ColorToken.blue, Theme.ColorToken.purple],
            baseReadiness: template.readiness,
            passRate: max(58, template.readiness - 4),
            reviewHours: template == .needsWork ? "48 – 72" : "24 – 48",
            aiScore: max(60, template.readiness - 2),
            status: template.rawValue,
            keywords: ["release", "app", draft.name.lowercased(), "store", "aso", "release"],
            incompleteByPlatform: incomplete
        )
    }

    static func makeRelease(from snapshot: AppStoreConnectAppSnapshot) -> AppReleaseMock {
        let version = snapshot.latestVersion?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? snapshot.latestVersion! : "1.0.0"
        let buildNumber = snapshot.builds.first.flatMap { Int($0.version) } ?? 0
        let state = snapshot.appStoreState.map(readableState) ?? "Synced from ASC"
        let readiness = readiness(forASCState: snapshot.appStoreState)
        let app = AppItem(
            id: snapshot.id,
            name: snapshot.name,
            version: version,
            buildNumber: buildNumber,
            iconSymbol: iconSymbol(for: snapshot.bundleID),
            iconGradient: iconGradient(for: snapshot.id),
            iconImagePath: snapshot.iconImagePath,
            readiness: readiness,
            passRate: readiness >= 90 ? 88 : 74,
            reviewHours: "24 – 48",
            aiScore: max(68, readiness - 6),
            status: state
        )
        let platformData = Dictionary(uniqueKeysWithValues: Platform.allCases.map { platform in
            let incomplete: Set<ReleaseModule> = readiness >= 90 ? [.screenshots] : [.metadata, .screenshots, .reviewInfo]
            return (
                platform,
                PlatformReleaseMock(
                    metadata: AppMetadata(
                        subtitle: "\(snapshot.primaryLocale) · \(snapshot.bundleID)",
                        keywords: [snapshot.name.lowercased(), snapshot.sku.lowercased(), "app", "release", "store"],
                        description: "来自 App Store Connect 的真实 App：\(snapshot.name)。Bundle ID：\(snapshot.bundleID)。",
                        releaseNotes: "当前版本状态：\(state)。",
                        reviewNote: ""
                    ),
                    builds: builds(from: snapshot, app: app, platform: platform),
                    screenshotsByDevice: screenshots(from: snapshot, platform: platform, incomplete: incomplete),
                    suggestions: suggestions(name: snapshot.name, incomplete: incomplete),
                    releaseChecks: ReleaseModule.allCases.map { module in
                        ReleaseCheck(id: module, isComplete: !incomplete.contains(module) && module != .release, warning: warning(for: module))
                    },
                    copilotIssues: issues(incomplete: incomplete, suggestions: suggestions(name: snapshot.name, incomplete: incomplete)),
                    releasePlan: ReleasePlan(releaseMode: .manualAfterApproval, timing: .immediate, scheduledAt: Date().addingTimeInterval(86400), releaseNotes: "ASC 同步数据，仅本地预览发布计划。", notifyTeam: true, monitorReview: true)
                )
            )
        })
        return AppReleaseMock(app: app, platformData: platformData, history: history(from: snapshot, app: app))
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
            SettingsRow(id: "plan", title: "会员状态", value: "本地演示 Pro", symbol: "diamond.fill", isEnabled: true)
        ]),
        SettingsSection(id: "api", title: "API Key", rows: [
            SettingsRow(id: "openai", title: "OpenAI API Key", value: "未配置", symbol: "key.fill", isEnabled: false),
            SettingsRow(id: "claude", title: "Claude API Key", value: "未配置", symbol: "key.horizontal.fill", isEnabled: false),
            SettingsRow(id: "gemini", title: "Gemini API Key", value: "未配置", symbol: "sparkles", isEnabled: false)
        ]),
        SettingsSection(id: "models", title: "模型配置", rows: [
            SettingsRow(id: "default-model", title: "默认模型", value: "GPT-4o 演示配置", symbol: "brain.head.profile", isEnabled: true),
            SettingsRow(id: "fallback-model", title: "备用模型", value: "Claude Sonnet 演示配置", symbol: "arrow.triangle.branch", isEnabled: true),
            SettingsRow(id: "local-cache", title: "本地缓存分析结果", value: "开启", symbol: "internaldrive.fill", isEnabled: true)
        ]),
        SettingsSection(id: "asc", title: "App Store Connect", rows: [
            SettingsRow(id: "issuer", title: "Issuer ID", value: "前往 ASC 设置配置", symbol: "building.2.fill", isEnabled: true),
            SettingsRow(id: "keyid", title: "Key ID", value: "前往 ASC 设置配置", symbol: "signature", isEnabled: true),
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

    private static func builds(from snapshot: AppStoreConnectAppSnapshot, app: AppItem, platform: Platform) -> [BuildInfo] {
        snapshot.builds.enumerated().map { index, build in
            BuildInfo(
                id: Int(build.version) ?? stableNumericID(for: build.id, fallback: index + 1),
                buildNumber: build.version.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? build.id : build.version,
                version: app.version,
                uploadedAt: formattedASCDate(build.uploadedDate),
                size: "ASC 未返回",
                status: readableState(build.processingState),
                bundleID: snapshot.bundleID,
                testFlightStatus: "ASC 未返回",
                validationResults: ["App Store Connect 构建读取成功", "Bundle ID：\(snapshot.bundleID)", "Build ID：\(build.id)"],
                uploadLogs: [
                    "[ASC] App: \(snapshot.name)",
                    "[ASC] Build ID: \(build.id)",
                    "[ASC] Processing State: \(build.processingState)",
                    "[ASC] Uploaded: \(build.uploadedDate.isEmpty ? "Unknown" : build.uploadedDate)"
                ],
                submissionStatus: snapshot.appStoreState.map(readableState) ?? "Synced",
                dataSource: .appStoreConnect
            )
        }
    }

    private static func screenshots(appID: String, platform: Platform, incomplete: Set<ReleaseModule>) -> [ScreenshotDevice: [ScreenshotItem]] {
        var result: [ScreenshotDevice: [ScreenshotItem]] = [:]
        for device in ScreenshotDevice.allCases {
            let count = screenshotCount(platform: platform, device: device, incomplete: incomplete)
            guard count > 0 else {
                result[device] = []
                continue
            }
            var items: [ScreenshotItem] = []
            items.reserveCapacity(count)
            for slot in 1...count {
                items.append(ScreenshotItem(
                    id: "\(appID)-\(platform.id)-\(device.id)-\(slot)",
                    device: device,
                    slot: slot,
                    title: slotTitle(slot),
                    subtitle: slotSubtitle(slot),
                    hasWarning: incomplete.contains(.screenshots) && slot == min(3, max(1, count)),
                    styleIndex: slot
                ))
            }
            result[device] = items
        }
        return result
    }

    private static func screenshots(from snapshot: AppStoreConnectAppSnapshot, platform: Platform, incomplete: Set<ReleaseModule>) -> [ScreenshotDevice: [ScreenshotItem]] {
        var grouped: [ScreenshotDevice: [ScreenshotItem]] = [:]
        let primaryLocale = snapshot.primaryLocale
        let hasPrimaryLocaleScreenshots = snapshot.screenshots.contains { $0.locale == primaryLocale }
        let localizedScreenshots = snapshot.screenshots.filter { screenshot in
            hasPrimaryLocaleScreenshots ? screenshot.locale == primaryLocale : true
        }

        for screenshot in localizedScreenshots {
            guard let device = screenshotDevice(for: screenshot.displayType) else { continue }
            var items = grouped[device] ?? []
            let slot = items.count + 1
            items.append(
                ScreenshotItem(
                    id: screenshot.id,
                    device: device,
                    slot: slot,
                    title: screenshot.fileName,
                    subtitle: readableScreenshotDisplayType(screenshot.displayType),
                    hasWarning: screenshot.cachedImagePath == nil,
                    isPlaceholder: screenshot.cachedImagePath == nil,
                    styleIndex: slot,
                    localImagePath: screenshot.cachedImagePath
                )
            )
            grouped[device] = items
        }

        if grouped.values.flatMap({ $0 }).isEmpty {
            return screenshots(appID: snapshot.id, platform: platform, incomplete: incomplete)
        }

        for device in ScreenshotDevice.allCases where grouped[device] == nil {
            grouped[device] = []
        }
        return grouped
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

    private static func screenshotDevice(for displayType: String) -> ScreenshotDevice? {
        let value = displayType.uppercased()
        if value.contains("IPHONE_69") || value.contains("6_9") || value.contains("67") || value.contains("6_7") {
            return .iPhone69
        }
        if value.contains("IPHONE") {
            return .iPhone65
        }
        if value.contains("IPAD_PRO") || value.contains("129") || value.contains("12_9") {
            return .iPadPro
        }
        if value.contains("IPAD") {
            return .iPad109
        }
        if value.contains("DESKTOP") || value.contains("MAC") {
            return .mac
        }
        return nil
    }

    private static func readableScreenshotDisplayType(_ displayType: String) -> String {
        screenshotDevice(for: displayType)?.rawValue ?? displayType.replacingOccurrences(of: "_", with: " ")
    }

    private static func readableState(_ value: String) -> String {
        value
            .split(separator: "_")
            .map { $0.prefix(1).uppercased() + $0.dropFirst().lowercased() }
            .joined(separator: " ")
    }

    private static func readiness(forASCState state: String?) -> Int {
        switch state {
        case "READY_FOR_SALE", "PENDING_APPLE_RELEASE", "PENDING_DEVELOPER_RELEASE":
            return 96
        case "READY_FOR_REVIEW", "WAITING_FOR_REVIEW", "IN_REVIEW":
            return 92
        case "PREPARE_FOR_SUBMISSION", "PROCESSING_FOR_APP_STORE":
            return 78
        case "REJECTED", "METADATA_REJECTED", "INVALID_BINARY":
            return 64
        default:
            return 82
        }
    }

    private static func formattedASCDate(_ value: String) -> String {
        guard !value.isEmpty else { return "Unknown" }
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: value) else { return value }
        return date.formatted(date: .numeric, time: .shortened)
    }

    private static func stableNumericID(for value: String, fallback: Int) -> Int {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if let intValue = Int(trimmed) {
            return intValue
        }
        let scalarSum = trimmed.unicodeScalars.reduce(0) { partial, scalar in
            partial &+ Int(scalar.value)
        }
        return max(scalarSum, fallback)
    }

    private static func platform(fromASCValue value: String) -> Platform {
        switch value {
        case "MAC_OS": .macOS
        case "IOS": .iOS
        default: .iOS
        }
    }

    private static func iconSymbol(for bundleID: String) -> String {
        if bundleID.localizedCaseInsensitiveContains("photo") || bundleID.localizedCaseInsensitiveContains("image") {
            return "photo.fill"
        }
        if bundleID.localizedCaseInsensitiveContains("video") {
            return "play.rectangle.fill"
        }
        if bundleID.localizedCaseInsensitiveContains("music") || bundleID.localizedCaseInsensitiveContains("audio") {
            return "music.note.list"
        }
        return "app.fill"
    }

    private static func iconGradient(for id: String) -> [Color] {
        let palettes: [[Color]] = [
            [Theme.ColorToken.blue, Theme.ColorToken.purple],
            [Theme.ColorToken.green, Theme.ColorToken.cyan],
            [Theme.ColorToken.orange, Theme.ColorToken.purple],
            [Color(hex: 0xF6C7A7), Theme.ColorToken.purple]
        ]
        return palettes[abs(id.hashValue) % palettes.count]
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

    private static func history(from snapshot: AppStoreConnectAppSnapshot, app: AppItem) -> [ReleaseHistoryItem] {
        snapshot.appStoreVersions.enumerated().map { index, version in
            ReleaseHistoryItem(
                id: "\(snapshot.id)-version-\(version.id)",
                appName: snapshot.name,
                platform: platform(fromASCValue: version.platform),
                version: version.versionString,
                build: matchingBuildNumber(for: version.versionString, in: snapshot.builds) ?? app.buildNumber,
                status: readableState(version.appStoreState),
                submittedAt: formattedASCDate(version.createdDate ?? ""),
                sortKey: version.createdDate ?? "\(String(format: "%05d", snapshot.appStoreVersions.count - index))-\(version.id)"
            )
        }
    }

    private static func matchingBuildNumber(for version: String, in builds: [AppStoreConnectBuildSnapshot]) -> Int? {
        builds.first { $0.version == version }.flatMap { Int($0.version) }
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
