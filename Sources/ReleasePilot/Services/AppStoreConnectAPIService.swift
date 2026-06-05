import CryptoKit
import Foundation
import SwiftUI

struct AppStoreConnectAppSnapshot: Identifiable, Hashable, Codable {
    let id: String
    var name: String
    var bundleID: String
    var sku: String
    var primaryLocale: String
    var latestVersion: String?
    var appStoreState: String?
    var platform: String?
    var builds: [AppStoreConnectBuildSnapshot]
}

struct AppStoreConnectBuildSnapshot: Identifiable, Hashable, Codable {
    let id: String
    var version: String
    var uploadedDate: String
    var processingState: String
}

enum AppStoreConnectAPIError: LocalizedError {
    case missingFields
    case privateKeyNotFound
    case invalidPrivateKey
    case invalidURL
    case emptyResponse
    case requestFailed(statusCode: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .missingFields:
            return "缺少 App Store Connect API Key ID、Issuer ID 或 .p8 Private Key。"
        case .privateKeyNotFound:
            return ".p8 Private Key 文件不存在或无法读取。"
        case .invalidPrivateKey:
            return ".p8 Private Key 无法解析，请确认文件来自 App Store Connect API Keys。"
        case .invalidURL:
            return "App Store Connect API URL 无效。"
        case .emptyResponse:
            return "App Store Connect 返回了空数据。"
        case .requestFailed(let statusCode, let message):
            return "App Store Connect 请求失败（\(statusCode)）：\(message)"
        }
    }
}

final class AppStoreConnectAPIService {
    private let baseURL = URL(string: "https://api.appstoreconnect.apple.com/v1")!
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func listApps(config: AppStoreConnectConfig, limit: Int = 20) async throws -> [AppStoreConnectAppSnapshot] {
        let token = try makeJWT(config: config)
        let response: ASCListResponse<ASCAppAttributes> = try await request(
            path: "/apps",
            queryItems: [
                URLQueryItem(name: "limit", value: "\(limit)"),
                URLQueryItem(name: "fields[apps]", value: "name,bundleId,sku,primaryLocale")
            ],
            token: token
        )

        guard !response.data.isEmpty else {
            throw AppStoreConnectAPIError.emptyResponse
        }

        var snapshots: [AppStoreConnectAppSnapshot] = []
        for app in response.data {
            async let versions = latestVersions(appID: app.id, token: token)
            async let builds = latestBuilds(appID: app.id, token: token)
            let latestVersion = try? await versions.first
            let latestBuilds = (try? await builds) ?? []
            snapshots.append(
                AppStoreConnectAppSnapshot(
                    id: app.id,
                    name: app.attributes.name,
                    bundleID: app.attributes.bundleId,
                    sku: app.attributes.sku,
                    primaryLocale: app.attributes.primaryLocale,
                    latestVersion: latestVersion?.attributes.versionString,
                    appStoreState: latestVersion?.attributes.appStoreState,
                    platform: latestVersion?.attributes.platform,
                    builds: latestBuilds.map {
                        AppStoreConnectBuildSnapshot(
                            id: $0.id,
                            version: $0.attributes.version,
                            uploadedDate: $0.attributes.uploadedDate ?? "",
                            processingState: $0.attributes.processingState ?? "Unknown"
                        )
                    }
                )
            )
        }
        return snapshots
    }

    func testConnection(config: AppStoreConnectConfig) async -> AppStoreConnectConnectionStatus {
        do {
            _ = try await listApps(config: config, limit: 1)
            return .connected
        } catch AppStoreConnectAPIError.missingFields {
            return .missingFields
        } catch {
            return .failed
        }
    }

    private func latestVersions(appID: String, token: String) async throws -> [ASCResource<ASCAppStoreVersionAttributes>] {
        let response: ASCListResponse<ASCAppStoreVersionAttributes> = try await request(
            path: "/apps/\(appID)/appStoreVersions",
            queryItems: [
                URLQueryItem(name: "limit", value: "3"),
                URLQueryItem(name: "fields[appStoreVersions]", value: "versionString,appStoreState,platform")
            ],
            token: token
        )
        return response.data
    }

    private func latestBuilds(appID: String, token: String) async throws -> [ASCResource<ASCBuildAttributes>] {
        let response: ASCListResponse<ASCBuildAttributes> = try await request(
            path: "/apps/\(appID)/builds",
            queryItems: [
                URLQueryItem(name: "limit", value: "5"),
                URLQueryItem(name: "sort", value: "-uploadedDate"),
                URLQueryItem(name: "fields[builds]", value: "version,uploadedDate,processingState")
            ],
            token: token
        )
        return response.data
    }

