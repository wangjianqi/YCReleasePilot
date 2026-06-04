import SwiftUI

struct ReleasePlanModalView: View {
    @Bindable var viewModel: ReleaseDashboardViewModel

    var body: some View {
        ModalShell(title: "配置发布计划", onClose: { viewModel.closeDialog() }) {
            VStack(alignment: .leading, spacing: 14) {
                Picker("发布方式", selection: $viewModel.releasePlanDraft.releaseMode) {
                    ForEach(ReleaseMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                Picker("发布时间", selection: $viewModel.releasePlanDraft.timing) {
                    ForEach(ReleaseTiming.allCases) { timing in
                        Text(timing.title).tag(timing)
                    }
                }
                .pickerStyle(.segmented)

                if viewModel.releasePlanDraft.timing == .scheduled {
                    DatePicker("指定时间", selection: $viewModel.releasePlanDraft.scheduledAt)
                        .datePickerStyle(.compact)
                }

                Text("版本发布说明")
                    .font(.caption.weight(.semibold))
                TextEditor(text: $viewModel.releasePlanDraft.releaseNotes)
                    .font(.caption)
                    .frame(height: 90)
                    .scrollContentBackground(.hidden)
                    .background(Color.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                Toggle("发布后通知团队", isOn: $viewModel.releasePlanDraft.notifyTeam)
                Toggle("自动监控审核状态", isOn: $viewModel.releasePlanDraft.monitorReview)

                HStack {
                    Spacer()
                    SmallGlassButton(title: "取消") { viewModel.closeDialog() }
                    PrimaryButton(title: "保存发布计划", systemImage: "checkmark") {
                        viewModel.saveReleasePlan()
                    }
                    .frame(width: 180)
                }
            }
        }
    }
}
