import Foundation
import NativeBridge

extension URL {
    internal static func sandboxPath(directory: FileManager.SearchPathDirectory) -> Self {
        try! FileManager.default.url(
            for: directory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
    }
    
    @inline(__always)
    static var homeDirectory_backport: Self { .init(fileURLWithPath: NSHomeDirectory(), isDirectory: true) }

    @inline(__always)
    static var documentsDirectory_backport: Self { sandboxPath(directory: .documentDirectory) }

    @inline(__always)
    static var temporaryDirectory_backport: Self {
        FileManager.default.temporaryDirectory
    }
}

@available(iOS, deprecated: 16.0, message: "Backport support for this call is unnecessary")
@available(macOS, deprecated: 13.0, message: "Backport support for this call is unnecessary")
@available(tvOS, deprecated: 16.0, message: "Backport support for this call is unnecessary")
@available(watchOS, deprecated: 9.0, message: "Backport support for this call is unnecessary")
public extension URL {
    static var homeDirectory: Self {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            return homeDirectory_native
        } else {
            return homeDirectory_backport
        }
    }
    
    static var documentsDirectory: Self {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            return documentsDirectory_native
        } else {
            return documentsDirectory_backport
        }
    }
    
    static var temporaryDirectory: Self {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            return temporaryDirectory_native
        } else {
            return temporaryDirectory_backport
        }
    }
}
