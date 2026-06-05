import AppKit
import SwiftUI

struct WindowTitleBarDoubleClickInstaller: NSViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        DispatchQueue.main.async {
            context.coordinator.install(from: view)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            context.coordinator.install(from: nsView)
        }
    }

    final class Coordinator: NSObject, NSGestureRecognizerDelegate {
        private enum Metrics {
            static let titleBarHeight: CGFloat = 40
            static let trafficLightReservedWidth: CGFloat = 78
        }

        private weak var frameView: NSView?

        private lazy var doubleClickRecognizer: NSClickGestureRecognizer = {
            let recognizer = NSClickGestureRecognizer(target: self, action: #selector(handleDoubleClick(_:)))
            recognizer.numberOfClicksRequired = 2
            recognizer.delegate = self
            return recognizer
        }()

        func install(from markerView: NSView) {
            guard let targetView = markerView.window?.contentView?.superview else { return }
            guard frameView !== targetView else { return }

            frameView?.removeGestureRecognizer(doubleClickRecognizer)
            targetView.addGestureRecognizer(doubleClickRecognizer)
            frameView = targetView
        }

        @objc private func handleDoubleClick(_ recognizer: NSClickGestureRecognizer) {
            guard recognizer.state == .ended, let window = frameView?.window else { return }
            window.toggleFullScreen(nil)
        }

        func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer, shouldAttemptToRecognizeWith event: NSEvent) -> Bool {
            guard let frameView else { return false }

            let location = frameView.convert(event.locationInWindow, from: nil)
            let distanceFromTop = frameView.bounds.height - location.y
            return distanceFromTop <= Metrics.titleBarHeight
                && location.x > Metrics.trafficLightReservedWidth
        }

        func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: NSGestureRecognizer) -> Bool {
            true
        }
    }
}
