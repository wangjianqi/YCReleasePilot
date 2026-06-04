import SwiftUI

struct SettingsSidebar: View {
    @Binding var selection: SettingsSectionID

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Settings")
                    .font(.system(size: 24, weight: .bold))
                Text("ReleasePilot preferences")
                    .font(.caption)
                    .foregroundStyle(Theme.ColorToken.muted)
            }
            .padding(.horizontal, 16)
            .padding(.top, 18)

            VStack(spacing: 4) {
                ForEach(SettingsSectionID.allCases) { section in
                    Button {
                        selection = section
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: section.symbol)
                                .frame(width: 20)
                            Text(section.title)
                                .font(.caption.weight(.semibold))
                            Spacer()
                        }
                        .foregroundStyle(selection == section ? Theme.ColorToken.text : Theme.ColorToken.muted)
                        .padding(.horizontal, 12)
                        .frame(height: 34)
                        .background(selection == section ? Color.white.opacity(0.075) : .clear)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 10)
            Spacer()
        }
        .background(Color.white.opacity(0.025))
    }
}
