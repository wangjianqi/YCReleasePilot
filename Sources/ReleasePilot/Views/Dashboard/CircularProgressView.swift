import SwiftUI

struct CircularProgressView: View {
    let percent: Int

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: 11)
            Circle()
                .trim(from: 0, to: CGFloat(percent) / 100)
                .stroke(
                    LinearGradient(colors: [Theme.ColorToken.blue, Theme.ColorToken.cyan], startPoint: .topLeading, endPoint: .bottomTrailing),
                    style: StrokeStyle(lineWidth: 11, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: Theme.ColorToken.blue.opacity(0.42), radius: 12)
            VStack(spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    Text("\(percent)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                    Text("%")
                        .font(.title3.weight(.semibold))
                }
                StatusBadge(title: percent >= 90 ? "优秀" : "良好", tint: Theme.ColorToken.green)
            }
        }
        .frame(width: 132, height: 132)
    }
}
