import SwiftUI

struct CopilotSuggestionsView: View {
    @Bindable var dashboardViewModel: ReleaseDashboardViewModel
    @Bindable var copilotViewModel: CopilotViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 10) {
                ForEach(copilotViewModel.visibleSuggestions) { suggestion in
                    CopilotSuggestionCard(
                        suggestion: suggestion,
                        onApply: { copilotViewModel.applySuggestion(suggestion) },
                        onIgnore: { copilotViewModel.ignoreSuggestion(suggestion) },
                        onAskAI: {
                            copilotViewModel.askAI(
                                about: suggestion,
                                appName: dashboardViewModel.selectedApp.name,
                                platform: dashboardViewModel.selectedPlatform
                            )
                        }
                    )
                }
            }
        }
    }
}
