import Foundation
import Observation

@Observable
final class MembershipViewModel {
    let service: MembershipService
    private let toastService: ToastService

    var showingPaywall = false

    init(service: MembershipService = MembershipService(), toastService: ToastService = ToastService()) {
        self.service = service
        self.toastService = toastService
    }

    var status: MembershipStatus {
        service.status
    }

    var usageLabel: String {
        service.usageLabel
    }

    var canSendCopilotMessage: Bool {
        service.canSendCopilotMessage()
    }

    func isAllowed(_ feature: FeatureFlag) -> Bool {
        service.isAllowed(feature)
    }

    func openPaywall() {
        showingPaywall = true
    }

    func upgradeToPro() {
        service.upgradeToPro()
        showingPaywall = false
        toastService.show("已切换为 Pro")
    }

    func upgradeToLifetime() {
        service.upgradeToLifetime()
        showingPaywall = false
        toastService.show("已切换为 Lifetime")
    }

    func restorePurchases() {
        toastService.show(service.restorePurchases())
    }
}
