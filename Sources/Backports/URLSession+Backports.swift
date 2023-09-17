import Foundation
import NativeBridge
import Synchronization

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension URLSession {
    @inline(__always)
    func data_backport(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await adaptTask { completionHandler in
            dataTask(with: request, completionHandler: completionHandler)
        }
    }

    @inline(__always)
    func data_backport(from url: URL) async throws -> (Data, URLResponse) {
        try await data_backport(for: .init(url: url))
    }

    @inline(__always)
    func upload_backport(for request: URLRequest, fromFile fileURL: URL) async throws -> (Data, URLResponse) {
        try await adaptTask { completionHandler in
            uploadTask(with: request, fromFile: fileURL, completionHandler: completionHandler)
        }
    }

    @inline(__always)
    func upload_backport(for request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse) {
        try await adaptTask { completionHandler in
            uploadTask(with: request, from: bodyData, completionHandler: completionHandler)
        }
    }

    @inline(__always)
    func download_backport(for request: URLRequest) async throws -> (URL, URLResponse) {
        try await adaptTask { completionHandler in
            downloadTask(with: request, completionHandler: completionHandler)
        }
    }

    @inline(__always)
    func download_backport(from url: URL) async throws -> (URL, URLResponse) {
        try await download_backport(for: .init(url: url))
    }

    @inline(__always)
    func download_backport(resumeFrom resumeData: Data) async throws -> (URL, URLResponse) {
        try await adaptTask { completionHandler in
            downloadTask(withResumeData: resumeData, completionHandler: completionHandler)
        }
    }
  
    @inline(__always)
    private func adaptTask<D>(_ taskFactory: (@escaping @Sendable (D?, URLResponse?, Error?) -> Void) -> URLSessionTask) async throws -> (D, URLResponse) {
        try Task.checkCancellation()
        
        @Synchronized
        var task: URLSessionTask?
        
        return try await withTaskCancellationHandler(
            operation: { [_task] in
                try Task.checkCancellation()
                
                return try await withCheckedThrowingContinuation { continuation in
                    _task.wrappedValue = taskFactory { data, response, error in
                        guard let data, let response else {
                            continuation.resume(throwing: error!)
                            return
                        }
                        
                        continuation.resume(returning: (data, response))
                    }
                }
            },
            onCancel: { [_task] in _task.wrappedValue?.cancel() }
        )
    }
}

@available(macOS, introduced: 10.15, deprecated: 13.0, message: "Backport support for this call is unnecessary")
@available(iOS, introduced: 13.0, deprecated: 16.0, message: "Backport support for this call is unnecessary")
@available(tvOS, introduced: 13.0, deprecated: 16.0, message: "Backport support for this call is unnecessary")
@available(watchOS, introduced: 6.0, deprecated: 9.0, message: "Backport support for this call is unnecessary")
public extension URLSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            return try await data_native(for: request)
        } else {
            return try await data_backport(for: request)
        }
    }

    func data(from url: URL) async throws -> (Data, URLResponse) {
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            return try await data_native(from: url)
        } else {
            return try await data_backport(from: url)
        }
    }

    func upload(for request: URLRequest, fromFile fileURL: URL) async throws -> (Data, URLResponse) {
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            return try await upload_native(for: request, fromFile: fileURL)
        } else {
            return try await upload_backport(for: request, fromFile: fileURL)
        }
    }

    func upload(for request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse) {
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            return try await upload_native(for: request, from: bodyData)
        } else {
            return try await upload_backport(for: request, from: bodyData)
        }
    }

    func download(for request: URLRequest) async throws -> (URL, URLResponse) {
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            return try await download_native(for: request)
        } else {
            return try await download_backport(for: request)
        }
    }

    func download(from url: URL) async throws -> (URL, URLResponse) {
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            return try await download_native(from: url)
        } else {
            return try await download_backport(from: url)
        }
    }

    func download(resumeFrom resumeData: Data) async throws -> (URL, URLResponse) {
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            return try await download_native(resumeFrom: resumeData)
        } else {
            return try await download_backport(resumeFrom: resumeData)
        }
    }
}
