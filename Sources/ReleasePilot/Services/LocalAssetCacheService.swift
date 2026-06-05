import AppKit
import CryptoKit

enum LocalAssetCacheService {
    private static let cacheFolderName = "ReleasePilotAssetCache"

    static func appIcon(for app: AppItem, size: CGFloat) -> NSImage? {
        let pixelSize = max(128, Int(size * 3))
        let fileURL = cacheDirectory()
            .appendingPathComponent("icons", isDirectory: true)
            .appendingPathComponent("\(safeFileName(app.id))-\(pixelSize).png")
        if let image = NSImage(contentsOf: fileURL) {
            return image
        }
        let image = drawAppIcon(app: app, pixelSize: pixelSize)
        return writePNG(image, to: fileURL) ? image : image
    }

    static func screenshot(for item: ScreenshotItem, width: CGFloat, height: CGFloat) -> NSImage? {
        if let path = item.localImagePath, let image = NSImage(contentsOfFile: path) {
            return image
        }

        let pixelWidth = max(240, Int(width * 3))
        let pixelHeight = max(552, Int(height * 3))
        let fileURL = cacheDirectory()
            .appendingPathComponent("screenshots", isDirectory: true)
            .appendingPathComponent("\(safeFileName(item.id))-\(pixelWidth)x\(pixelHeight).png")
        if let image = NSImage(contentsOf: fileURL) {
            return image
        }
        let image = drawScreenshot(item: item, pixelWidth: pixelWidth, pixelHeight: pixelHeight)
        return writePNG(image, to: fileURL) ? image : image
    }

