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

@available(macOS, deprecated: 10.15, message: "Backport support for this call is unnecessary")
@available(iOS, deprecated: 16.0, message: "Backport support for this call is unnecessary")
@available(tvOS, deprecated: 16.0, message: "Backport support for this call is unnecessary")
@available(watchOS, deprecated: 9.0, message: "Backport support for this call is unnecessary")
extension Date: Strideable {
    public typealias Stride = TimeInterval
    
    public func distance(to other: Date) -> Stride {
        if #available(macOS 10.15, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            return distance_native(to: other)
        } else {
            return distance_backport(to: other)
        }
    }

    public func advanced(by n: Stride) -> Date {
        if #available(macOS 10.15, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            return advanced_native(by: n)
        } else {
            return advanced_backport(by: n)
        }
    }
}
