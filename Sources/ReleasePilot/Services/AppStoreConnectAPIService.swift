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
    var iconImagePath: String?
    var screenshots: [AppStoreConnectScreenshotSnapshot]
}

struct AppStoreConnectBuildSnapshot: Identifiable, Hashable, Codable {
    let id: String
    var version: String
    var uploadedDate: String
    var processingState: String
}

struct AppStoreConnectScreenshotSnapshot: Identifiable, Hashable, Codable {
    let id: String
    var displayType: String
    var locale: String
    var fileName: String
    var width: Int?
    var height: Int?
    var imageTemplateURL: String?
    var cachedImagePath: String?
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
            let versionResources = (try? await versions) ?? []
            let latestVersion = versionResources.first
            let latestBuilds = (try? await builds) ?? []
            async let iconPath = cachedIconPath(from: latestBuilds.first, bundleID: app.attributes.bundleId, token: token)
            async let screenshots = cachedScreenshotSnapshots(from: latestVersion, token: token)
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
                    },
                    iconImagePath: await iconPath,
                    screenshots: await screenshots
                )
            )
        }
        return snapshots
    }

    func refreshStatuses(config: AppStoreConnectConfig, snapshots: [AppStoreConnectAppSnapshot]) async throws -> [AppStoreConnectAppSnapshot] {
        let token = try makeJWT(config: config)
        var refreshed: [AppStoreConnectAppSnapshot] = []

        for snapshot in snapshots {
            async let versions = latestVersions(appID: snapshot.id, token: token)
            async let builds = latestBuilds(appID: snapshot.id, token: token)
            let versionResources = (try? await versions) ?? []
            let latestVersion = versionResources.first
            let latestBuilds = (try? await builds) ?? snapshot.builds.map {
                ASCResource(
                    id: $0.id,
                    attributes: ASCBuildAttributes(
                        version: $0.version,
                        uploadedDate: $0.uploadedDate.isEmpty ? nil : $0.uploadedDate,
                        processingState: $0.processingState
                    )
                )
            }

            var updated = snapshot
            updated.latestVersion = latestVersion?.attributes.versionString ?? snapshot.latestVersion
            updated.appStoreState = latestVersion?.attributes.appStoreState ?? snapshot.appStoreState
            updated.platform = latestVersion?.attributes.platform ?? snapshot.platform
            updated.builds = latestBuilds.map {
                AppStoreConnectBuildSnapshot(
                    id: $0.id,
                    version: $0.attributes.version,
                    uploadedDate: $0.attributes.uploadedDate ?? "",
                    processingState: $0.attributes.processingState ?? "Unknown"
                )
            }
            refreshed.append(updated)
        }

        return refreshed
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

    private func cachedBuildIconPath(from build: ASCResource<ASCBuildAttributes>?, token: String) async -> String? {
        guard let build else { return nil }
        do {
            let response: ASCListResponse<ASCBuildIconAttributes> = try await request(
                path: "/builds/\(build.id)/icons",
                queryItems: [
                    URLQueryItem(name: "fields[buildIcons]", value: "iconAsset,iconType,name,masked")
                ],
                token: token
            )
            guard let icon = response.data.first(where: { $0.attributes.iconType == "APP_STORE" }) ?? response.data.first,
                  let imageURL = resolvedImageURL(from: icon.attributes.iconAsset, preferredWidth: 256)
            else {
                return nil
            }
            let cachedURL = try await LocalAssetCacheService.cacheRemoteImage(
                from: imageURL,
                namespace: "asc-icon-\(build.id)-\(icon.id)",
                session: session
            )
            return cachedURL.path
        } catch {
            return nil
        }
    }

    private func cachedIconPath(from build: ASCResource<ASCBuildAttributes>?, bundleID: String, token: String) async -> String? {
        if let buildIconPath = await cachedBuildIconPath(from: build, token: token) {
            return buildIconPath
        }
        return await cachedPublicAppIconPath(bundleID: bundleID)
    }

    private func cachedPublicAppIconPath(bundleID: String) async -> String? {
        var components = URLComponents(string: "https://itunes.apple.com/lookup")
        components?.queryItems = [
            URLQueryItem(name: "bundleId", value: bundleID)
        ]
        guard let url = components?.url else { return nil }

        do {
            let response: ITunesLookupResponse = try await decodePublicJSON(from: url)
            guard let iconURLString = response.results.first?.artworkUrl512,
                  let iconURL = URL(string: iconURLString)
            else {
                return nil
            }
            let cachedURL = try await LocalAssetCacheService.cacheRemoteImage(
                from: iconURL,
                namespace: "itunes-icon-\(bundleID)",
                session: session
            )
            return cachedURL.path
        } catch {
            return nil
        }
    }

    private func cachedScreenshotSnapshots(from version: ASCResource<ASCAppStoreVersionAttributes>?, token: String) async -> [AppStoreConnectScreenshotSnapshot] {
        guard let version else { return [] }
        return (try? await screenshotSnapshots(appStoreVersionID: version.id, token: token)) ?? []
    }

    private func screenshotSnapshots(appStoreVersionID: String, token: String) async throws -> [AppStoreConnectScreenshotSnapshot] {
        let localizations: ASCListResponse<ASCAppStoreVersionLocalizationAttributes> = try await request(
            path: "/appStoreVersions/\(appStoreVersionID)/appStoreVersionLocalizations",
            queryItems: [
                URLQueryItem(name: "fields[appStoreVersionLocalizations]", value: "locale")
            ],
            token: token
        )

        var snapshots: [AppStoreConnectScreenshotSnapshot] = []
        for localization in localizations.data {
            let sets: ASCListResponse<ASCAppScreenshotSetAttributes> = try await request(
                path: "/appStoreVersionLocalizations/\(localization.id)/appScreenshotSets",
                queryItems: [
                    URLQueryItem(name: "fields[appScreenshotSets]", value: "screenshotDisplayType")
                ],
                token: token
            )
            for set in sets.data {
                let screenshots: ASCListResponse<ASCAppScreenshotAttributes> = try await request(
                    path: "/appScreenshotSets/\(set.id)/appScreenshots",
                    queryItems: [
                        URLQueryItem(name: "fields[appScreenshots]", value: "fileName,imageAsset,assetDeliveryState")
                    ],
                    token: token
                )
                for (index, screenshot) in screenshots.data.enumerated() {
                    let imageAsset = screenshot.attributes.imageAsset
                    let imageURL = resolvedImageURL(from: imageAsset, preferredWidth: preferredScreenshotWidth(for: set.attributes.screenshotDisplayType))
                    let cachedImagePath: String?
                    if let imageURL {
                        cachedImagePath = try? await LocalAssetCacheService.cacheRemoteImage(
                            from: imageURL,
                            namespace: "asc-screenshot-\(screenshot.id)-\(index)",
                            session: session
                        ).path
                    } else {
                        cachedImagePath = nil
                    }
                    snapshots.append(
                        AppStoreConnectScreenshotSnapshot(
                            id: screenshot.id,
                            displayType: set.attributes.screenshotDisplayType,
                            locale: localization.attributes.locale,
                            fileName: screenshot.attributes.fileName,
                            width: imageAsset?.width,
                            height: imageAsset?.height,
                            imageTemplateURL: imageAsset?.templateURL,
                            cachedImagePath: cachedImagePath
                        )
                    )
                }
            }
        }
        return snapshots
    }

    private func resolvedImageURL(from imageAsset: ASCImageAsset?, preferredWidth: Int) -> URL? {
        guard let imageAsset else { return nil }
        let width = imageAsset.width ?? preferredWidth
        let height = imageAsset.height ?? preferredWidth
        let replacements = [
            "{w}": "\(width)",
            "{h}": "\(height)",
            "{f}": "png",
            "{scale}": "1",
            "{quality}": "90",
            "{c}": "0"
        ]
        var template = imageAsset.templateURL
        for (placeholder, value) in replacements {
            template = template.replacingOccurrences(of: placeholder, with: value)
        }
        return URL(string: template)
    }

    private func preferredScreenshotWidth(for displayType: String) -> Int {
        if displayType.contains("IPAD") {
            return 1024
        }
        if displayType.contains("DESKTOP") || displayType.contains("MAC") {
            return 1280
        }
        return 430
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

        await NetworkRequestLogger.shared.logRequestStart(endpoint: path, method: "GET", queryItems: queryItems)
        let startTime = Date()

        do {
            let (data, response) = try await session.data(for: request)
            let duration = Date().timeIntervalSince(startTime)

            guard let httpResponse = response as? HTTPURLResponse else {
                await NetworkRequestLogger.shared.logRequestError(endpoint: path, method: "GET", queryItems: queryItems, errorMessage: "Empty response", duration: duration)
                throw AppStoreConnectAPIError.emptyResponse
            }

            guard (200..<300).contains(httpResponse.statusCode) else {
                let error = try? JSONDecoder().decode(ASCErrorResponse.self, from: data)
                let message = error?.errors.first?.detail ?? error?.errors.first?.title ?? String(data: data, encoding: .utf8) ?? "未知错误"
                await NetworkRequestLogger.shared.logRequestComplete(endpoint: path, method: "GET", queryItems: queryItems, statusCode: httpResponse.statusCode, duration: duration)
                throw AppStoreConnectAPIError.requestFailed(
                    statusCode: httpResponse.statusCode,
                    message: message
                )
            }

            await NetworkRequestLogger.shared.logRequestComplete(endpoint: path, method: "GET", queryItems: queryItems, statusCode: httpResponse.statusCode, duration: duration)
            return try JSONDecoder().decode(Response.self, from: data)
        } catch let error as AppStoreConnectAPIError {
            throw error
        } catch {
            let duration = Date().timeIntervalSince(startTime)
            await NetworkRequestLogger.shared.logRequestError(endpoint: path, method: "GET", queryItems: queryItems, errorMessage: error.localizedDescription, duration: duration)
            throw error
        }
    }

    private func decodePublicJSON<Response: Decodable>(from url: URL) async throws -> Response {
        let (data, response) = try await session.data(from: url)
        if let httpResponse = response as? HTTPURLResponse, !(200..<300).contains(httpResponse.statusCode) {
            throw AppStoreConnectAPIError.requestFailed(statusCode: httpResponse.statusCode, message: "Apple Lookup 请求失败")
        }
        return try JSONDecoder().decode(Response.self, from: data)
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

private struct ASCBuildIconAttributes: Decodable {
    let iconAsset: ASCImageAsset?
    let iconType: String
    let name: String?
    let masked: Bool?
}

private struct ASCAppStoreVersionLocalizationAttributes: Decodable {
    let locale: String
}

private struct ASCAppScreenshotSetAttributes: Decodable {
    let screenshotDisplayType: String
}

private struct ASCAppScreenshotAttributes: Decodable {
    let fileName: String
    let imageAsset: ASCImageAsset?
}

private struct ASCImageAsset: Decodable {
    let width: Int?
    let height: Int?
    let templateURL: String

    enum CodingKeys: String, CodingKey {
        case width
        case height
        case templateURL = "templateUrl"
    }
}

private struct ASCErrorResponse: Decodable {
    let errors: [ASCError]
}

private struct ASCError: Decodable {
    let title: String?
    let detail: String?
}

private struct ITunesLookupResponse: Decodable {
    let results: [ITunesLookupApp]
}

private struct ITunesLookupApp: Decodable {
    let artworkUrl512: String?
}
