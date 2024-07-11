import Foundation

public extension Date {
    @inline(__always)
    func distance_backport(to other: Date) -> TimeInterval {
        other.timeIntervalSince(self)
    }

    @inline(__always)
    func advanced_backport(by n: TimeInterval) -> Date {
        addingTimeInterval(n)
    }
}

public extension Date {
    typealias Stride = TimeInterval
    
    @available(macOS, obsoleted: 10.15, message: "Backport support for this call is unnecessary")
    @available(iOS, obsoleted: 16.0, message: "Backport support for this call is unnecessary")
    @available(tvOS, obsoleted: 16.0, message: "Backport support for this call is unnecessary")
    @available(watchOS, obsoleted: 9.0, message: "Backport support for this call is unnecessary")
    func distance(to other: Date) -> Stride {
        if #available(macOS 10.15, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            return distance_native(to: other)
        } else {
            return distance_backport(to: other)
        }
    }

    @available(macOS, obsoleted: 10.15, message: "Backport support for this call is unnecessary")
    @available(iOS, obsoleted: 16.0, message: "Backport support for this call is unnecessary")
    @available(tvOS, obsoleted: 16.0, message: "Backport support for this call is unnecessary")
    @available(watchOS, obsoleted: 9.0, message: "Backport support for this call is unnecessary")
    func advanced(by n: Stride) -> Date {
        if #available(macOS 10.15, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            return advanced_native(by: n)
        } else {
            return advanced_backport(by: n)
        }
    }
}
