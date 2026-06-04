import Foundation
import Observation

@Observable
final class ToastService {
    var message: String?

    func show(_ value: String) {
        message = value
    }

    func clear() {
        message = nil
    }
}
