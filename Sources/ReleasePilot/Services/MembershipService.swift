import Foundation
import Observation

@Observable
final class MembershipService {
    private let defaults: UserDefaults
    private let statusKey = "releasepilot.membershipStatus"
    private let dailyUsedKey = "releasepilot.dailyCopilotUsed"
    private let usageDateKey = "releasepilot.dailyCopilotDate"

    var status: MembershipStatus {
        didSet {
            defaults.set(status.rawValue, forKey: statusKey)
        }
    }

    var dailyCopilotUsed: Int {
        didSet {
            defaults.set(dailyCopilotUsed, forKey: dailyUsedKey)
            defaults.set(Self.dayStamp(Date()), forKey: usageDateKey)
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let rawStatus = defaults.string(forKey: statusKey) ?? MembershipStatus.free.rawValue
        status = MembershipStatus(rawValue: rawStatus) ?? .free
        let storedDay = defaults.string(forKey: usageDateKey)
        if storedDay == Self.dayStamp(Date()) {
            dailyCopilotUsed = defaults.integer(forKey: dailyUsedKey)
        } else {
            dailyCopilotUsed = 0
            defaults.set(0, forKey: dailyUsedKey)
            defaults.set(Self.dayStamp(Date()), forKey: usageDateKey)
        }
    }

    var dailyCopilotLimit: Int { 5 }

    var remainingFreeCopilotMessages: Int {
        max(0, dailyCopilotLimit - dailyCopilotUsed)
    }

    var usageLabel: String {
        status.isPaid ? "Pro: Unlimited" : "Free: \(dailyCopilotUsed)/\(dailyCopilotLimit) used today"
    }

    func isAllowed(_ feature: FeatureFlag) -> Bool {
        guard !status.isPaid else { return true }
        switch feature {
        case .aiCopilotChat:
            return true
        case .advancedReviewRisk, .batchTranslation, .asoKeywordOptimization, .multipleApps, .releaseHistoryAnalytics:
            return false
        }
    }

    func canSendCopilotMessage() -> Bool {
        status.isPaid || dailyCopilotUsed < dailyCopilotLimit
    }

    func recordCopilotMessage() {
        guard !status.isPaid else { return }
        dailyCopilotUsed += 1
    }

    func upgradeToPro() {
        status = .pro
    }

    func upgradeToLifetime() {
        status = .lifetime
    }

    func restorePurchases() -> String {
        "暂无可恢复购买"
    }

    func reset() {
        status = .free
        dailyCopilotUsed = 0
    }

    private static func dayStamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
