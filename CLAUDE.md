# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

YCReleasePilot is a native macOS desktop app for App Store release management. It provides a dashboard for managing app metadata, screenshots, builds, review notes, and submission workflows. All data is currently mock data — no real API integrations exist yet.

## Build & Run

This is a pure Swift Package Manager project (no Xcode project). Targets macOS 14+ with Swift 5.9. There is also a `project.yml` for XcodeGen if you need an `.xcodeproj`.

```bash
# Build only
swift build

# Build and run (packages into dist/ReleasePilot.app bundle)
./script/build_and_run.sh

# Debug mode (lldb)
./script/build_and_run.sh --debug
```

The build script (`script/build_and_run.sh`) compiles via `swift build`, then creates a `.app` bundle at `dist/ReleasePilot.app` with a generated Info.plist. Bundle ID: `ai.opensource.ReleasePilot`.

## Architecture

**MVVM with centralized state.** The primary state lives in `ReleaseDashboardViewModel` (`@Observable`), passed down from `RootView`. Additional ViewModels exist for scoped concerns: `SettingsViewModel`, `CopilotViewModel`, `AIProvidersViewModel`, `MembershipViewModel`.

**Swift Observation framework** — uses `@Observable` macro (not Combine's `@Published`/`ObservableObject`). This is a macOS 14+ / Swift 5.9 requirement.

**Three-panel layout:** collapsible sidebar (left) | main content (center) | AI copilot panel (right, hideable). Window has hidden title bar (`.windowStyle(.hiddenTitleBar)`) with min size 1180x780, default 1440x920.

**Page routing:** `MainPage` enum (in `Models/NavigationState.swift`) drives which page view renders in the center panel: Dashboard (`ReleaseCenterView`), Apps (`AppsPageView`), History (`HistoryPageView`), Settings (`SettingsPageView`), Debug (`DebugPageView`).

**Dialog system:** `ActiveDialog` enum (same file) controls modal overlays (BuildDetail, VersionHistory, ReleasePlan) rendered on top of the main content.

**Services layer** (`Services/`): `AppStoreConnectAPIService`, `AppStoreConnectConfigService`, `AppStoreConnectSnapshotCacheService` for ASC integration; `AIProviderService` for LLM providers; `KeychainService` for secrets; `MembershipService`, `CopilotSessionService`, `CopilotMockService`, `LocalAssetCacheService`, `NetworkRequestLogger`, `ToastService`.

**Feature flags:** `FeatureFlag` enum gates unreleased features (AI copilot chat, review risk analysis, batch translation, ASO keywords, multi-app, history analytics).

**Data layer:** `MockData.swift` generates 5 sample apps (FaceBlur, SnapEdit, VideoMagic, TuneFlow, ChatLens) with per-platform release data. All models in `Models/` are value types.

## Key Conventions

- **Zero external dependencies** — only Apple frameworks (SwiftUI, AppKit, Foundation, Observation).
- **Design tokens** in `Support/Theme.swift` (colors, radii, spacing) and `Support/AppStrings.swift` (all UI strings). Use these instead of inline values.
- **Dark-only UI** — forced via `.preferredColorScheme(.dark)` at the app level. Glass-morphism style with deep navy backgrounds (`#07111F`), blue/purple accent gradients, 26pt corner radii.
- **AppKit integration** via `@NSApplicationDelegateAdaptor(AppDelegate.self)` for macOS lifecycle. `NSOpenPanel` used for file picking.
- **Shared components** live in `Views/Shared/` (GlassCard, PrimaryButton, StatusBadge, etc.) — reuse these for consistency.
- **Settings page** uses its own sidebar (`SettingsSidebar.swift`) with sub-views per section (General, AI Providers, App Store Connect, Membership, Privacy, About).
