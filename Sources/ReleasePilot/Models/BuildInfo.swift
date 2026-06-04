struct BuildInfo: Identifiable, Hashable {
    let id: Int
    let version: String
    let uploadedAt: String
    let size: String
    let status: String
    var bundleID: String = "com.releasepilot.app"
    var testFlightStatus: String = "Ready to Test"
    var validationResults: [String] = []
    var uploadLogs: [String] = []
    var submissionStatus: String = "Not Submitted"
}
