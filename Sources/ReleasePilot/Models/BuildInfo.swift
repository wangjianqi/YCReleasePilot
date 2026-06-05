enum BuildDataSource: String, Hashable {
    case mock
    case appStoreConnect
}

struct BuildInfo: Identifiable, Hashable {
    let id: Int
    var buildNumber: String
    let version: String
    let uploadedAt: String
    let size: String
    let status: String
    var bundleID: String = "com.releasepilot.app"
    var testFlightStatus: String = "Ready to Test"
    var validationResults: [String] = []
    var uploadLogs: [String] = []
    var submissionStatus: String = "Not Submitted"
    var dataSource: BuildDataSource = .mock

    init(
        id: Int,
        buildNumber: String? = nil,
        version: String,
        uploadedAt: String,
        size: String,
        status: String,
        bundleID: String = "com.releasepilot.app",
        testFlightStatus: String = "Ready to Test",
        validationResults: [String] = [],
        uploadLogs: [String] = [],
        submissionStatus: String = "Not Submitted",
        dataSource: BuildDataSource = .mock
    ) {
        self.id = id
        self.buildNumber = buildNumber ?? "\(id)"
        self.version = version
        self.uploadedAt = uploadedAt
        self.size = size
        self.status = status
        self.bundleID = bundleID
        self.testFlightStatus = testFlightStatus
        self.validationResults = validationResults
        self.uploadLogs = uploadLogs
        self.submissionStatus = submissionStatus
        self.dataSource = dataSource
    }
}
