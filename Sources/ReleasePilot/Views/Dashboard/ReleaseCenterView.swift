import SwiftUI

struct ReleaseCenterView: View {
    @Bindable var viewModel: ReleaseDashboardViewModel
    var membershipViewModel: MembershipViewModel

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    header
                    metrics
                    ReleaseFlowView(steps: viewModel.releaseSteps)
                        .id(ReleaseModule.release)
                    topDashboardRow
                    bottomDashboardRow
                }
                .padding(18)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onChange(of: viewModel.focusedModule) { _, module in
                guard let module else { return }
                withAnimation(.easeInOut(duration: 0.25)) {
                    proxy.scrollTo(module, anchor: .center)
                }
            }
        }
        .background(surface)
        .onChange(of: viewModel.selectedPlatform) { _, platform in
            viewModel.selectPlatform(platform)
        }
    }

    private var surface: some View {
        LinearGradient(colors: [Color(hex: 0x0B1423).opacity(0.88), Color(hex: 0x07101D).opacity(0.9)], startPoint: .top, endPoint: .bottom)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.surface, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: Theme.Radius.surface, style: .continuous).stroke(Theme.ColorToken.line, lineWidth: 1))
    }

    private var header: some View {
        HStack {
            HStack(spacing: 12) {
                AppIconView(app: viewModel.selectedApp, size: 50)
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(viewModel.selectedApp.name)
                            .font(.system(size: 26, weight: .bold))
                        Image(systemName: "star")
                            .font(.caption)
                            .foregroundStyle(Theme.ColorToken.muted)
                    }
                    HStack(spacing: 10) {
                        PlatformBadge(platform: viewModel.selectedPlatform)
                        StatusBadge(title: viewModel.selectedVersionBuildText, tint: Theme.ColorToken.blue)
                        StatusBadge(title: viewModel.displayedStatus, tint: Theme.ColorToken.green)
                    }
                }
            }
            Spacer()
            SmallGlassButton(
                title: viewModel.isRefreshingAppStoreConnectStatus ? "更新中" : "更新状态",
                systemImage: viewModel.isRefreshingAppStoreConnectStatus ? "arrow.triangle.2.circlepath" : "arrow.clockwise",
                action: { viewModel.refreshAppStoreConnectStatus() }
            )
            .disabled(viewModel.isRefreshingAppStoreConnectStatus || viewModel.isSyncingAppStoreConnect)
            SmallGlassButton(
                title: viewModel.isSyncingAppStoreConnect ? "同步中" : "完整同步",
                systemImage: viewModel.isSyncingAppStoreConnect ? "arrow.triangle.2.circlepath" : "icloud.and.arrow.down",
                action: { viewModel.syncAppStoreConnect() }
            )
            .disabled(viewModel.isSyncingAppStoreConnect || viewModel.isRefreshingAppStoreConnectStatus)
            PlatformSegmentedControl(selection: $viewModel.selectedPlatform)
        }
    }

    private var metrics: some View {
        GlassCard(cornerRadius: 20, padding: 0) {
            HStack(alignment: .top, spacing: 0) {
                MetricCardView(title: AppStrings.readiness) {
                    CircularProgressView(percent: viewModel.displayedReadiness)
                        .frame(maxWidth: .infinity)
                    Text(viewModel.canSubmit ? "所有必需检查项已完成" : "还差 \(viewModel.blockingWarnings.count) 项即可提交审核")
                        .font(.caption)
                        .foregroundStyle(Theme.ColorToken.muted)
                        .frame(maxWidth: .infinity)
                }
                divider
                MetricCardView(title: AppStrings.reviewTime) {
                    ReviewTimeMetric(hours: viewModel.selectedApp.reviewHours)
                }
                divider
                MetricCardView(title: AppStrings.reviewRisk) {
                    RiskMetric(passRate: viewModel.selectedApp.passRate)
                }
                divider
                MetricCardView(title: AppStrings.contentCompletion) {
                    CompletionMetric(items: viewModel.completionItems)
                }
                divider
                MetricCardView(title: AppStrings.aiScore) {
                    AIScoreMetric(
                        score: viewModel.selectedApp.aiScore,
                        isFullAccess: membershipViewModel.isAllowed(.advancedReviewRisk) && membershipViewModel.status.isPaid
                    ) {
                        membershipViewModel.openPaywall()
                    }
                }
            }
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(Theme.ColorToken.line)
            .frame(width: 1)
            .padding(.vertical, 18)
    }

    private var topDashboardRow: some View {
        HStack(alignment: .top, spacing: 12) {
            TodoCardView(
                todos: viewModel.visibleTodos,
                totalTodoCount: viewModel.todoItems.count,
                suggestions: viewModel.visibleSuggestions,
                totalSuggestionCount: viewModel.suggestions.count,
                showAllTodos: viewModel.showAllTodos,
                showAllSuggestions: viewModel.showAllSuggestions,
                onToggleTodos: { viewModel.showAllTodos.toggle() },
                onToggleSuggestions: { viewModel.showAllSuggestions.toggle() }
            ) { todo in
                viewModel.handleTodo(todo)
            }
            .id(ReleaseModule.metadata)
            .frame(width: 250)

            ScreenshotPreviewView(
                selectedDevice: $viewModel.selectedScreenshotDevice,
                screenshots: viewModel.screenshots,
                isFocused: viewModel.focusedModule == .screenshots,
                onAdd: { viewModel.addScreenshot() },
                onDelete: { viewModel.deleteScreenshot($0) },
                onReplace: { viewModel.replaceScreenshot($0) },
                isRefreshing: viewModel.isRefreshingScreenshots,
                onRefresh: { viewModel.refreshSelectedAppScreenshots() }
            )
            .id(ReleaseModule.screenshots)
            .frame(maxWidth: .infinity)

            VStack(spacing: 12) {
                SubmissionInfoCard(
                    app: viewModel.selectedApp,
                    readiness: viewModel.displayedReadiness,
                    status: viewModel.displayedStatus,
                    bundleID: viewModel.selectedBundleID,
                    primaryLocale: viewModel.selectedPrimaryLocale,
                    buildNumber: viewModel.selectedBuildNumberText,
                    dataSourceTitle: viewModel.dataSourceTitle
                )
                ReleasePlanSummaryCard(
                    releasePlanSummary: viewModel.releasePlan.summary,
                    canSubmit: viewModel.canSubmit
                )
            }
            .id(ReleaseModule.reviewInfo)
            .frame(width: 250)
        }
    }

    private var bottomDashboardRow: some View {
        HStack(alignment: .top, spacing: 12) {
            BuildCardView(
                builds: viewModel.visibleBuilds,
                showAllBuilds: viewModel.showAllBuilds,
                isRefreshing: viewModel.isRefreshingAppStoreConnectStatus,
                onToggleBuilds: { viewModel.showAllBuilds.toggle() },
                onRefresh: { viewModel.refreshAppStoreConnectStatus() },
                onShowAllVersions: { viewModel.showVersionHistory() },
                onShowBuildDetail: { viewModel.showBuildDetail($0) }
            )
            .id(ReleaseModule.build)
            .frame(width: 360)

            SubmissionHeroCard(
                app: viewModel.selectedApp,
                bundleID: viewModel.selectedBundleID,
                versionBuildText: viewModel.selectedVersionBuildText,
                dataSourceTitle: viewModel.dataSourceTitle,
                didSubmit: viewModel.didSubmit,
                canSubmit: viewModel.canSubmit,
                blockedMessage: viewModel.blockedSubmitMessage ?? viewModel.blockingWarnings.first,
                onSubmit: { viewModel.requestSubmit() },
                onPreview: { viewModel.showReleaseDetails.toggle() }
            )
            .id(ReleaseModule.release)
            .frame(maxWidth: .infinity)

            ReleaseOptimizationCard(items: viewModel.completionItems)
                .frame(width: 200)

            PostReleasePlanCard(onConfigurePlan: { viewModel.showReleasePlanDialog() })
                .frame(width: 220)
        }
    }
}

