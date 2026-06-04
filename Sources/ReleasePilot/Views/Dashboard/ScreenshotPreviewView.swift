import SwiftUI

struct ScreenshotPreviewView: View {
    @Binding var selectedDevice: ScreenshotDevice
    let screenshots: [ScreenshotItem]

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(AppStrings.screenshotPreview)
                        .font(.headline)
                    Spacer()
                    SmallGlassButton(title: "管理截图")
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
                        ScreenshotPhoneView(item: item)
                    }
                    AddScreenshotView()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

private struct ScreenshotPhoneView: View {
    let item: ScreenshotItem

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
    }
}

private struct AddScreenshotView: View {
    var body: some View {
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
}
