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
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(AppStrings.screenshotPreview)
                            .font(.headline)
                        Text("（最多 5 张）")
                            .font(.caption)
                            .foregroundStyle(Theme.ColorToken.muted)
                    }
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
                                .frame(height: 32)
                                .background(selectedDevice == device ? Theme.ColorToken.blue.opacity(0.72) : Color.white.opacity(0.055))
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 10) {
                        if screenshots.isEmpty {
                            MissingScreenshotView(onAdd: onAdd)
                        } else {
                            ForEach(previewScreenshots) { item in
                                ScreenshotPhoneView(item: item, onDelete: { onDelete(item) }, onReplace: { onReplace(item) })
                            }
                        }
                    }
                    .padding(.vertical, 2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 8) {
                    Spacer()
                    ForEach(0..<max(min(screenshots.count, 5), 1), id: \.self) { index in
                        Circle()
                            .fill(index == 0 ? Theme.ColorToken.green : Theme.ColorToken.muted.opacity(0.45))
                            .frame(width: index == 0 ? 10 : 8, height: index == 0 ? 10 : 8)
                    }
                    Spacer()
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                .stroke(isFocused ? Theme.ColorToken.blue.opacity(0.85) : Color.clear, lineWidth: 2)
        )
    }

    private var previewScreenshots: [ScreenshotItem] {
        guard !screenshots.isEmpty else { return [] }
        var items = Array(screenshots.prefix(5))
        while items.count < 5 {
            let slot = items.count + 1
            items.append(
                ScreenshotItem(
                    id: "preview-placeholder-\(selectedDevice.id)-\(slot)",
                    device: selectedDevice,
                    slot: slot,
                    title: placeholderTitle(for: slot),
                    subtitle: placeholderSubtitle(for: slot),
                    hasWarning: slot == 4,
                    isPlaceholder: true,
                    styleIndex: slot
                )
            )
        }
        return items
    }

    private func placeholderTitle(for slot: Int) -> String {
        switch slot {
        case 4: "多种滤镜"
        case 5: "隐私安全"
        default: "截图占位"
        }
    }

    private func placeholderSubtitle(for slot: Int) -> String {
        switch slot {
        case 4: "风格任选"
        case 5: "本地处理"
        default: "等待补充"
        }
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

                if let path = item.localImagePath, let image = NSImage(contentsOfFile: path) {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 184)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                } else {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(LinearGradient(colors: gradientColors, startPoint: .top, endPoint: .bottom))
                        .padding(7)

                    VStack(spacing: 5) {
                        Text(item.title)
                            .font(.system(size: 14, weight: .bold))
                            .multilineTextAlignment(.center)
                        Text(item.subtitle)
                            .font(.system(size: 13, weight: .bold))
                            .multilineTextAlignment(.center)
                        Spacer()
                        ZStack(alignment: .bottom) {
                            Circle()
                                .fill(Color.black.opacity(0.28))
                                .frame(width: 64, height: 64)
                            Image(systemName: item.styleIndex % 5 == 4 ? "lock.shield.fill" : "person.fill")
                                .font(.system(size: 52))
                                .foregroundStyle(LinearGradient(colors: [Color(hex: 0xFFE0C8), Color(hex: 0x9A5A66)], startPoint: .top, endPoint: .bottom))
                        }
                        .padding(.bottom, 18)
                        HStack(spacing: 8) {
                            ForEach(0..<3, id: \.self) { index in
                                Circle()
                                    .fill(index == 0 ? Theme.ColorToken.purple : Color.white.opacity(0.18))
                                    .frame(width: 14, height: 14)
                            }
                        }
                        .padding(.bottom, 12)
                    }
                    .foregroundStyle(.white)
                    .padding(.top, 22)
                    .padding(.horizontal, 10)
                }

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
                    .offset(x: 32, y: -70)
                    .buttonStyle(.plain)
                }
            }
            .frame(width: 94, height: 204)
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

    private var gradientColors: [Color] {
        switch item.styleIndex % 5 {
        case 1: [Color(hex: 0x221527), Color(hex: 0x151D2A), Color.black]
        case 2: [Color(hex: 0x161B25), Color(hex: 0x312030), Color.black]
        case 3: [Color(hex: 0x1B1728), Color(hex: 0x0D1D25), Color.black]
        case 4: [Color(hex: 0x10172A), Color(hex: 0x251A46), Color.black]
        default: [Color(hex: 0x2B1B26), Color(hex: 0x192030), Color.black]
        }
    }
}

private struct MissingScreenshotView: View {
    let onAdd: () -> Void

    var body: some View {
        Button(action: onAdd) {
            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Theme.ColorToken.orange.opacity(0.55), style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    .frame(width: 180, height: 204)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(Theme.ColorToken.orange)
                            Text("当前设备缺少截图")
                                .font(.caption.weight(.semibold))
                            Text("点击添加")
                                .font(.caption2)
                                .foregroundStyle(Theme.ColorToken.muted)
                        }
                    )
                Text(" ")
                    .font(.caption)
            }
        }
        .buttonStyle(.plain)
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
                    .frame(width: 94, height: 204)
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
