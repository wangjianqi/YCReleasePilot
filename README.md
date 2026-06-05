<div align="center">

# ReleasePilot

**App Store 发布管理桌面客户端**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![macOS 14+](https://img.shields.io/badge/platform-macOS%2014%2B-blue)](https://www.apple.com/macos)
[![Swift 5.9](https://img.shields.io/badge/Swift-5.9-orange)](https://swift.org)

[English](#features) | [中文](#功能特性)

</div>

---

ReleasePilot 是一款原生 macOS 桌面应用，专为 iOS/macOS 开发者打造，提供 App Store 发布流程的一站式管理。从元数据编辑、截图管理、构建版本追踪到审核提交，全部在一个界面内完成。

> **注意**：当前版本已接入 App Store Connect 的 App、版本、构建和截图读取；元数据/截图写回、提交审核、AI Copilot 真实 LLM、会员付费等能力仍在开发中。本地演示数据仅在未同步 ASC 或手动添加演示 App 时使用。

## 功能特性

- **发布仪表盘** — 一目了然查看所有 App 的发布准备度、审核风险、AI 评分
- **多平台支持** — 同时管理 iOS、iPadOS、macOS 三个平台的发布状态
- **构建版本管理** — 追踪构建历史、TestFlight 状态、验证结果
- **截图管理** — 按设备类型管理截图，支持本地导入、替换、预览
- **AI Copilot** — 智能助手帮你生成审核备注、优化关键词、分析发布风险
- **发布流程** — 可视化发布检查清单，确保每个步骤都已完成
- **App Store Connect** — 支持连接 ASC 账号同步真实 App、版本、构建和截图读取数据
- **接口调试面板** — 监控 API 请求，检测重复调用和风控风险
- **深色毛玻璃 UI** — 精心设计的深色主题，玻璃拟态风格

## 截图

> 截图待补充 — 欢迎提交 PR 添加应用截图

## 系统要求

- macOS 14.0 (Sonoma) 或更高版本
- Xcode 15.0 或更高版本
- Swift 5.9

## 快速开始

### 克隆项目

```bash
git clone https://github.com/your-username/YCReleasePilot.git
cd YCReleasePilot
```

### 构建并运行

```bash
# 方式一：使用构建脚本（推荐，自动打包为 .app）
./script/build_and_run.sh

# 方式二：仅构建
swift build

# 方式三：使用 Xcode 打开
# 通过 XcodeGen 生成 .xcodeproj 后用 Xcode 打开
xcodegen generate
open YCReleasePilot.xcodeproj
```

### 构建脚本选项

```bash
./script/build_and_run.sh              # 构建并运行
./script/build_and_run.sh --debug      # 构建并在 lldb 中调试
./script/build_and_run.sh --logs       # 构建并查看日志流
./script/build_and_run.sh --telemetry  # 构建并查看遥测数据
./script/build_and_run.sh --verify     # 构建并验证进程启动
```

## 项目架构

```
Sources/ReleasePilot/
├── ReleasePilotApp.swift          # 应用入口
├── Data/
│   └── MockData.swift             # 本地演示数据与 ASC 快照展示映射
├── Models/                        # 数据模型（值类型）
│   ├── AppItem.swift              # App 模型
│   ├── BuildInfo.swift            # 构建版本
│   ├── ScreenshotItem.swift       # 截图
│   ├── NavigationState.swift      # 导航状态
│   └── ...
├── Services/                      # 服务层
│   ├── AppStoreConnectAPIService.swift
│   ├── AIProviderService.swift
│   ├── KeychainService.swift
│   └── ...
├── ViewModels/                    # 视图模型
│   ├── ReleaseDashboardViewModel.swift  # 核心状态管理
│   ├── CopilotViewModel.swift
│   ├── SettingsViewModel.swift
│   └── ...
├── Views/                         # 视图层
│   ├── RootView.swift             # 根视图
│   ├── Dashboard/                 # 仪表盘
│   ├── Copilot/                   # AI 助手面板
│   ├── Sidebar/                   # 侧边栏
│   ├── Settings/                  # 设置页面
│   ├── Modals/                    # 弹窗
│   ├── Pages/                     # 页面视图
│   └── Shared/                    # 共享组件
└── Support/
    ├── Theme.swift                # 设计令牌（颜色、圆角、间距）
    └── AppStrings.swift           # UI 字符串常量
```

### 设计原则

- **MVVM 架构** — 使用 Swift Observation 框架（`@Observable`），状态集中在 ViewModel 管理
- **零外部依赖** — 仅使用 Apple 原生框架（SwiftUI、AppKit、Foundation、Observation）
- **设计令牌** — 所有颜色、圆角、间距统一在 `Theme.swift` 和 `AppStrings.swift` 中定义
- **共享组件** — `Views/Shared/` 下的 GlassCard、PrimaryButton、StatusBadge 等可复用组件

## 技术栈

| 技术 | 说明 |
|------|------|
| SwiftUI | 声明式 UI 框架 |
| AppKit | macOS 原生集成（NSOpenPanel、应用生命周期） |
| Swift Observation | `@Observable` 状态管理 |
| Swift Package Manager | 项目构建与依赖管理 |
| XcodeGen | 可选的 .xcodeproj 生成工具 |

## 路线图

- [ ] App Store Connect 写操作完整集成（元数据、截图、审核备注、提交审核）
- [ ] AI Copilot 接入真实 LLM（OpenAI / Claude / Gemini）
- [ ] 多语言本地化
- [ ] 截图自动裁剪与适配
- [ ] 审核状态实时推送通知
- [ ] 团队协作功能
- [ ] CI/CD 自动化发布

## 贡献

我们欢迎所有形式的贡献！请阅读 [贡献指南](CONTRIBUTING.md) 了解如何参与项目。

### 快速贡献

1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 创建 Pull Request

## 行为准则

本项目采用 [贡献者公约](CODE_OF_CONDUCT.md) 作为行为准则。参与本项目即表示你同意遵守其条款。

## 安全

如果你发现安全漏洞，请参阅 [安全策略](SECURITY.md) 了解报告方式。

## 许可证

本项目基于 [MIT License](LICENSE) 开源。

## 致谢

- 所有为这个项目做出贡献的开发者
- Apple SwiftUI 和 Swift 团队提供的优秀框架
