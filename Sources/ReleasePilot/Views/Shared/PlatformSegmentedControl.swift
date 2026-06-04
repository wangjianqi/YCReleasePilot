import SwiftUI

struct PlatformSegmentedControl: View {
    @Binding var selection: Platform

    var body: some View {
        HStack(spacing: 4) {
            ForEach(Platform.allCases) { platform in
                Button {
                    selection = platform
                } label: {
                    Label(platform.rawValue, systemImage: platform.symbol)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(selection == platform ? .white : Theme.ColorToken.muted)
                        .frame(width: 104, height: 34)
                        .background(selection == platform ? Theme.ColorToken.blue.opacity(0.75) : .clear)
                        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .stroke(Theme.ColorToken.line, lineWidth: 1)
        )
    }
}