private struct SubmissionInfoCard: View {
    let app: AppItem
    let readiness: Int
    let status: String
    let bundleID: String
    let primaryLocale: String
    let buildNumber: String
    let dataSourceTitle: String

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(AppStrings.submitInfo)
                        .font(.headline)
                    Spacer()
                    SmallGlassButton(title: "编辑")
                }
                info("应用", app.name)
                info("版本", "\(app.version) (\(app.buildNumber))")
                info(dataSourceTitle == "App Store Connect" ? "Bundle" : "平台", bundleID)
                info(dataSourceTitle == "App Store Connect" ? "Locale" : "语言", primaryLocale)
                info("构建", buildNumber)
                info("准备度", "\(readiness)%")
                info("状态", status)
                info("来源", dataSourceTitle)
            }
        }
    }

    private func info(_ label: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .foregroundStyle(Theme.ColorToken.muted)
                .frame(width: 54, alignment: .leading)
            Text(value)
                .fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Spacer(minLength: 0)
        }
        .font(.caption)
    }
}

private struct ReleasePlanSummaryCard: View {
    let releasePlanSummary: String
    let canSubmit: Bool

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("发布计划")
                    .font(.headline)
                status("平滑发布", releasePlanSummary, isOn: true)
                status("优先地区预热", "关闭", isOn: false)
                status("全球范围自然增长", canSubmit ? "开启" : "关闭", isOn: canSubmit)
            }
        }
    }

    private func status(_ title: String, _ value: String, isOn: Bool) -> some View {
        Label {
            HStack {
                Text(title)
                Spacer(minLength: 8)
                Text(value)
                    .foregroundStyle(Theme.ColorToken.muted)
                    .lineLimit(1)
            }
        } icon: {
            Image(systemName: isOn ? "checkmark.circle.fill" : "clock.fill")
                .foregroundStyle(isOn ? Theme.ColorToken.green : Theme.ColorToken.soft)
        }
        .font(.caption)
        .foregroundStyle(Theme.ColorToken.soft)
    }
}

