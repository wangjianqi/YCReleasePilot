# 贡献指南

感谢你对 ReleasePilot 的关注！我们欢迎所有形式的贡献，包括但不限于 Bug 报告、功能建议、文档改进和代码贡献。

## 目录

- [行为准则](#行为准则)
- [如何贡献](#如何贡献)
- [开发环境设置](#开发环境设置)
- [代码规范](#代码规范)
- [提交规范](#提交规范)
- [Pull Request 流程](#pull-request-流程)
- [问题报告](#问题报告)

## 行为准则

本项目采用 [贡献者公约](CODE_OF_CONDUCT.md) 作为行为准则。参与本项目即表示你同意遵守其条款。

## 如何贡献

### 报告 Bug

如果你发现了 Bug，请 [创建 Issue](../../issues/new) 并包含以下信息：

- **Bug 描述**：清晰描述问题
- **复现步骤**：如何复现该问题
- **预期行为**：你期望发生什么
- **实际行为**：实际发生了什么
- **环境信息**：macOS 版本、Xcode 版本
- **截图**：如果适用，添加截图帮助说明

### 建议功能

功能建议同样通过 [创建 Issue](../../issues/new) 提交，请包含：

- **功能描述**：你希望实现的功能
- **使用场景**：为什么需要这个功能
- **期望效果**：功能应该如何工作

### 贡献代码

1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/amazing-feature`)
3. 编写代码并确保通过编译
4. 提交更改（遵循[提交规范](#提交规范)）
5. 推送到分支 (`git push origin feature/amazing-feature`)
6. 创建 Pull Request

## 开发环境设置

### 前置要求

- macOS 14.0 (Sonoma) 或更高版本
- Xcode 15.0 或更高版本
- Swift 5.9

### 构建项目

```bash
# 克隆你的 Fork
git clone https://github.com/your-username/YCReleasePilot.git
cd YCReleasePilot

# 构建并运行
./script/build_and_run.sh
```

### 项目结构

请参考 [README.md](README.md) 中的项目架构部分了解代码组织方式。

## 代码规范

### Swift 风格

- 遵循 [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- 使用 4 个空格缩进
- 文件末尾保留一个空行
- 类型名称使用 `UpperCamelCase`，函数和变量使用 `lowerCamelCase`
- 缩写词在命名中保持统一大小写（如 `URL`、`ID`）

### 项目特定规范

- **零外部依赖** — 仅使用 Apple 原生框架，不要引入第三方库
- **设计令牌** — 颜色使用 `Theme.ColorToken`，圆角使用 `Theme.Radius`，间距使用 `Theme.Spacing`，不要在代码中硬编码
- **字符串常量** — UI 文本统一在 `AppStrings.swift` 中定义
- **共享组件** — 优先复用 `Views/Shared/` 下的组件（GlassCard、PrimaryButton、StatusBadge 等）
- **状态管理** — 使用 Swift Observation 框架的 `@Observable` 宏，不使用 Combine 的 `@Published`
- **深色主题** — UI 强制深色模式，确保所有新增 UI 在深色背景下表现良好

### 文件组织

- 模型放在 `Models/` 目录，使用值类型（struct/enum）
- 服务放在 `Services/` 目录
- 视图模型放在 `ViewModels/` 目录
- 视图按功能模块放在 `Views/` 的子目录中
- 可复用组件放在 `Views/Shared/` 目录

## 提交规范

我们使用 [Conventional Commits](https://www.conventionalcommits.org/) 规范：

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Type 类型

| 类型 | 说明 |
|------|------|
| `feat` | 新功能 |
| `fix` | Bug 修复 |
| `docs` | 文档变更 |
| `style` | 代码格式（不影响功能） |
| `refactor` | 代码重构 |
| `perf` | 性能优化 |
| `test` | 测试相关 |
| `chore` | 构建/工具变更 |

### 示例

```
feat(copilot): add keyword optimization suggestion
fix(sidebar): resolve app selection state sync issue
docs: update README with architecture diagram
refactor(dashboard): extract metric card into shared component
```

## Pull Request 流程

1. **确保构建通过** — 运行 `swift build` 确认无编译错误
2. **描述清晰** — PR 描述中说明改动内容和原因
3. **关联 Issue** — 如果 PR 解决了某个 Issue，请在描述中引用（如 `Closes #123`）
4. **小而专注** — 每个 PR 只做一件事，便于审查
5. **代码审查** — 维护者会审查你的代码，可能会提出修改建议

### PR 标题格式

与提交规范一致：`<type>(<scope>): <description>`

## 问题报告

如果你有任何问题，可以：

- [创建 Issue](../../issues/new)
- 在 [Discussions](../../discussions) 中发起讨论

---

再次感谢你的贡献！每一个 PR、Issue 和建议都让 ReleasePilot 变得更好。
