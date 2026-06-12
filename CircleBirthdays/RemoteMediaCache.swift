import CryptoKit
import Foundation
import SwiftUI
import UIKit

actor RemoteMediaCache {
    static let shared = RemoteMediaCache()

    private let memoryCache = NSCache<NSURL, UIImage>()
    private let urlCache: URLCache

    private init() {
        urlCache = URLCache(
            memoryCapacity: 48 * 1024 * 1024,
            diskCapacity: 512 * 1024 * 1024,
            diskPath: "CircleBirthdaysRemoteMedia"
        )
        memoryCache.countLimit = 240
        memoryCache.totalCostLimit = 96 * 1024 * 1024
    }

    func image(for url: URL, forceRefresh: Bool = false) async throws -> UIImage {
        let key = url as NSURL
        if !forceRefresh, let cached = memoryCache.object(forKey: key) {
            return cached
        }

        var request = URLRequest(url: url)
        request.cachePolicy = forceRefresh ? .reloadIgnoringLocalCacheData : .returnCacheDataElseLoad
        request.timeoutInterval = 30

        if !forceRefresh,
           let cachedResponse = urlCache.cachedResponse(for: request),
           let image = UIImage(data: cachedResponse.data) {
            memoryCache.setObject(image, forKey: key, cost: cachedResponse.data.count)
            return image
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let image = UIImage(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }

        let cachedResponse = CachedURLResponse(response: response, data: data)
        urlCache.storeCachedResponse(cachedResponse, for: request)
        memoryCache.setObject(image, forKey: key, cost: data.count)
        return image
    }

    func preload(urls: [URL], forceRefresh: Bool = false) async {
        for url in Array(Set(urls)) {
            _ = try? await image(for: url, forceRefresh: forceRefresh)
        }
    }

    func refresh(urls: [URL]) async {
        await preload(urls: urls, forceRefresh: true)
    }

    func cachedFileURL(for url: URL, forceRefresh: Bool = false) async throws -> URL {
        let directory = try mediaDirectory()
        let destination = directory.appendingPathComponent(Self.fileName(for: url))
        if !forceRefresh, FileManager.default.fileExists(atPath: destination.path) {
            return destination
        }

        var request = URLRequest(url: url)
        request.cachePolicy = forceRefresh ? .reloadIgnoringLocalCacheData : .returnCacheDataElseLoad
        request.timeoutInterval = 45

        let data: Data
        if !forceRefresh, let cachedResponse = urlCache.cachedResponse(for: request) {
            data = cachedResponse.data
        } else {
            let (downloadedData, response) = try await URLSession.shared.data(for: request)
            urlCache.storeCachedResponse(CachedURLResponse(response: response, data: downloadedData), for: request)
            data = downloadedData
        }

        try data.write(to: destination, options: .atomic)
        return destination
    }

    private func mediaDirectory() throws -> URL {
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let directory = base.appendingPathComponent("CircleBirthdaysRemoteMediaFiles", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    private static func fileName(for url: URL) -> String {
        let digest = SHA256.hash(data: Data(url.absoluteString.utf8))
        let hash = digest.map { String(format: "%02x", $0) }.joined()
        let ext = url.pathExtension.isEmpty ? "bin" : url.pathExtension
        return "\(hash).\(ext)"
    }
}

struct CachedRemoteImage<Content: View, Placeholder: View>: View {
    let url: URL?
    var forceRefresh = false
    @ViewBuilder let content: (Image) -> Content
    @ViewBuilder let placeholder: () -> Placeholder

    @State private var uiImage: UIImage?
    @State private var didFail = false

    var body: some View {
        Group {
            if let uiImage {
                content(Image(uiImage: uiImage))
            } else {
                placeholder()
            }
        }
        .task(id: cacheTaskID) {
            await load()
        }
    }

    private var cacheTaskID: String {
        "\(url?.absoluteString ?? "nil")-\(forceRefresh)"
    }

    private func load() async {
        guard let url else { return }
        do {
            let image = try await RemoteMediaCache.shared.image(for: url, forceRefresh: forceRefresh)
            await MainActor.run {
                uiImage = image
                didFail = false
            }
        } catch {
            await MainActor.run {
                didFail = true
            }
        }
    }
}
