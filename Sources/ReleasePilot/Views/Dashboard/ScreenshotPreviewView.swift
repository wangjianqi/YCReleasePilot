import SwiftUI

struct ScreenshotPreviewView: View {
    @Binding var selectedDevice: ScreenshotDevice
    let screenshots: [ScreenshotItem]
    var isFocused: Bool
    let onAdd: () -> Void
    let onDelete: (ScreenshotItem) -> Void
    let onReplace: (ScreenshotItem) -> Void

    var body: some View {
        GlassCard(cornerRadius: Theme.Radius.large, padding: 16) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(AppStrings.screenshotPreview)
                        .font(.headline)
                    Spacer()
                    SmallGlassButton(title: "添加截图", systemImage: "plus", action: onAdd)
                }

                HStack(spacing: 6) {
                    ForEach(ScreenshotDevice.allCases) { device in
                        Button {
                            selectedDevice = device
                        } label: {
                            Text(device.rawValue)
                                .font(.caption)
                                .foregroundStyle(selectedDevice == device ? .white : Theme.ColorToken.muted)
                                .padding(.horizontal, 12)
                                .frame(height: 30)
                                .background(selectedDevice == device ? Theme.ColorToken.blue.opacity(0.65) : Color.white.opacity(0.04))
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }

                HStack(spacing: 13) {
                    ForEach(screenshots) { item in
                        ScreenshotPhoneView(item: item, onDelete: { onDelete(item) }, onReplace: { onReplace(item) })
                    }
                    AddScreenshotView(onAdd: onAdd)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                .stroke(isFocused ? Theme.ColorToken.blue.opacity(0.85) : Color.clear, lineWidth: 2)
        )
    }
}

private struct ScreenshotPhoneView: View {
    let item: ScreenshotItem
    let onDelete: () -> Void
    let onReplace: () -> Void
    @State private var isHovering = false

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.black)
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(LinearGradient(colors: [Color(hex: 0x2B1B26), Color(hex: 0x192030), Color.black], startPoint: .top, endPoint: .bottom))
                    .padding(6)

                VStack {
                    Text(item.title)
                        .font(.system(size: 9, weight: .bold))
                    Text(item.subtitle)
                        .font(.system(size: 9, weight: .bold))
                    Spacer()
                    Image(systemName: "person.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(LinearGradient(colors: [Color(hex: 0xFFE0C8), Color(hex: 0x8E5A60)], startPoint: .top, endPoint: .bottom))
                        .padding(.bottom, 12)
                }
                .foregroundStyle(.white)
                .padding(.top, 18)

                if isHovering {
                    VStack(spacing: 6) {
                        Button(action: onReplace) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.caption.weight(.bold))
                                .frame(width: 24, height: 24)
                        }
                        Button(action: onDelete) {
                            Image(systemName: "trash")
                                .font(.caption.weight(.bold))
                                .frame(width: 24, height: 24)
                        }
                    }
                    .foregroundStyle(.white)
                    .background(Color.black.opacity(0.36))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .offset(x: 22, y: -48)
                    .buttonStyle(.plain)
                }
            }
            .frame(width: 78, height: 156)
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.26), lineWidth: 1)
            )

            Image(systemName: item.hasWarning ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                .foregroundStyle(item.hasWarning ? Theme.ColorToken.orange : Theme.ColorToken.green)
                .font(.caption)
        }
        .onHover { isHovering = $0 }
    }
}

private struct AddScreenshotView: View {
    let onAdd: () -> Void

    var body: some View {
        Button(action: onAdd) {
            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    .foregroundStyle(Color.white.opacity(0.20))
                    .frame(width: 78, height: 156)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.title3)
                            .foregroundStyle(Theme.ColorToken.muted)
                    )
                Text(" ")
                    .font(.caption)
            }
        }
        .buttonStyle(.plain)
    }
}
