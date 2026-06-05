import Foundation
import Observation
import Testing
@testable import ReleasePilot

@MainActor
@Suite(.serialized)
struct NetworkRequestLoggerTests {
    @Test
    func logRequestStartStoresRequestWithoutCrashing() {
        let logger = NetworkRequestLogger.shared
        logger.clearAll()
        logger.logRequestStart(
            endpoint: "v1/apps",
            method: "GET",
            queryItems: [
                URLQueryItem(name: "limit", value: "20"),
                URLQueryItem(name: "fields[apps]", value: "name,bundleId,sku,primaryLocale")
            ]
        )

        #expect(logger.records.count == 1)
        #expect(logger.groups.count == 1)
        #expect(logger.groups.first?.count == 1)
    }

    @Test
    func logRequestStartNotifiesObservedRecordsWithoutCrashing() {
        let logger = NetworkRequestLogger.shared
        logger.clearAll()
        final class NotificationFlag: @unchecked Sendable {
            var didNotify = false
        }
        let flag = NotificationFlag()

        withObservationTracking {
            _ = logger.groups.count
            _ = logger.totalRequestCount
        } onChange: {
            flag.didNotify = true
        }

        logger.logRequestStart(
            endpoint: "v1/apps",
            method: "GET",
            queryItems: [URLQueryItem(name: "limit", value: "20")]
        )

        #expect(flag.didNotify)
        #expect(logger.records.count == 1)
    }

    @Test
    func logRequestStartFromBackgroundQueueIsMarshaledToMainActor() async {
        let logger = NetworkRequestLogger.shared
        logger.clearAll()

        await Task.detached {
            await NetworkRequestLogger.shared.logRequestStart(
                endpoint: "v1/apps",
                method: "GET",
                queryItems: [URLQueryItem(name: "limit", value: "20")]
            )
        }.value

        #expect(logger.records.count == 1)
    }
}
