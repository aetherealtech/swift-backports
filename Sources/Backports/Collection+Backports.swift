import NativeBridge

extension Collection where Element: Equatable {
    func find<C: Collection>(
        other: C,
        index: inout Index
    ) -> Range<Index>? where C.Element == Element {
        guard distance(from: startIndex, to: endIndex) >= other.count else {
            return nil
        }
        
        var matched = true
        
        let startIndex = index
        for otherIndex in other.indices {
            if self[index] != other[otherIndex] {
                matched = false
                break
            }
            
            formIndex(after: &index)
        }
        
        if matched {
            return startIndex ..< index
        } else {
            index = startIndex
            formIndex(after: &index)
            return nil
        }
    }
    
    @inline(__always)
    func firstRange_backport<C: Collection>(of separator: C) -> Range<Self.Index>? where C.Element == Element {
        var index = startIndex
        let endIndex = endIndex

        while index < endIndex {
            if let match = find(other: separator, index: &index) {
                return match
            }
        }

        return nil
    }
    
    @inline(__always)
    func ranges_backport<C: Collection>(of separator: C) -> [Range<Self.Index>] where C.Element == Element {
        var results: [Range<Self.Index>] = []

        var index = startIndex
        let endIndex = endIndex

        while index < endIndex {
            if let match = find(other: separator, index: &index) {
                results.append(match)
            }
        }

        return results
    }
    
    @inline(__always)
    func split_backport<C: Collection>(separator: C, maxSplits: Int = .max, omittingEmptySubsequences: Bool = true) -> [SubSequence] where C.Element == Element {
        let separatorOccurrences = ranges(of: separator)
        
        var results: [SubSequence] = []
        
        var sliceStart = startIndex
        for occurrence in separatorOccurrences {
            let sliceEnd = occurrence.lowerBound
            results.append(self[sliceStart ..< sliceEnd])
            sliceStart = occurrence.upperBound
            
            if results.count == maxSplits {
                break
            }
        }
        
        results.append(self[sliceStart ..< endIndex])
        
        if omittingEmptySubsequences {
            results = results.filter { split in !split.isEmpty }
        }
        
        return results
    }
}

@available(iOS, deprecated: 16.0, message: "Backport support for this call is unnecessary")
@available(macOS, deprecated: 13.0, message: "Backport support for this call is unnecessary")
@available(tvOS, deprecated: 16.0, message: "Backport support for this call is unnecessary")
@available(watchOS, deprecated: 9.0, message: "Backport support for this call is unnecessary")
public extension Collection where Element: Equatable {
    func firstRange<C: Collection>(of separator: C) -> Range<Self.Index>? where C.Element == Element {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            return firstRange_native(of: separator)
        } else {
            return firstRange_backport(of: separator)
        }
    }

    func ranges<C: Collection>(of separator: C) -> [Range<Self.Index>] where C.Element == Element {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            return ranges_native(of: separator)
        } else {
            return ranges_backport(of: separator)
        }
    }

    func split<C: Collection>(separator: C, maxSplits: Int = .max, omittingEmptySubsequences: Bool = true) -> [SubSequence] where C.Element == Element {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            return split_native(separator: separator, maxSplits: maxSplits, omittingEmptySubsequences: omittingEmptySubsequences)
        } else {
            return split_backport(separator: separator, maxSplits: maxSplits, omittingEmptySubsequences: omittingEmptySubsequences)
        }
    }
}
