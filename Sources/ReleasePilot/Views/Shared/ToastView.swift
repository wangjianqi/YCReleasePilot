import SwiftUI

struct ToastView: View {
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        VStack {
            Spacer()
            Text(message)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 16)
                .frame(height: 38)
                .background(Color.black.opacity(0.7))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Theme.ColorToken.lineStrong, lineWidth: 1))
                .padding(.bottom, 28)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                        onDismiss()
                    }
                }
        }
    }
}
