import SwiftUI

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
public typealias NavigationPath_Native = NavigationPath

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
public typealias NavigationStack_Native = NavigationStack

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
public extension View {
    func navigationDestination_native<D: Hashable, C: View>(
        for type: D.Type,
        @ViewBuilder destination: @escaping (D) -> C
    ) -> some View {
        navigationDestination(
            for: type,
            destination: destination
        )
    }
}
