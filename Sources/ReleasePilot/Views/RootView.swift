import SwiftUI

struct RootView: View {
    @State private var viewModel = ReleaseDashboardViewModel()

    var body: some View {
        ZStack {
            background

            HStack(spacing: Theme.Spacing.page) {
                SidebarView(viewModel: viewModel)
                    .frame(width: 252)

                ReleaseCenterView(viewModel: viewModel)
                    .frame(maxWidth: .infinity)

                CopilotPanelView(viewModel: viewModel)
                    .frame(width: 360)
            }
            .padding(10)
        }
        .foregroundStyle(Theme.ColorToken.text)
        .alert(AppStrings.confirmSubmitTitle, isPresented: Binding(
            get: { viewModel.showingSubmitConfirmation },
            set: { viewModel.showingSubmitConfirmation = $0 }
        )) {
            Button(AppStrings.cancel, role: .cancel) {}
            Button(AppStrings.confirmSubmit) {
                viewModel.confirmSubmit()
            }
        } message: {
            Text(AppStrings.confirmSubmitMessage)
        }
    }

    private var background: some View {
        ZStack {
            LinearGradient(colors: [Theme.ColorToken.backgroundDeep, Theme.ColorToken.background, Theme.ColorToken.backgroundDeep], startPoint: .topLeading, endPoint: .bottomTrailing)
            RadialGradient(colors: [Theme.ColorToken.blue.opacity(0.18), .clear], center: .topLeading, startRadius: 40, endRadius: 520)
            RadialGradient(colors: [Theme.ColorToken.purple.opacity(0.14), .clear], center: .bottomTrailing, startRadius: 40, endRadius: 600)
        }
        .ignoresSafeArea()
    }
}
