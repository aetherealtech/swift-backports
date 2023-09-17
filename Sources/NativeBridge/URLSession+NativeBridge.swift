import Foundation

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension URLSession {
    @inline(__always)
    func data_native(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await data(for: request)
    }

    @inline(__always)
    func data_native(from url: URL) async throws -> (Data, URLResponse) {
        try await data(from: url)
    }

    @inline(__always)
    func upload_native(for request: URLRequest, fromFile fileURL: URL) async throws -> (Data, URLResponse) {
        try await upload(for: request, fromFile: fileURL)
    }

    @inline(__always)
    func upload_native(for request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse) {
        try await upload(for: request, from: bodyData)
    }

    @inline(__always)
    func download_native(for request: URLRequest) async throws -> (URL, URLResponse) {
        try await download(for: request)
    }

    @inline(__always)
    func download_native(from url: URL) async throws -> (URL, URLResponse) {
        try await download(from: url)
    }

    @inline(__always)
    func download_native(resumeFrom resumeData: Data) async throws -> (URL, URLResponse) {
        try await download(resumeFrom: resumeData)
    }
}
