import Foundation
import Testing
@testable import ReleasePilot

struct AIProviderServiceTests {
    @Test
    func loadProvidersCreatesXiaomiProviderFromEnvironment() {
        let defaults = UserDefaults(suiteName: "AIProviderServiceTests.creates.\(UUID().uuidString)")!
        let service = AIProviderService(defaults: defaults, environment: ["XIAO_API_KEY": "tp-test-key"])

        let providers = service.loadProviders()

        #expect(providers.count == 1)
        #expect(providers.first?.type == .xiaomi)
        #expect(providers.first?.baseURL == "https://token-plan-sgp.xiaomimimo.com/v1")
        #expect(providers.first?.defaultModel == "mimo-v2.5-pro")
        #expect(providers.first?.isDefault == true)
    }

    @Test
    func loadProvidersAppendsXiaomiProviderWithoutReplacingExistingDefault() {
        let defaults = UserDefaults(suiteName: "AIProviderServiceTests.appends.\(UUID().uuidString)")!
        let service = AIProviderService(defaults: defaults, environment: ["XIAO_API_KEY": "tp-test-key"])
        let existing = AIProvider(type: .openAI, isEnabled: true, isDefault: true)
        service.saveProviders([existing])

        let providers = service.loadProviders()

        #expect(providers.count == 2)
        #expect(providers.first(where: { $0.type == .openAI })?.isDefault == true)
        #expect(providers.first(where: { $0.type == .xiaomi })?.isDefault == false)
    }
}
