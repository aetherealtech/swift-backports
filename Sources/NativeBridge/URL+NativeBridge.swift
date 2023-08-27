import Foundation

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension URL {
    @inline(__always)
    static var homeDirectory_native: Self { homeDirectory }

    @inline(__always)
    static var documentsDirectory_native: Self { documentsDirectory }

    @inline(__always)
    static var temporaryDirectory_native: Self { temporaryDirectory }
}
