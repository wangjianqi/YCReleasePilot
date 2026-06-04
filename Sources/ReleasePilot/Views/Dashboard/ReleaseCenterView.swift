import SwiftUI

struct ReleaseCenterView: View {
    @Bindable var viewModel: ReleaseDashboardViewModel

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    header
                    metrics
                    ReleaseFlowView(steps: viewModel.releaseSteps)
                        .id(ReleaseModule.release)
                    middleGrid
                    SubmitReviewCardView(
                        app: viewModel.selectedApp,
                        readiness: viewModel.displayedReadiness,
                        didSubmit: viewModel.didSubmit,
                        canSubmit: viewModel.canSubmit,
                        blockedMessage: viewModel.blockedSubmitMessage ?? viewModel.blockingWarnings.first
                    ) {
                        viewModel.requestSubmit()
                    }
                    .id(ReleaseModule.reviewInfo)
                }
                .padding(18)
            }
            .onChange(of: viewModel.focusedModule) { _, module in
                guard let module else { return }
                withAnimation(.easeInOut(duration: 0.25)) {
                    proxy.scrollTo(module, anchor: .center)
                }
            }
        }
        .background(surface)
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
                        Text("iOS, iPadOS, macOS")
                            .font(.caption)
                            .foregroundStyle(Theme.ColorToken.muted)
                        StatusBadge(title: "v\(viewModel.selectedApp.version) (\(viewModel.selectedApp.buildNumber))", tint: Theme.ColorToken.blue)
                        StatusBadge(title: viewModel.displayedStatus, tint: Theme.ColorToken.green)
                    }
                }
            }
            Spacer()
            PlatformSegmentedControl(selection: $viewModel.selectedPlatform)
        }
    }

    private var metrics: some View {
        GlassCard(cornerRadius: 20, padding: 0) {
            HStack(spacing: 0) {
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
                    AIScoreMetric(score: viewModel.selectedApp.aiScore)
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

    private var middleGrid: some View {
        Grid(horizontalSpacing: 12, verticalSpacing: 12) {
            GridRow {
                TodoCardView(todos: viewModel.todoItems, suggestions: viewModel.suggestions) { todo in
                    viewModel.handleTodo(todo)
                }
                .id(ReleaseModule.metadata)
                    .gridCellColumns(1)
                BuildCardView(builds: viewModel.builds)
                    .id(ReleaseModule.build)
                    .gridCellColumns(1)
                ScreenshotPreviewView(
                    selectedDevice: $viewModel.selectedScreenshotDevice,
                    screenshots: viewModel.screenshots,
                    isFocused: viewModel.focusedModule == .screenshots,
                    onAdd: { viewModel.addScreenshot() },
                    onDelete: { viewModel.deleteScreenshot($0) },
                    onReplace: { viewModel.replaceScreenshot($0) }
                )
                .id(ReleaseModule.screenshots)
                    .gridCellColumns(2)
            }
        }
    }
}
