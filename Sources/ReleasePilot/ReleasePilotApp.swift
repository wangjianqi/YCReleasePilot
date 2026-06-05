import AppKit
import SwiftUI

@main
struct ReleasePilotApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.dark)
                .frame(minWidth: 1180, minHeight: 780)
        }
        .defaultSize(width: 1440, height: 920)
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(after: .windowArrangement) {
                Button("切换全屏") {
                    toggleFullScreen()
                }
                .keyboardShortcut("f", modifiers: [.control, .command])
            }
        }
    }

    private func toggleFullScreen() {
        guard let window = NSApp.mainWindow else { return }
        window.toggleFullScreen(nil)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
}
