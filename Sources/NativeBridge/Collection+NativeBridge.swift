@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension Collection where Element: Equatable {
    @inline(__always)
    func firstRange_native<C: Collection>(of separator: C) -> Range<Self.Index>? where C.Element == Element {
        firstRange(of: separator)
    }

    @inline(__always)
    func ranges_native<C: Collection>(of separator: C) -> [Range<Self.Index>] where C.Element == Element {
        ranges(of: separator)
    }

    @inline(__always)
    func split_native<C: Collection>(separator: C, maxSplits: Int = .max, omittingEmptySubsequences: Bool = true) -> [SubSequence] where C.Element == Element {
        split(separator: separator, maxSplits: maxSplits, omittingEmptySubsequences: omittingEmptySubsequences)
    }
}