    static func cacheImportedImage(from sourceURL: URL, namespace: String) throws -> URL {
        let ext = sourceURL.pathExtension.isEmpty ? "png" : sourceURL.pathExtension
        let targetDirectory = cacheDirectory().appendingPathComponent("imports", isDirectory: true)
        try FileManager.default.createDirectory(at: targetDirectory, withIntermediateDirectories: true)

        let data = try Data(contentsOf: sourceURL)
        let digest = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
        let fileURL = targetDirectory.appendingPathComponent("\(safeFileName(namespace))-\(digest.prefix(16)).\(ext)")
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            try data.write(to: fileURL, options: [.atomic])
        }
        return fileURL
    }

    private static func cacheDirectory() -> URL {
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let directory = base.appendingPathComponent(cacheFolderName, isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    private static func drawAppIcon(app: AppItem, pixelSize: Int) -> NSImage {
        let size = NSSize(width: pixelSize, height: pixelSize)
        let image = NSImage(size: size)
        image.lockFocus()
        defer { image.unlockFocus() }

        let rect = NSRect(origin: .zero, size: size)
        let path = NSBezierPath(roundedRect: rect, xRadius: CGFloat(pixelSize) * 0.24, yRadius: CGFloat(pixelSize) * 0.24)
        path.addClip()

        let colors = iconColors(for: app.id)
        NSGradient(starting: colors.0, ending: colors.1)?.draw(in: rect, angle: 315)

        NSColor.white.withAlphaComponent(0.12).setFill()
        NSBezierPath(ovalIn: NSRect(x: -CGFloat(pixelSize) * 0.18, y: CGFloat(pixelSize) * 0.58, width: CGFloat(pixelSize) * 0.76, height: CGFloat(pixelSize) * 0.76)).fill()
        NSColor.black.withAlphaComponent(0.14).setFill()
        NSBezierPath(ovalIn: NSRect(x: CGFloat(pixelSize) * 0.56, y: -CGFloat(pixelSize) * 0.12, width: CGFloat(pixelSize) * 0.62, height: CGFloat(pixelSize) * 0.62)).fill()

        let symbolSize = CGFloat(pixelSize) * 0.48
        if let symbol = NSImage(systemSymbolName: app.iconSymbol, accessibilityDescription: app.name) {
            symbol.isTemplate = true
            NSColor.white.set()
            symbol.draw(
                in: NSRect(x: (CGFloat(pixelSize) - symbolSize) / 2, y: (CGFloat(pixelSize) - symbolSize) / 2, width: symbolSize, height: symbolSize),
                from: .zero,
                operation: .sourceOver,
                fraction: 0.96
            )
        } else {
            drawCenteredText(String(app.name.prefix(1)), in: rect, size: CGFloat(pixelSize) * 0.44, weight: .bold)
        }

        return image
    }

    private static func drawScreenshot(item: ScreenshotItem, pixelWidth: Int, pixelHeight: Int) -> NSImage {
        let size = NSSize(width: pixelWidth, height: pixelHeight)
        let image = NSImage(size: size)
        image.lockFocus()
        defer { image.unlockFocus() }

        let rect = NSRect(origin: .zero, size: size)
        let colors = screenshotColors(for: item.styleIndex)
        NSGradient(starting: colors.0, ending: colors.1)?.draw(in: rect, angle: 90)

        let topInset = CGFloat(pixelHeight) * 0.08
        drawText(item.title, in: NSRect(x: 28, y: CGFloat(pixelHeight) - topInset - 64, width: CGFloat(pixelWidth) - 56, height: 48), size: 28, weight: .bold, color: .white, alignment: .center)
        drawText(item.subtitle, in: NSRect(x: 28, y: CGFloat(pixelHeight) - topInset - 105, width: CGFloat(pixelWidth) - 56, height: 34), size: 20, weight: .semibold, color: NSColor.white.withAlphaComponent(0.82), alignment: .center)

        drawPhotoPanel(in: NSRect(x: CGFloat(pixelWidth) * 0.16, y: CGFloat(pixelHeight) * 0.26, width: CGFloat(pixelWidth) * 0.68, height: CGFloat(pixelHeight) * 0.38), seed: item.styleIndex)
        drawBottomControls(in: NSRect(x: 34, y: 44, width: CGFloat(pixelWidth) - 68, height: 68), selected: item.styleIndex % 3)

        if item.hasWarning {
            let badgeRect = NSRect(x: CGFloat(pixelWidth) - 72, y: CGFloat(pixelHeight) - 74, width: 42, height: 42)
            NSColor.systemOrange.setFill()
            NSBezierPath(ovalIn: badgeRect).fill()
            drawCenteredText("!", in: badgeRect.offsetBy(dx: 0, dy: -2), size: 26, weight: .black)
        }

        return image
    }

    private static func drawPhotoPanel(in rect: NSRect, seed: Int) {
        let path = NSBezierPath(roundedRect: rect, xRadius: 24, yRadius: 24)
        path.addClip()
        let start = seed % 2 == 0 ? NSColor(calibratedRed: 0.98, green: 0.72, blue: 0.58, alpha: 1) : NSColor(calibratedRed: 0.49, green: 0.75, blue: 0.94, alpha: 1)
        let end = seed % 2 == 0 ? NSColor(calibratedRed: 0.25, green: 0.18, blue: 0.34, alpha: 1) : NSColor(calibratedRed: 0.08, green: 0.13, blue: 0.24, alpha: 1)
        NSGradient(starting: start, ending: end)?.draw(in: rect, angle: 270)

        NSColor.black.withAlphaComponent(0.24).setFill()
        NSBezierPath(ovalIn: NSRect(x: rect.midX - 56, y: rect.minY + 36, width: 112, height: 112)).fill()
        NSColor(calibratedRed: 1.0, green: 0.78, blue: 0.68, alpha: 1).setFill()
        NSBezierPath(ovalIn: NSRect(x: rect.midX - 42, y: rect.minY + 82, width: 84, height: 84)).fill()
        NSBezierPath(roundedRect: NSRect(x: rect.midX - 56, y: rect.minY + 30, width: 112, height: 72), xRadius: 36, yRadius: 36).fill()

        NSColor.white.withAlphaComponent(0.22).setStroke()
        let line = NSBezierPath()
        line.lineWidth = 4
        line.move(to: NSPoint(x: rect.minX + 28, y: rect.maxY - 36))
        line.line(to: NSPoint(x: rect.maxX - 28, y: rect.maxY - 36))
        line.stroke()
    }

    private static func drawBottomControls(in rect: NSRect, selected: Int) {
        for index in 0..<3 {
            let diameter: CGFloat = index == selected ? 34 : 26
            let x = rect.midX - 47 + CGFloat(index) * 47 - diameter / 2
            let y = rect.midY - diameter / 2
            (index == selected ? NSColor.white : NSColor.white.withAlphaComponent(0.24)).setFill()
            NSBezierPath(ovalIn: NSRect(x: x, y: y, width: diameter, height: diameter)).fill()
        }
    }

    private static func drawText(_ text: String, in rect: NSRect, size: CGFloat, weight: NSFont.Weight, color: NSColor, alignment: NSTextAlignment) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = alignment
        paragraph.lineBreakMode = .byTruncatingTail
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: size, weight: weight),
            .foregroundColor: color,
            .paragraphStyle: paragraph
        ]
        NSString(string: text).draw(in: rect, withAttributes: attributes)
    }

    private static func drawCenteredText(_ text: String, in rect: NSRect, size: CGFloat, weight: NSFont.Weight) {
        drawText(text, in: rect.insetBy(dx: 4, dy: (rect.height - size * 1.28) / 2), size: size, weight: weight, color: .white, alignment: .center)
    }

    private static func writePNG(_ image: NSImage, to url: URL) -> Bool {
        do {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            guard
                let tiff = image.tiffRepresentation,
                let bitmap = NSBitmapImageRep(data: tiff),
                let data = bitmap.representation(using: .png, properties: [:])
            else { return false }
            try data.write(to: url, options: [.atomic])
            return true
        } catch {
            return false
        }
    }

    private static func safeFileName(_ value: String) -> String {
        value
            .lowercased()
            .map { character in
                character.isLetter || character.isNumber ? character : "-"
            }
            .reduce(into: "") { partialResult, character in
                if partialResult.last != "-" || character != "-" {
                    partialResult.append(character)
                }
            }
    }

    private static func iconColors(for id: String) -> (NSColor, NSColor) {
        let palettes: [(NSColor, NSColor)] = [
            (NSColor(calibratedRed: 0.98, green: 0.78, blue: 0.61, alpha: 1), NSColor(calibratedRed: 0.50, green: 0.27, blue: 0.89, alpha: 1)),
            (NSColor(calibratedRed: 0.06, green: 0.72, blue: 0.51, alpha: 1), NSColor(calibratedRed: 0.13, green: 0.83, blue: 0.93, alpha: 1)),
            (NSColor(calibratedRed: 0.99, green: 0.55, blue: 0.24, alpha: 1), NSColor(calibratedRed: 0.49, green: 0.23, blue: 0.93, alpha: 1)),
            (NSColor(calibratedRed: 0.39, green: 0.40, blue: 0.95, alpha: 1), NSColor(calibratedRed: 0.91, green: 0.31, blue: 0.73, alpha: 1))
        ]
        return palettes[abs(id.hashValue) % palettes.count]
    }

    private static func screenshotColors(for index: Int) -> (NSColor, NSColor) {
        switch index % 5 {
        case 1:
            return (NSColor(calibratedRed: 0.13, green: 0.08, blue: 0.18, alpha: 1), NSColor(calibratedRed: 0.08, green: 0.12, blue: 0.19, alpha: 1))
        case 2:
            return (NSColor(calibratedRed: 0.08, green: 0.12, blue: 0.17, alpha: 1), NSColor(calibratedRed: 0.21, green: 0.12, blue: 0.22, alpha: 1))
        case 3:
            return (NSColor(calibratedRed: 0.08, green: 0.18, blue: 0.22, alpha: 1), NSColor(calibratedRed: 0.18, green: 0.10, blue: 0.24, alpha: 1))
        case 4:
            return (NSColor(calibratedRed: 0.07, green: 0.10, blue: 0.18, alpha: 1), NSColor(calibratedRed: 0.16, green: 0.10, blue: 0.30, alpha: 1))
        default:
            return (NSColor(calibratedRed: 0.16, green: 0.10, blue: 0.15, alpha: 1), NSColor(calibratedRed: 0.10, green: 0.13, blue: 0.20, alpha: 1))
        }
    }
}