private struct SubmissionHeroCard: View {
    let app: AppItem
    let bundleID: String
    let versionBuildText: String
    let dataSourceTitle: String
    let didSubmit: Bool
    let canSubmit: Bool
    let blockedMessage: String?
    let onSubmit: () -> Void
    let onPreview: () -> Void

    var body: some View {
        GlassCard(cornerRadius: 20, padding: 0) {
            VStack(spacing: 14) {
                HStack(spacing: 18) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [Theme.ColorToken.blue, Theme.ColorToken.purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 74, height: 74)
                            .shadow(color: Theme.ColorToken.purple.opacity(0.45), radius: 24, x: 0, y: 12)
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 34, weight: .semibold))
                            .foregroundStyle(.white)
                            .rotationEffect(.degrees(-18))
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(AppStrings.submitTitle)
                            .font(.title3.weight(.bold))
                        Text("版本: \(versionBuildText) · \(bundleID) · \(dataSourceTitle)")
                            .font(.caption)
                            .foregroundStyle(Theme.ColorToken.muted)
                            .lineLimit(1)
                    }
                    Spacer()
                }

                Button(action: onSubmit) {
                    HStack(spacing: 10) {
                        Image(systemName: "paperplane.fill")
                        Text(didSubmit ? "已模拟提交" : "准备提交")
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(LinearGradient(colors: [Theme.ColorToken.blue, Theme.ColorToken.purple], startPoint: .leading, endPoint: .trailing))
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.button, style: .continuous))
                    .shadow(color: Theme.ColorToken.blue.opacity(0.28), radius: 18, x: 0, y: 10)
                }
                .buttonStyle(.plain)
                    .frame(width: 260)

                Label(canSubmit ? "还剩 0 项待优化，已满足提交条件" : "还有 \(blockedMessage ?? "待处理项目")", systemImage: canSubmit ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(canSubmit ? Theme.ColorToken.green : Theme.ColorToken.orange)

                SmallGlassButton(title: "查看提交预览", systemImage: "eye", action: onPreview)
                    .frame(width: 160)
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(
                LinearGradient(colors: [Theme.ColorToken.purple.opacity(0.42), Theme.ColorToken.blue.opacity(0.28), Theme.ColorToken.panel.opacity(0.36)], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
        }
    }
}

private struct ReleaseOptimizationCard: View {
    let items: [CompletionItem]

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("发布优化")
                    .font(.headline)
                ForEach(items.prefix(4)) { item in
                    Label {
                        Text(label(for: item))
                            .lineLimit(1)
                    } icon: {
                        Image(systemName: item.percent >= 90 ? "checkmark.circle.fill" : "clock.fill")
                            .foregroundStyle(item.percent >= 90 ? Theme.ColorToken.green : Theme.ColorToken.orange)
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Theme.ColorToken.soft)
                }
            }
        }
    }

    private func label(for item: CompletionItem) -> String {
        item.percent >= 90 ? "\(item.title)已完善" : "\(item.title)需优化"
    }
}

private struct PostReleasePlanCard: View {
    let onConfigurePlan: () -> Void

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text(AppStrings.postReleasePlan)
                    .font(.headline)
                plan("监控每日核心指标", value: "开启")
                plan("宣传创意测试", value: "关闭")
                plan("发布后活动设计", value: "关闭")
                Spacer(minLength: 8)
                SmallGlassButton(title: "配置发布计划", action: onConfigurePlan)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func plan(_ title: String, value: String) -> some View {
        Label {
            HStack {
                Text(title)
                Spacer(minLength: 8)
                Text(value)
                    .foregroundStyle(Theme.ColorToken.muted)
            }
        } icon: {
            Image(systemName: "clock.fill")
                .foregroundStyle(Theme.ColorToken.soft)
        }
        .font(.caption)
        .foregroundStyle(Theme.ColorToken.soft)
    }
}
