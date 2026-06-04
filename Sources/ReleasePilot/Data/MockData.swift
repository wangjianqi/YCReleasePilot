import SwiftUI

enum MockData {
    static let apps: [AppItem] = [
        AppItem(id: UUID(), name: "FaceBlur", version: "2.1.0", buildNumber: 47, iconSymbol: "person.crop.square.fill", iconGradient: [Color(hex: 0xF6C7A7), Theme.ColorToken.purple], readiness: 92, passRate: 87, reviewHours: "24 – 48", aiScore: 85, status: "Ready for Review"),
        AppItem(id: UUID(), name: "SnapEdit", version: "1.8.3", buildNumber: 36, iconSymbol: "camera.aperture", iconGradient: [Color(hex: 0x10B981), Color(hex: 0x22D3EE)], readiness: 78, passRate: 76, reviewHours: "36 – 60", aiScore: 78, status: "Metadata Draft"),
        AppItem(id: UUID(), name: "VideoMagic", version: "3.2.1", buildNumber: 105, iconSymbol: "play.rectangle.fill", iconGradient: [Color(hex: 0xFDE047), Color(hex: 0x7C3AED)], readiness: 84, passRate: 81, reviewHours: "24 – 72", aiScore: 80, status: "Ready for Review"),
        AppItem(id: UUID(), name: "TuneFlow", version: "1.4.0", buildNumber: 23, iconSymbol: "music.note.list", iconGradient: [Color(hex: 0x14B8A6), Color(hex: 0x0EA5E9)], readiness: 68, passRate: 69, reviewHours: "48 – 72", aiScore: 73, status: "Needs Work"),
        AppItem(id: UUID(), name: "ChatLens", version: "2.0.0", buildNumber: 51, iconSymbol: "bubble.left.and.bubble.right.fill", iconGradient: [Color(hex: 0x6366F1), Color(hex: 0x8B5CF6)], readiness: 88, passRate: 84, reviewHours: "24 – 48", aiScore: 82, status: "Ready for Review")
    ]

    static let builds: [BuildInfo] = [
        BuildInfo(id: 47, version: "2.1.0", uploadedAt: "2024-05-20 14:35", size: "38.4 MB", status: "Processing Complete"),
        BuildInfo(id: 46, version: "2.0.9", uploadedAt: "2024-05-18 11:20", size: "38.1 MB", status: "Processing Complete"),
        BuildInfo(id: 45, version: "2.0.8", uploadedAt: "2024-05-15 09:40", size: "37.8 MB", status: "Processing Complete"),
        BuildInfo(id: 44, version: "2.0.7", uploadedAt: "2024-05-10 16:30", size: "37.6 MB", status: "Processing Complete")
    ]

    static let screenshots: [ScreenshotItem] = [
        ScreenshotItem(id: 1, title: "AI 智能", subtitle: "人像美化", hasWarning: false),
        ScreenshotItem(id: 2, title: "专业级", subtitle: "模糊效果", hasWarning: false),
        ScreenshotItem(id: 3, title: "光斑效果", subtitle: "一键展示", hasWarning: true),
        ScreenshotItem(id: 4, title: "智能识别", subtitle: "精准分割", hasWarning: false),
        ScreenshotItem(id: 5, title: "多种滤镜", subtitle: "风格融合", hasWarning: false)
    ]

    static func completionItems(reviewNoteApplied: Bool) -> [CompletionItem] {
        [
            CompletionItem(title: "元数据", percent: 95, tint: Theme.ColorToken.green),
            CompletionItem(title: "截图", percent: 80, tint: Theme.ColorToken.orange),
            CompletionItem(title: "审核信息", percent: reviewNoteApplied ? 100 : 70, tint: reviewNoteApplied ? Theme.ColorToken.green : Theme.ColorToken.orange),
            CompletionItem(title: "隐私合规", percent: 100, tint: Theme.ColorToken.green),
            CompletionItem(title: "本地化", percent: 85, tint: Theme.ColorToken.green)
        ]
    }

    static func releaseSteps(reviewNoteApplied: Bool) -> [ReleaseStep] {
        [
            ReleaseStep(title: "Build", subtitle: "构建版本", state: .done),
            ReleaseStep(title: "Metadata", subtitle: "元数据", state: .done),
            ReleaseStep(title: "Screenshots", subtitle: "截图管理", state: .warning),
            ReleaseStep(title: "Review Info", subtitle: "审核信息", state: reviewNoteApplied ? .done : .warning),
            ReleaseStep(title: "Privacy", subtitle: "隐私合规", state: .done),
            ReleaseStep(title: "Release", subtitle: "发布提交", state: .pending)
        ]
    }

    static func todoItems(reviewNoteApplied: Bool) -> [TodoItem] {
        var items = [
            TodoItem(title: "缺少 iPad 截图", subtitle: "iPad Pro 12.9\" 需要至少 1 张截图", symbol: "rectangle.stack.badge.plus", actionTitle: "去处理", severity: .high)
        ]
        if !reviewNoteApplied {
            items.append(TodoItem(title: "缺少审核备注", subtitle: "App Review 团队需要审核信息", symbol: "sparkles", actionTitle: "AI 生成", severity: .high))
        }
        return items
    }

    static let suggestions: [SuggestionItem] = [
        SuggestionItem(title: "第 3 张截图文案区域过大", impact: "低影响", tint: Theme.ColorToken.green),
        SuggestionItem(title: "关键词重复率较高", impact: "中影响", tint: Theme.ColorToken.orange),
        SuggestionItem(title: "副标题利用率只有 60%", impact: "中影响", tint: Theme.ColorToken.orange)
    ]

    static let initialCopilotMessages: [CopilotMessage] = [
        CopilotMessage(
            role: .assistant,
            title: "我已分析 FaceBlur v2.1.0 的发布状态，发现以下问题和优化建议：",
            body: "需要我帮你优化这些内容吗？",
            issues: [
                CopilotIssue(title: "缺少 iPad 截图", severity: "高影响", colorName: "red"),
                CopilotIssue(title: "缺少审核备注信息", severity: "高影响", colorName: "orange"),
                CopilotIssue(title: "关键词重复率较高", severity: "中影响", colorName: "orange"),
                CopilotIssue(title: "副标题利用率只有 60%", severity: "中影响", colorName: "orange")
            ]
        ),
        CopilotMessage(role: .user, body: AppStrings.userPrompt),
        CopilotMessage(
            role: .assistant,
            title: "已为你生成审核备注：",
            body: "感谢审核团队的辛勤工作！FaceBlur 是一款 AI 驱动的照片美化应用，提供专业级人像模糊、光斑效果和智能背景处理功能。\n\n应用内所有功能均符合 App Store 规范，不包含任何虚假宣传、违规内容或隐私数据采集。用户数据均在本地处理。",
            showsReviewNoteActions: true
        )
    ]
}
