# YCReleasePilot 未完成功能 Todo

## App Store Connect

- [ ] 元数据写回：将标题、副标题、关键词、描述、版本说明写回 App Store Connect。
- [ ] 截图写回：支持上传、替换、删除 ASC 截图，而不是只做本地导入/缓存。
- [ ] 审核备注写回：将生成或编辑后的审核备注写入 ASC review detail。
- [ ] 提交审核：把当前本地 `confirmSubmit()` 的模拟提交替换为真实 ASC 提交流程。
- [ ] 发布计划写回：将手动/自动发布、预约发布时间等发布计划同步到 ASC。
- [ ] 审核状态刷新：补齐更细粒度的审核状态、错误原因和状态变更提示。

## AI Provider 与 Copilot

- [ ] 真实 Keychain：用 macOS Keychain 持久化 AI Provider API Key，替换当前内存字典。
- [ ] 真实连通性测试：OpenAI、Claude、Gemini、DeepSeek 按各自 API 做真实 test connection。
- [ ] 真实 LLM 回复：用已配置 Provider 替换 `CopilotMockService`。
- [ ] 建议写回：让 Copilot 的审核备注、关键词、翻译、风险建议能写回对应发布字段。
- [ ] Suggestions 真实来源：从当前 App/平台/ASC 数据生成建议，而不是固定演示建议。

## 会员与商业化

- [ ] 接入真实 IAP 或 RevenueCat，替换 UserDefaults 状态切换。
- [ ] 恢复购买：实现真实 restore purchases。
- [ ] 权益校验：把 Pro/Lifetime 权益从本地状态切换改成真实订阅状态。

## 发布分析与自动化

- [ ] 准备度、审核风险、AI 评分改为基于真实字段和规则引擎计算。
- [ ] 截图自动裁剪与设备适配。
- [ ] 审核状态推送通知。
- [ ] 团队协作。
- [ ] CI/CD 自动化发布。

## 设置与账号

- [ ] 设置首页汇总项改为读取真实配置状态，而不是静态演示行。
- [ ] 账号菜单接入真实登录/退出状态。
- [ ] 隐私安全页展示实际本地存储、缓存和密钥状态。
