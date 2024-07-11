import Foundation

@available(macOS 10.15, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
public extension Date {
    @inline(__always)
    func distance_native(to other: Date) -> Stride {
        distance(to: other)
    }

    @inline(__always)
    func advanced_native(by n: Stride) -> Date {
        advanced(by: n)
    }
}
