import SwiftUI

struct CopilotPanelView: View {
    @Bindable var viewModel: ReleaseDashboardViewModel
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 14) {
            header
            tabs
            messages
            quickActions
            composer
            footer
        }
        .padding(16)
        .background(surface)
    }

    private var surface: some View {
        LinearGradient(colors: [Color(hex: 0x0A1628).opacity(0.9), Color(hex: 0x06101E).opacity(0.94)], startPoint: .top, endPoint: .bottom)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.surface, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: Theme.Radius.surface, style: .continuous).stroke(Theme.ColorToken.line, lineWidth: 1))
            .shadow(color: .black.opacity(0.36), radius: 30, x: 0, y: 20)
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(Theme.ColorToken.purple)
                    Text(AppStrings.copilotTitle)
                        .font(.title3.weight(.bold))
                    StatusBadge(title: AppStrings.copilotBeta, tint: Theme.ColorToken.purple)
                }
                Text(AppStrings.copilotSubtitle)
                    .font(.caption)
                    .foregroundStyle(Theme.ColorToken.muted)
            }
            Spacer()
            Image(systemName: "arrow.up.left.and.arrow.down.right")
            Image(systemName: "xmark")
        }
        .font(.caption)
        .foregroundStyle(Theme.ColorToken.muted)
    }

    private var tabs: some View {
        HStack(spacing: 4) {
            tabButton(AppStrings.chat, index: 0)
            tabButton("\(AppStrings.advice) (6)", index: 1)
        }
        .padding(4)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
    }

    private func tabButton(_ title: String, index: Int) -> some View {
        Button {
            selectedTab = index
        } label: {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(selectedTab == index ? .white : Theme.ColorToken.muted)
                .frame(maxWidth: .infinity)
                .frame(height: 32)
                .background(selectedTab == index ? Color.white.opacity(0.08) : .clear)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var messages: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    ForEach(viewModel.copilotMessages) { message in
                        CopilotMessageView(message: message) {
                            viewModel.applyReviewNote()
                        }
                        .id(message.id)
                    }
                }
                .padding(.vertical, 2)
            }
            .onChange(of: viewModel.copilotMessages.count) { _, _ in
                if let lastID = viewModel.copilotMessages.last?.id {
                    withAnimation(.easeOut(duration: 0.2)) {
                        proxy.scrollTo(lastID, anchor: .bottom)
                    }
                }
            }
        }
    }

    private var quickActions: some View {
        VStack(spacing: 10) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                CopilotQuickActionView(title: "优化副标题", systemImage: "textformat.size") { quick("正在优化标题与副标题...") }
                CopilotQuickActionView(title: "生成关键词", systemImage: "key.fill") { quick("正在生成关键词方案...") }
                CopilotQuickActionView(title: "翻译描述", systemImage: "globe") { quick("正在翻译描述...") }
                CopilotQuickActionView(title: "ASO 分析", systemImage: "chart.line.uptrend.xyaxis") { quick("正在进行 ASO 分析...") }
            }
        }
    }

    private var composer: some View {
        HStack(spacing: 8) {
            TextField(AppStrings.inputPlaceholder, text: $viewModel.chatInput)
                .textFieldStyle(.plain)
                .font(.caption)
                .foregroundStyle(Theme.ColorToken.text)
                .onSubmit {
                    viewModel.sendChat()
                }

            Button {
                viewModel.sendChat()
            } label: {
                Image(systemName: "paperplane.fill")
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .background(LinearGradient(colors: [Theme.ColorToken.blue, Theme.ColorToken.purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(10)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 17, style: .continuous).stroke(Theme.ColorToken.line, lineWidth: 1))
    }

    private var footer: some View {
        Label("基于 GPT-4o 分析，内容仅供参考", systemImage: "info.circle")
            .font(.caption2)
            .foregroundStyle(Theme.ColorToken.muted)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func quick(_ text: String) {
        viewModel.copilotMessages.append(CopilotMessage(role: .assistant, title: text, body: "这是本地 Mock 反馈。后续可以接入 AI 网关或 OpenAI API，把结果写回元数据、关键词和审核信息。"))
    }
}
