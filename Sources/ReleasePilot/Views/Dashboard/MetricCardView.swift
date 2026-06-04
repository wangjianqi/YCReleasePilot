import SwiftUI

struct MetricCardView<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 5) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                Image(systemName: "info.circle")
                    .font(.caption2)
                    .foregroundStyle(Theme.ColorToken.muted)
            }
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 172, alignment: .topLeading)
    }
}

struct ReviewTimeMetric: View {
    let hours: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text(hours)
                    .font(.system(size: 28, weight: .bold))
                Text("小时")
                    .font(.caption)
            }
            Text("基于近期历史数据预测")
                .font(.caption)
                .foregroundStyle(Theme.ColorToken.muted)

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array([28, 44, 34, 60, 42, 31, 54, 36, 46].enumerated()), id: \.offset) { _, height in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LinearGradient(colors: [Theme.ColorToken.purple, Theme.ColorToken.purple.opacity(0.22)], startPoint: .top, endPoint: .bottom))
                        .frame(width: 7, height: CGFloat(height))
                }
            }
            .frame(height: 66)
        }
    }
}

struct RiskMetric: View {
    let passRate: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("低风险")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Theme.ColorToken.green)
            Text("预计通过率")
                .font(.caption)
                .foregroundStyle(Theme.ColorToken.muted)
            Text("\(passRate)%")
                .font(.system(size: 28, weight: .bold))
            Sparkline()
                .stroke(Theme.ColorToken.green, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                .frame(height: 42)
                .shadow(color: Theme.ColorToken.green.opacity(0.25), radius: 8)
        }
    }
}

struct CompletionMetric: View {
    let items: [CompletionItem]

    var body: some View {
        VStack(spacing: 9) {
            ForEach(items) { item in
                HStack(spacing: 8) {
                    Text(item.title)
                        .font(.caption)
                        .foregroundStyle(Theme.ColorToken.soft)
                        .frame(width: 58, alignment: .leading)
                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.white.opacity(0.09))
                            Capsule()
                                .fill(item.tint)
                                .frame(width: proxy.size.width * CGFloat(item.percent) / 100)
                        }
                    }
                    .frame(height: 6)
                    Text("\(item.percent)%")
                        .font(.caption2)
                        .foregroundStyle(Theme.ColorToken.muted)
                        .frame(width: 34, alignment: .trailing)
                }
            }
        }
        .padding(.top, 2)
    }
}

struct AIScoreMetric: View {
    let score: Int

    var body: some View {
        VStack(spacing: 8) {
            Hexagon()
                .fill(LinearGradient(colors: [Theme.ColorToken.blue.opacity(0.28), Theme.ColorToken.purple.opacity(0.72)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay(
                    VStack(spacing: 0) {
                        Text("\(score)")
                            .font(.system(size: 34, weight: .black))
                        Text("/100")
                            .font(.caption)
                            .foregroundStyle(Theme.ColorToken.soft)
                    }
                )
                .frame(width: 94, height: 104)
                .shadow(color: Theme.ColorToken.purple.opacity(0.35), radius: 18)
            Text("表现良好")
                .font(.caption.weight(.bold))
                .foregroundStyle(Theme.ColorToken.green)
            Text("仍有优化空间")
                .font(.caption2)
                .foregroundStyle(Theme.ColorToken.muted)
        }
        .frame(maxWidth: .infinity)
    }
}

struct Sparkline: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let points = [
            CGPoint(x: 0.00, y: 0.78), CGPoint(x: 0.12, y: 0.56),
            CGPoint(x: 0.24, y: 0.70), CGPoint(x: 0.34, y: 0.42),
            CGPoint(x: 0.48, y: 0.62), CGPoint(x: 0.61, y: 0.36),
            CGPoint(x: 0.72, y: 0.18), CGPoint(x: 0.84, y: 0.30),
            CGPoint(x: 1.00, y: 0.22)
        ]
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + rect.height * points[0].y))
        for point in points.dropFirst() {
            path.addLine(to: CGPoint(x: rect.minX + rect.width * point.x, y: rect.minY + rect.height * point.y))
        }
        return path
    }
}

struct Hexagon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.25))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.75))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.75))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.25))
        path.closeSubpath()
        return path
    }
}
