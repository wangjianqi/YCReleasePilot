import AppKit
import Foundation
import Observation

struct AIProviderDraft: Identifiable {
    var id: UUID
    var providerID: UUID?
    var type: AIProviderType
    var displayName: String
    var apiKey: String
    var baseURL: String
    var defaultModel: String
    var isEnabled: Bool
    var useAsDefault: Bool
    var showsAPIKey: Bool

    init(provider: AIProvider? = nil, apiKey: String = "") {
        let type = provider?.type ?? .openAI
        id = UUID()
        providerID = provider?.id
        self.type = type
        displayName = provider?.displayName ?? type.name
        self.apiKey = apiKey
        baseURL = provider?.baseURL ?? type.defaultBaseURL
        defaultModel = provider?.defaultModel ?? type.defaultModel
        isEnabled = provider?.isEnabled ?? true
        useAsDefault = provider?.isDefault ?? false
        showsAPIKey = false
    }

    mutating func applyTypeDefaults() {
        displayName = type.name
        baseURL = type.defaultBaseURL
        defaultModel = type.defaultModel
    }
}

@Observable
final class AIProvidersViewModel {
    var providers: [AIProvider]
    var editingDraft: AIProviderDraft?
    var providerPendingDeletion: AIProvider?
    var testingProviderIDs: Set<UUID> = []

    private let service: AIProviderService
    private let toastService: ToastService

    init(service: AIProviderService = AIProviderService(), toastService: ToastService = ToastService()) {
        self.service = service
        self.toastService = toastService
        providers = service.loadProviders()
    }

    var enabledProviders: [AIProvider] {
        providers.filter(\.isEnabled)
    }

    var defaultProvider: AIProvider? {
        providers.first(where: \.isDefault) ?? enabledProviders.first
    }

    func apiKey(for provider: AIProvider) -> String {
        service.apiKey(for: provider.id)
    }

    func maskedAPIKey(for provider: AIProvider) -> String {
        service.maskedAPIKey(for: provider.id)
    }

    func addProvider() {
        editingDraft = AIProviderDraft()
    }

    func editProvider(_ provider: AIProvider) {
        editingDraft = AIProviderDraft(provider: provider, apiKey: service.apiKey(for: provider.id))
    }

    func saveDraft(_ draft: AIProviderDraft) {
        let providerID = draft.providerID ?? UUID()
        var provider = AIProvider(
            id: providerID,
            type: draft.type,
            displayName: draft.displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? draft.type.name : draft.displayName,
            baseURL: draft.baseURL,
            defaultModel: draft.defaultModel,
            isEnabled: draft.isEnabled,
            isDefault: draft.useAsDefault,
            connectionStatus: draft.apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .notConfigured : .connected
        )
        if providers.isEmpty {
            provider.isDefault = true
        }
        if let index = providers.firstIndex(where: { $0.id == providerID }) {
            providers[index] = provider
        } else {
            providers.append(provider)
        }
        if provider.isDefault {
            setDefault(provider)
        } else {
            persist()
        }
        if !draft.apiKey.isEmpty {
            service.saveAPIKey(draft.apiKey, for: providerID)
        } else {
            service.deleteAPIKey(for: providerID)
        }
        editingDraft = nil
        toastService.show("AI Provider 已保存")
    }

    func requestDelete(_ provider: AIProvider) {
        providerPendingDeletion = provider
    }

    func confirmDeleteProvider() {
        guard let provider = providerPendingDeletion else { return }
        providers.removeAll { $0.id == provider.id }
        service.deleteAPIKey(for: provider.id)
        if !providers.contains(where: \.isDefault), let first = providers.first {
            setDefault(first)
        } else {
            persist()
        }
        providerPendingDeletion = nil
        toastService.show("Provider 已删除")
    }

    func setDefault(_ provider: AIProvider) {
        providers = providers.map { item in
            var copy = item
            copy.isDefault = item.id == provider.id
            return copy
        }
        persist()
    }

    func clearAPIKey(for provider: AIProvider) {
        service.deleteAPIKey(for: provider.id)
        if let index = providers.firstIndex(where: { $0.id == provider.id }) {
            providers[index].connectionStatus = .notConfigured
        }
        persist()
        toastService.show("API Key 已清空")
    }

    func copyAPIKey(for provider: AIProvider) {
        let value = service.apiKey(for: provider.id)
        guard !value.isEmpty else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(value, forType: .string)
        toastService.show("API Key 已复制")
    }

    func testConnection(_ provider: AIProvider) {
        testingProviderIDs.insert(provider.id)
        Task {
            let status = await service.testConnection(for: provider)
            if let index = providers.firstIndex(where: { $0.id == provider.id }) {
                providers[index].connectionStatus = status
            }
            testingProviderIDs.remove(provider.id)
            persist()
            toastService.show(status == .connected ? "连接成功" : status.title)
        }
    }

    func clearAllProviders() {
        providers.removeAll()
        service.clearAllProviders()
        toastService.show("Provider 配置已清空")
    }

    private func persist() {
        service.saveProviders(providers)
    }
}