    private func request<Response: Decodable>(path: String, queryItems: [URLQueryItem], token: String) async throws -> Response {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems
        guard let url = components?.url else {
            throw AppStoreConnectAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let logger = NetworkRequestLogger.shared
        logger.logRequestStart(endpoint: path, method: "GET", queryItems: queryItems)
        let startTime = Date()

        do {
            let (data, response) = try await session.data(for: request)
            let duration = Date().timeIntervalSince(startTime)

            guard let httpResponse = response as? HTTPURLResponse else {
                logger.logRequestError(endpoint: path, method: "GET", queryItems: queryItems, errorMessage: "Empty response", duration: duration)
                throw AppStoreConnectAPIError.emptyResponse
            }

            guard (200..<300).contains(httpResponse.statusCode) else {
                let error = try? JSONDecoder().decode(ASCErrorResponse.self, from: data)
                let message = error?.errors.first?.detail ?? error?.errors.first?.title ?? String(data: data, encoding: .utf8) ?? "未知错误"
                logger.logRequestComplete(endpoint: path, method: "GET", queryItems: queryItems, statusCode: httpResponse.statusCode, duration: duration)
                throw AppStoreConnectAPIError.requestFailed(
                    statusCode: httpResponse.statusCode,
                    message: message
                )
            }

            logger.logRequestComplete(endpoint: path, method: "GET", queryItems: queryItems, statusCode: httpResponse.statusCode, duration: duration)
            return try JSONDecoder().decode(Response.self, from: data)
        } catch let error as AppStoreConnectAPIError {
            throw error
        } catch {
            let duration = Date().timeIntervalSince(startTime)
            logger.logRequestError(endpoint: path, method: "GET", queryItems: queryItems, errorMessage: error.localizedDescription, duration: duration)
            throw error
        }
    }

    private func makeJWT(config: AppStoreConnectConfig) throws -> String {
        let keyID = config.apiKeyID.trimmingCharacters(in: .whitespacesAndNewlines)
        let issuerID = config.issuerID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !keyID.isEmpty, !issuerID.isEmpty, !config.privateKeyFilePath.isEmpty else {
            throw AppStoreConnectAPIError.missingFields
        }
        guard let pem = try? String(contentsOfFile: config.privateKeyFilePath, encoding: .utf8) else {
            throw AppStoreConnectAPIError.privateKeyNotFound
        }
        guard let privateKey = try? P256.Signing.PrivateKey(pemRepresentation: pem) else {
            throw AppStoreConnectAPIError.invalidPrivateKey
        }

        let now = Int(Date().timeIntervalSince1970)
        let header: [String: String] = [
            "alg": "ES256",
            "kid": keyID,
            "typ": "JWT"
        ]
        let payload: [String: Any] = [
            "iss": issuerID,
            "iat": now,
            "exp": now + 20 * 60,
            "aud": "appstoreconnect-v1"
        ]

        let headerData = try JSONSerialization.data(withJSONObject: header, options: [.sortedKeys])
        let payloadData = try JSONSerialization.data(withJSONObject: payload, options: [.sortedKeys])
        let signingInput = "\(base64URLEncoded(headerData)).\(base64URLEncoded(payloadData))"
        let signature = try privateKey.signature(for: Data(signingInput.utf8))
        return "\(signingInput).\(base64URLEncoded(signature.rawRepresentation))"
    }

    private func base64URLEncoded(_ data: Data) -> String {
        data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

private struct ASCListResponse<Attributes: Decodable>: Decodable {
    let data: [ASCResource<Attributes>]
}

private struct ASCResource<Attributes: Decodable>: Decodable {
    let id: String
    let attributes: Attributes
}

private struct ASCAppAttributes: Decodable {
    let name: String
    let bundleId: String
    let sku: String
    let primaryLocale: String
}

private struct ASCAppStoreVersionAttributes: Decodable {
    let versionString: String
    let appStoreState: String
    let platform: String
}

private struct ASCBuildAttributes: Decodable {
    let version: String
    let uploadedDate: String?
    let processingState: String?
}

private struct ASCErrorResponse: Decodable {
    let errors: [ASCError]
}

private struct ASCError: Decodable {
    let title: String?
    let detail: String?
}
