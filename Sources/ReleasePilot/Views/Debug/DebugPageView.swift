import SwiftUI

struct DebugPageView: View {
    private let logger = NetworkRequestLogger.shared
    @State private var selectedGroupID: String?
    @State private var showingClearConfirm = false

    var body: some View {
        VStack(spacing: 0) {
            header
            if logger.groups.isEmpty {
                emptyState
            } else {
                statsBar
                Divider().overlay(Theme.ColorToken.line)
                requestList
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.ColorToken.background.opacity(0.3))
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(AppStrings.debugTitle)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Theme.ColorToken.text)
                Text("App Store Connect API")
                    .font(.caption)
                    .foregroundStyle(Theme.ColorToken.muted)
            }
            Spacer()

            if !logger.groups.isEmpty {
                Button {
                    showingClearConfirm = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "trash")
                            .font(.caption)
                        Text(AppStrings.debugClearAll)
                            .font(.caption.weight(.medium))
                    }
                    .foregroundStyle(Theme.ColorToken.red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Theme.ColorToken.red.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.button, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Radius.button, style: .continuous)
                            .stroke(Theme.ColorToken.red.opacity(0.24), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .alert(AppStrings.debugClearAll, isPresented: $showingClearConfirm) {
                    Button(AppStrings.cancel, role: .cancel) {}
                    Button(AppStrings.debugClearAll, role: .destructive) {
                        logger.clearAll()
                        selectedGroupID = nil
                    }
                } message: {
                    Text("确定要清空所有接口请求记录吗？")
                }
            }
        }
        .padding(.horizontal, Theme.Spacing.card)
        .padding(.vertical, 14)
    }

    // MARK: - Stats Bar

    private var statsBar: some View {
        HStack(spacing: 16) {
            statChip(
                title: AppStrings.debugTotalRequests,
                value: "\(logger.totalRequestCount)",
                tint: Theme.ColorToken.blue
            )
            statChip(
                title: AppStrings.debugDuplicateGroups,
                value: "\(logger.duplicateGroupCount)",
                tint: logger.duplicateGroupCount > 0 ? Theme.ColorToken.red : Theme.ColorToken.green
            )
            if logger.maxSeverity >= .serious {
                riskChip
            }
            Spacer()
        }
        .padding(.horizontal, Theme.Spacing.card)
        .padding(.vertical, 10)
    }

    private func statChip(title: String, value: String, tint: Color) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(tint)
                .frame(width: 8, height: 8)
            Text(title)
                .font(.caption)
                .foregroundStyle(Theme.ColorToken.muted)
            Text(value)
                .font(.caption.weight(.bold))
                .foregroundStyle(tint)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(tint.opacity(0.08))
        .clipShape(Capsule())
    }

    private var riskChip: some View {
        HStack(spacing: 6) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.caption2)
            Text(AppStrings.debugRiskLevel)
                .font(.caption2.weight(.medium))
            Text(severityLabel(logger.maxSeverity))
                .font(.caption2.weight(.bold))
        }
        .foregroundStyle(Theme.ColorToken.red)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Theme.ColorToken.red.opacity(0.12))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Theme.ColorToken.red.opacity(0.3), lineWidth: 1))
    }

    // MARK: - Request List

    private var requestList: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(logger.groups) { group in
                    requestGroupRow(group)
                }
            }
            .padding(Theme.Spacing.card)
        }
    }

    private func requestGroupRow(_ group: APIRequestGroup) -> some View {
        VStack(spacing: 0) {
            // Main row
            HStack(spacing: 12) {
                // Method badge
                methodBadge(group.method)

                // Endpoint + params
                VStack(alignment: .leading, spacing: 4) {
                    Text(group.endpoint)
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Theme.ColorToken.text)
                        .lineLimit(1)

                    if !group.queryItems.isEmpty {
                        Text(paramsSummary(group.queryItems))
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(Theme.ColorToken.muted)
                            .lineLimit(1)
                    }
                }

                Spacer()

                // Count badge
                countBadge(count: group.count, severity: group.severity)

                // Status code
                if let statusCode = group.lastStatusCode {
                    statusCodeBadge(statusCode)
                }

                // Duration
                if let duration = group.lastDuration {
                    durationBadge(duration)
                }
            }
            .padding(14)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.15)) {
                    selectedGroupID = selectedGroupID == group.id ? nil : group.id
                }
            }

            // Duplicate warning
            if group.isDuplicate {
                duplicateWarning(group)
            }

            // Expanded detail
            if selectedGroupID == group.id {
                expandedDetail(group)
            }
        }
        .background(Theme.cardGradient)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                .stroke(group.severity >= .serious ? Theme.ColorToken.red.opacity(0.4) : Theme.ColorToken.line, lineWidth: group.severity >= .serious ? 1.5 : 1)
        )
        .shadow(color: group.severity >= .serious ? Theme.ColorToken.red.opacity(0.08) : .black.opacity(0.26), radius: group.severity >= .serious ? 16 : 24, x: 0, y: group.severity >= .serious ? 0 : 18)
    }

    // MARK: - Sub-components

    private func methodBadge(_ method: String) -> some View {
        Text(method)
            .font(.caption2.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(method == "GET" ? Theme.ColorToken.green : Theme.ColorToken.blue)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }

    private func countBadge(count: Int, severity: DuplicateSeverity) -> some View {
        let tint: Color = severity >= .critical ? Theme.ColorToken.red :
                          severity >= .serious ? Theme.ColorToken.orange :
                          severity >= .warning ? Theme.ColorToken.orange :
                          Theme.ColorToken.soft

        return HStack(spacing: 4) {
            if severity >= .warning {
                Image(systemName: severity >= .critical ? "exclamationmark.triangle.fill" : "exclamationmark.circle.fill")
                    .font(.caption2)
            }
            Text("×\(count)")
                .font(.caption.weight(.bold))
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(tint.opacity(0.12))
        .clipShape(Capsule())
    }

    private func statusCodeBadge(_ statusCode: Int) -> some View {
        let tint: Color = (200..<300).contains(statusCode) ? Theme.ColorToken.green : Theme.ColorToken.red
        return Text("\(statusCode)")
            .font(.caption2.weight(.bold))
            .foregroundStyle(tint)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(tint.opacity(0.1))
            .clipShape(Capsule())
    }

    private func durationBadge(_ duration: TimeInterval) -> some View {
        let ms = Int(duration * 1000)
        let tint: Color = ms < 1000 ? Theme.ColorToken.cyan : ms < 3000 ? Theme.ColorToken.orange : Theme.ColorToken.red
        return Text("\(ms)ms")
            .font(.caption2.weight(.semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(tint.opacity(0.08))
            .clipShape(Capsule())
    }

    private func duplicateWarning(_ group: APIRequestGroup) -> some View {
        let (message, tint): (String, Color) = {
            switch group.severity {
            case .critical: (AppStrings.debugWarningCriticalMessage, Theme.ColorToken.red)
            case .serious: (AppStrings.debugWarningSeriousMessage, Theme.ColorToken.orange)
            case .warning: (AppStrings.debugWarningDuplicateMessage, Theme.ColorToken.orange)
            case .none: ("", Theme.ColorToken.muted)
            }
        }()

        return HStack(spacing: 8) {
            Image(systemName: group.severity >= .critical ? "flame.fill" : "exclamationmark.triangle.fill")
                .font(.caption)
            Text(severityLabel(group.severity))
                .font(.caption.weight(.bold))
            Text("—")
                .font(.caption)
            Text(message)
                .font(.caption)
            Spacer()
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(tint.opacity(0.06))
    }

    private func expandedDetail(_ group: APIRequestGroup) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider().overlay(Theme.ColorToken.line)

            // Params detail
            if !group.queryItems.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text(AppStrings.debugParams)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Theme.ColorToken.muted)
                    ForEach(Array(group.queryItems.sorted { $0.key < $1.key }), id: \.key) { key, value in
                        HStack(spacing: 4) {
                            Text(key)
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundStyle(Theme.ColorToken.cyan)
                            Text("=")
                                .foregroundStyle(Theme.ColorToken.muted)
                            Text(value)
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundStyle(Theme.ColorToken.soft)
                        }
                    }
                }
            }

            // Request history
            VStack(alignment: .leading, spacing: 4) {
                Text("请求历史（共 \(group.count) 次）")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Theme.ColorToken.muted)

                ForEach(group.records.suffix(5)) { record in
                    HStack(spacing: 8) {
                        if let code = record.statusCode {
                            statusCodeBadge(code)
                        } else if let error = record.errorMessage {
                            Text(error)
                                .font(.caption2)
                                .foregroundStyle(Theme.ColorToken.red)
                                .lineLimit(1)
                        }
                        if let duration = record.duration {
                            Text("\(Int(duration * 1000))ms")
                                .font(.caption2)
                                .foregroundStyle(Theme.ColorToken.muted)
                        }
                        Spacer()
                        Text(record.timestamp, style: .time)
                            .font(.caption2)
                            .foregroundStyle(Theme.ColorToken.muted)
                    }
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 12)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "network")
                .font(.system(size: 48))
                .foregroundStyle(Theme.ColorToken.muted.opacity(0.5))
            VStack(spacing: 6) {
                Text(AppStrings.debugNoRequests)
                    .font(.headline)
                    .foregroundStyle(Theme.ColorToken.muted)
                Text(AppStrings.debugNoRequestsHint)
                    .font(.caption)
                    .foregroundStyle(Theme.ColorToken.muted.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Helpers

    private func paramsSummary(_ params: [String: String]) -> String {
        params.sorted { $0.key < $1.key }
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
    }

    private func severityLabel(_ severity: DuplicateSeverity) -> String {
        switch severity {
        case .none: ""
        case .warning: AppStrings.debugWarningDuplicate
        case .serious: AppStrings.debugWarningSerious
        case .critical: AppStrings.debugWarningCritical
        }
    }
}
