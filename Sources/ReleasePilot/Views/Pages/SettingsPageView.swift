import SwiftUI

struct SettingsPageView: View {
    @Bindable var settingsViewModel: SettingsViewModel

    var body: some View {
        SettingsView(viewModel: settingsViewModel)
    }
}
