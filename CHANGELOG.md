# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-06-05

### Added

- 发布仪表盘：发布准备度、审核风险、AI 评分可视化
- 多平台支持：iOS、iPadOS、macOS 三平台发布状态管理
- 构建版本管理：构建历史、TestFlight 状态、验证结果查看
- 截图管理：按设备类型管理截图，支持本地导入和替换
- AI Copilot 面板：智能助手对话、审核备注生成、关键词优化建议
- 发布流程检查清单：元数据、截图、审核信息、隐私合规、发布提交
- App Store Connect 集成框架：API 服务、配置管理、快照缓存
- 接口调试面板：API 请求监控、重复调用检测、风控风险评估
- 设置页面：通用设置、AI 提供商配置、ASC 配置、会员管理、隐私安全
- 深色毛玻璃 UI 主题：玻璃拟态风格，深海军蓝背景，蓝紫渐变强调色
- 侧边栏：应用列表、导航菜单、账号信息
- 弹窗系统：构建详情、版本历史、发布计划
- 应用添加功能：支持手动添加新 App
- Toast 通知系统
- Mock 数据层：5 个示例 App 的完整发布数据

### Technical

- Swift 5.9 + SwiftUI + AppKit
- Swift Observation 框架（`@Observable`）
- Swift Package Manager 项目结构
- 零外部依赖
- MVVM 架构
