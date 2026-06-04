import SwiftUI

struct ModalShell<Content: View>: View {
    let title: String
    let onClose: () -> Void
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            Color.black.opacity(0.46).ignoresSafeArea()
            GlassCard(cornerRadius: 22, padding: 18) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(title)
                            .font(.title3.weight(.bold))
                        Spacer()
                        Button(action: onClose) {
                            Image(systemName: "xmark")
                                .frame(width: 30, height: 30)
                                .background(Color.white.opacity(0.07))
                                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                    content
                }
            }
            .frame(maxWidth: 760)
            .padding(32)
        }
    }
}
