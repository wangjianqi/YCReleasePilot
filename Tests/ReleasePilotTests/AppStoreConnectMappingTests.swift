import Testing
@testable import ReleasePilot

@Suite
struct AppStoreConnectMappingTests {
    @Test
    func appStoreConnectBuildsMapToRealBuildInfoWithoutFabricatedFields() {
        let release = MockData.makeRelease(
            from: snapshot(
                builds: [
                    AppStoreConnectBuildSnapshot(
                        id: "asc-build-001",
                        version: "47",
                        uploadedDate: "2026-06-01T08:30:00-07:00",
                        processingState: "PROCESSING_COMPLETE"
                    )
                ],
                versions: [
                    AppStoreConnectVersionSnapshot(
                        id: "version-210",
                        versionString: "2.1.0",
                        appStoreState: "READY_FOR_REVIEW",
                        platform: "IOS",
                        createdDate: "2026-05-30T10:00:00-07:00"
                    )
                ]
            )
        )

        let builds = release.data(for: .iOS).builds

        #expect(builds.count == 1)
        #expect(builds[0].buildNumber == "47")
        #expect(builds[0].version == "2.1.0")
        #expect(builds[0].size == "ASC 未返回")
        #expect(builds[0].testFlightStatus == "ASC 未返回")
        #expect(builds[0].dataSource == .appStoreConnect)
        #expect(builds[0].validationResults.contains("Build ID：asc-build-001"))
    }

    @Test
    func appStoreConnectSnapshotWithoutBuildsDoesNotGenerateMockBuilds() {
        let release = MockData.makeRelease(
            from: snapshot(builds: [], versions: [])
        )

        #expect(release.app.buildNumber == 0)
        #expect(release.data(for: .iOS).builds.isEmpty)
        #expect(release.data(for: .iPadOS).builds.isEmpty)
        #expect(release.data(for: .macOS).builds.isEmpty)
        #expect(release.history.isEmpty)
    }

    @Test
    func appStoreConnectVersionsMapToRealReleaseHistory() {
        let release = MockData.makeRelease(
            from: snapshot(
                builds: [
                    AppStoreConnectBuildSnapshot(
                        id: "asc-build-050",
                        version: "50",
                        uploadedDate: "2026-05-29T08:30:00-07:00",
                        processingState: "PROCESSING_COMPLETE"
                    )
                ],
                versions: [
                    AppStoreConnectVersionSnapshot(
                        id: "version-300",
                        versionString: "3.0.0",
                        appStoreState: "READY_FOR_SALE",
                        platform: "IOS",
                        createdDate: "2026-06-02T09:00:00-07:00"
                    ),
                    AppStoreConnectVersionSnapshot(
                        id: "version-290",
                        versionString: "2.9.0",
                        appStoreState: "REJECTED",
                        platform: "MAC_OS",
                        createdDate: "2026-05-20T09:00:00-07:00"
                    )
                ]
            )
        )

        #expect(release.history.count == 2)
        #expect(release.history[0].id == "asc-app-1-version-version-300")
        #expect(release.history[0].version == "3.0.0")
        #expect(release.history[0].status == "Ready For Sale")
        #expect(release.history[0].platform == .iOS)
        #expect(release.history[1].version == "2.9.0")
        #expect(release.history[1].status == "Rejected")
        #expect(release.history[1].platform == .macOS)
    }

    @Test
    func dashboardHistoryItemsSortByAppStoreConnectVersionDate() {
        let older = MockData.makeRelease(
            from: snapshot(
                id: "older-app",
                name: "Older App",
                versions: [
                    AppStoreConnectVersionSnapshot(
                        id: "version-old",
                        versionString: "1.0.0",
                        appStoreState: "READY_FOR_SALE",
                        platform: "IOS",
                        createdDate: "2026-04-01T09:00:00-07:00"
                    )
                ]
            )
        )
        let newer = MockData.makeRelease(
            from: snapshot(
                id: "newer-app",
                name: "Newer App",
                versions: [
                    AppStoreConnectVersionSnapshot(
                        id: "version-new",
                        versionString: "2.0.0",
                        appStoreState: "READY_FOR_REVIEW",
                        platform: "IOS",
                        createdDate: "2026-06-01T09:00:00-07:00"
                    )
                ]
            )
        )
        let viewModel = ReleaseDashboardViewModel()
        viewModel.appReleases = [
            older.app.id: older,
            newer.app.id: newer
        ]
        viewModel.appOrder = [older.app.id, newer.app.id]
        viewModel.isUsingAppStoreConnectData = true

        #expect(viewModel.historyItems.map(\.appName) == ["Newer App", "Older App"])
    }

    private func snapshot(
        id: String = "asc-app-1",
        name: String = "ASC Photo App",
        latestVersion: String = "2.1.0",
        appStoreState: String = "READY_FOR_REVIEW",
        platform: String = "IOS",
        builds: [AppStoreConnectBuildSnapshot] = [],
        versions: [AppStoreConnectVersionSnapshot] = []
    ) -> AppStoreConnectAppSnapshot {
        AppStoreConnectAppSnapshot(
            id: id,
            name: name,
            bundleID: "com.example.ascphoto",
            sku: "ASC-PHOTO",
            primaryLocale: "en-US",
            latestVersionID: versions.first?.id,
            latestVersion: latestVersion,
            appStoreState: appStoreState,
            platform: platform,
            appStoreVersions: versions,
            builds: builds,
            iconImagePath: nil,
            screenshots: []
        )
    }
}
