import Foundation
import Observation

struct APIRequestRecord: Identifiable {
    let id = UUID()
    let endpoint: String
    let method: String
    let queryItems: [String: String]
    let timestamp: Date
    let statusCode: Int?
    let errorMessage: String?
    let duration: TimeInterval?

    /// 去重 key：相同接口 + 相同参数视为同一个请求
    var deduplicationKey: String {
        let sortedParams = queryItems.sorted { $0.key < $1.key }
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
        return "\(method) \(endpoint)\(sortedParams.isEmpty ? "" : "?\(sortedParams)")"
    }

    var isDuplicate: Bool {
        // 由 NetworkRequestLogger 在聚合时判断
        false
    }
}

struct APIRequestGroup: Identifiable {
    let id: String // deduplicationKey
    let endpoint: String
    let method: String
    let queryItems: [String: String]
    var records: [APIRequestRecord]
    var count: Int { records.count }
    var isDuplicate: Bool { count > 1 }
    var lastStatusCode: Int? { records.last?.statusCode }
    var lastErrorMessage: String? { records.last?.errorMessage }
    var lastDuration: TimeInterval? { records.last?.duration }
    var lastTimestamp: Date? { records.last?.timestamp }

    /// 重复严重程度
    var severity: DuplicateSeverity {
        switch count {
        case 0...1: .none
        case 2: .warning
        case 3...4: .serious
        default: .critical
        }
    }
}

enum DuplicateSeverity: Int, Comparable {
    case none = 0
    case warning = 1
    case serious = 2
    case critical = 3

    var label: String {
        switch self {
        case .none: ""
        case .warning: "重复请求"
        case .serious: "严重重复"
        case .critical: "极高风险"
        }
    }

    var color: String {
        switch self {
        case .none: ""
        case .warning: "orange"
        case .serious: "red"
        case .critical: "red"
        }
    }

    static func < (lhs: DuplicateSeverity, rhs: DuplicateSeverity) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

@MainActor
@Observable
final class NetworkRequestLogger {
    static let shared = NetworkRequestLogger()

    private(set) var records: [APIRequestRecord] = []
    private(set) var groups: [APIRequestGroup] = []

    private init() {}

    /// 记录请求开始
    func logRequestStart(endpoint: String, method: String, queryItems: [URLQueryItem]) {
        let params = Dictionary(uniqueKeysWithValues: queryItems.compactMap { item -> (String, String)? in
            guard let value = item.value else { return nil }
            return (item.name, value)
        })
        let record = APIRequestRecord(
            endpoint: endpoint,
            method: method,
            queryItems: params,
            timestamp: Date(),
            statusCode: nil,
            errorMessage: nil,
            duration: nil
        )
        records.append(record)
        rebuildGroups()
    }

    /// 记录请求完成
    func logRequestComplete(endpoint: String, method: String, queryItems: [URLQueryItem], statusCode: Int, duration: TimeInterval) {
        let params = Dictionary(uniqueKeysWithValues: queryItems.compactMap { item -> (String, String)? in
            guard let value = item.value else { return nil }
            return (item.name, value)
        })
        let record = APIRequestRecord(
            endpoint: endpoint,
            method: method,
            queryItems: params,
            timestamp: Date(),
            statusCode: statusCode,
            errorMessage: nil,
            duration: duration
        )
        records.append(record)
        rebuildGroups()
    }

    /// 记录请求失败
    func logRequestError(endpoint: String, method: String, queryItems: [URLQueryItem], errorMessage: String, duration: TimeInterval) {
        let params = Dictionary(uniqueKeysWithValues: queryItems.compactMap { item -> (String, String)? in
            guard let value = item.value else { return nil }
            return (item.name, value)
        })
        let record = APIRequestRecord(
            endpoint: endpoint,
            method: method,
            queryItems: params,
            timestamp: Date(),
            statusCode: nil,
            errorMessage: errorMessage,
            duration: duration
        )
        records.append(record)
        rebuildGroups()
    }

    /// 清空所有记录
    func clearAll() {
        records.removeAll()
        groups.removeAll()
    }

    /// 总请求数
    var totalRequestCount: Int {
        records.count
    }

    /// 重复请求数（请求次数 > 1 的分组数）
    var duplicateGroupCount: Int {
        groups.filter { $0.isDuplicate }.count
    }

    /// 最高严重程度
    var maxSeverity: DuplicateSeverity {
        groups.map(\.severity).max() ?? .none
    }

    // MARK: - Private

    private func rebuildGroups() {
        var groupDict: [String: APIRequestGroup] = [:]
        for record in records {
            let key = record.deduplicationKey
            if var group = groupDict[key] {
                group.records.append(record)
                groupDict[key] = group
            } else {
                groupDict[key] = APIRequestGroup(
                    id: key,
                    endpoint: record.endpoint,
                    method: record.method,
                    queryItems: record.queryItems,
                    records: [record]
                )
            }
        }
        groups = Array(groupDict.values)
            .sorted { ($0.lastTimestamp ?? .distantPast) > ($1.lastTimestamp ?? .distantPast) }
    }
}
