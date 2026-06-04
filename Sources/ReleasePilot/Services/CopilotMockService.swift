import Foundation

struct CopilotMockService {
    func response(for prompt: String, appName: String, platform: Platform) -> CopilotMessage {
        let normalized = prompt.lowercased()
        if prompt.contains("审核备注") {
            return CopilotMessage(role: .assistant, title: "审核备注草稿", body: "\(appName) \(platform.rawValue) 本次版本重点优化发布流程、截图完整性与 AI 辅助能力。建议在审核备注中说明 AI 功能仅用于本地内容分析，用户 API Key 不会上传服务器。", showsReviewNoteActions: true)
        }
        if prompt.contains("副标题") {
            return CopilotMessage(role: .assistant, title: "副标题优化建议", body: "建议副标题突出核心价值，例如：Release checklist & AI review。这样能同时覆盖发布管理和 AI 审核语义，并减少泛词占用。")
        }
        if prompt.contains("关键词") || normalized.contains("keyword") {
            return CopilotMessage(role: .assistant, title: "关键词优化建议", body: "建议先去重，再把高意图词放到前半段：release, app store, metadata, screenshot, review, aso。避免重复的 app、ai 等低区分度词浪费字符空间。")
        }
        if prompt.contains("翻译") || normalized.contains("translate") {
            return CopilotMessage(role: .assistant, title: "新增内容翻译", body: "英文建议：Improved release readiness checks, screenshot validation, and AI-assisted review notes for App Store submissions.")
        }
        if prompt.contains("风险") || normalized.contains("risk") {
            return CopilotMessage(role: .assistant, title: "审核风险简析", body: "\(appName) 当前主要风险集中在截图完整性、审核备注说明和隐私描述一致性。建议先补齐 iPad 截图，再说明 AI 功能的数据处理边界。", issues: [
                CopilotIssue(title: "审核备注为空时可能增加沟通成本", severity: "中", colorName: "orange"),
                CopilotIssue(title: "iPad 截图缺失会影响提交完整度", severity: "中", colorName: "orange")
            ])
        }
        return CopilotMessage(role: .assistant, title: "模拟 AI 回复", body: "我已收到：\(prompt)\n\n基于 \(appName) \(platform.rawValue) 的当前发布状态，建议优先处理截图、审核备注和关键词去重。")
    }
}
