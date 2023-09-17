#if os(iOS) || os(tvOS) || os(watchOS)

import Combine
import SwiftUI

@available(iOS, introduced: 13.0, deprecated: 16.0, message: "Backport support for this call is unnecessary")
@available(tvOS, introduced: 13.0, deprecated: 16.0, message: "Backport support for this call is unnecessary")
@available(watchOS, introduced: 6.0, deprecated: 9.0, message: "Backport support for this call is unnecessary")
struct NavigationPath_Backport: MutableCollection, RandomAccessCollection, RangeReplaceableCollection, Equatable {
    typealias Element = AnyHashable
    typealias Iterator = Array<AnyHashable>.Iterator

    func makeIterator() -> Array<AnyHashable>.Iterator {
        values.makeIterator()
    }

    var startIndex: Int { values.startIndex }
    var endIndex: Int { values.endIndex }

    subscript(position: Index) -> AnyHashable {
        get { values[position] }
        set { values[position] = newValue }
    }

    var codable: CodableRepresentation? { fatalError() }

    init() {
        values = []
    }

    init<S: Sequence>(_ elements: S) where S.Element: Hashable {
        values = elements.map(AnyHashable.init)
    }

    init<S: Sequence>(_ elements: S) where S.Element: Codable & Hashable {
        values = elements.map(AnyHashable.init)
    }

    init(_ codable: CodableRepresentation) {
        fatalError()
    }

    mutating func append<V: Hashable>(_ value: V) {
        values.append(.init(value))
    }

    mutating func append<V: Codable & Hashable>(_ value: V) {
        values.append(.init(value))
    }

    mutating func replaceSubrange<C: Collection>(_ subrange: Range<Int>, with newElements: C) where C.Element: Hashable {
        values.replaceSubrange(subrange, with: newElements.map(AnyHashable.init))
    }

    public struct CodableRepresentation: Codable, Equatable {
        
    }

    private var values: [AnyHashable]
}

@available(iOS, introduced: 13.0, deprecated: 16.0, message: "Backport support for this call is unnecessary")
@available(tvOS, introduced: 13.0, deprecated: 16.0, message: "Backport support for this call is unnecessary")
@available(watchOS, introduced: 6.0, deprecated: 9.0, message: "Backport support for this call is unnecessary")
struct NavigationNode<Content: View>: View {
    let content: Content
    let next: NavigationState.PathIterator

    init(
        content: Content,
        next: NavigationState.PathIterator
    ) {
        self.content = content
        self.next = next
    }

    var body: some View {
        content.background(
            NavigationLink(
                isActive: next.isActive,
                destination: { destination },
                label: { EmptyView() }
            )
        )
    }

    @ViewBuilder
    private var destination: some View {
        if let value = self.next.value {
            NavigationNode<AnyView>(
                content: state.viewBuilder(for: value)!(value),
                next: self.next.next
            )
            .environmentObject(state)
        } else {
            EmptyView()
        }
    }

    @EnvironmentObject var state: NavigationState
}

@available(iOS, introduced: 13.0, deprecated: 16.0, message: "Backport support for this call is unnecessary")
@available(tvOS, introduced: 13.0, deprecated: 16.0, message: "Backport support for this call is unnecessary")
@available(watchOS, introduced: 6.0, deprecated: 9.0, message: "Backport support for this call is unnecessary")
final class NavigationState: ObservableObject {
    struct PathIterator {
        let value: AnyHashable?
        var next: PathIterator { getNext() }

        var isActive: Binding<Bool> {
            .init(
                get: { value != nil },
                set: { newValue in
                    if !newValue {
                        remove()
                    }
                }
            )
        }

        init<Data: MutableCollection & RandomAccessCollection & RangeReplaceableCollection>(path: Binding<Data>, index: Data.Index) where Data.Element: Hashable {
            value = index == path.wrappedValue.endIndex ? nil : path.wrappedValue[index]
            getNext = { .init(path: path, index: path.wrappedValue.index(after: index)) }
            remove = { [value] in
                if path.wrappedValue.indices.contains(index), path.wrappedValue[index] as AnyHashable == value { path.wrappedValue.remove(at: index) }
            }
        }

        let getNext: () -> PathIterator
        let remove: () -> Void
    }

    private var viewBuilders: [String: (any Hashable) -> AnyView] = [:]

    init() {
        print("Hello!")
    }
    
    func viewBuilder(for value: AnyHashable) -> ((any Hashable) -> AnyView)? {
        viewBuilders[String(reflecting: type(of: value.base))]
    }

    func add<D: Hashable, C: View>(viewBuilder: @escaping (D) -> C, for type: D.Type) {
        viewBuilders[String(reflecting: type)] = { data in .init(viewBuilder(data as! D)) }
    }
}

@available(iOS, introduced: 13.0, deprecated: 16.0, message: "Backport support for this call is unnecessary")
@available(tvOS, introduced: 13.0, deprecated: 16.0, message: "Backport support for this call is unnecessary")
@available(watchOS, introduced: 6.0, deprecated: 9.0, message: "Backport support for this call is unnecessary")
@propertyWrapper
struct StateObject_Backport<T: ObservableObject>: DynamicProperty {
    final class OptionalObservableObject: ObservableObject {
        var value: T? {
            didSet {
                subscription = value?
                    .objectWillChange
                    .sink { [unowned self] _ in objectWillChange.send() }
            }
        }
        
        init() {
            print("TEST")
        }
        
        private var subscription: AnyCancellable?
    }
    
    @MainActor
    var wrappedValue: T {
        if let value = observedObject.value {
            return value
        }
        if let value = state.value {
            observedObject.value = value
            return value
        }

        let value = initialize()
        self.state.value = value
        return value
    }
    
    init(wrappedValue initialize: @autoclosure @escaping () -> T) {
        self.initialize = initialize
    }
    
    @ObservedObject private var observedObject = OptionalObservableObject()
    @State private var state = OptionalObservableObject()
    
    private let initialize: () -> T
}

@available(iOS, introduced: 13.0, deprecated: 16.0, message: "Backport support for this call is unnecessary")
@available(tvOS, introduced: 13.0, deprecated: 16.0, message: "Backport support for this call is unnecessary")
@available(watchOS, introduced: 6.0, deprecated: 9.0, message: "Backport support for this call is unnecessary")
struct NavigationDestinationModifier<D: Hashable, C: View>: ViewModifier {
    func body(content: Content) -> some View {
        state.add(viewBuilder: destination, for: type)
        return content
            .environmentObject(state)
    }

    let type: D.Type
    let destination: (D) -> C

    @EnvironmentObject private var state: NavigationState
}

@available(iOS, introduced: 13.0, deprecated: 16.0, message: "Backport support for this call is unnecessary")
@available(tvOS, introduced: 13.0, deprecated: 16.0, message: "Backport support for this call is unnecessary")
@available(watchOS, introduced: 6.0, deprecated: 9.0, message: "Backport support for this call is unnecessary")
extension View {
    func navigationDestination_backport<D: Hashable, C: View>(
        for type: D.Type,
        @ViewBuilder destination: @escaping (D) -> C
    ) -> some View {
        modifier(NavigationDestinationModifier<D, C>(type: type, destination: destination))
    }
}

@available(iOS, introduced: 13.0, deprecated: 16.0, message: "Backport support for this call is unnecessary")
@available(tvOS, introduced: 13.0, deprecated: 16.0, message: "Backport support for this call is unnecessary")
@available(watchOS, introduced: 6.0, deprecated: 9.0, message: "Backport support for this call is unnecessary")
@MainActor
struct NavigationStack_Backport<Data, Root: View>: View {
    init(
        @ViewBuilder root: () -> Root
    ) where Data == NavigationPath_Backport {
        self.init(
            path: .constant(.init()),
            root: root
        )
    }

    init(
        path: Binding<NavigationPath_Backport>,
        @ViewBuilder root: () -> Root
    ) where Data == NavigationPath_Backport {
        content = { [root = root()] in
            NavigationNode(
                content: root,
                next: .init(path: path, index: path.wrappedValue.startIndex)
            )
        }
    }

    init(
        path: Binding<Data>,
        @ViewBuilder root: () -> Root
    ) where Data: MutableCollection & RandomAccessCollection & RangeReplaceableCollection, Data.Element: Hashable {
        content = { [root = root()] in
            NavigationNode(
                content: root,
                next: .init(path: path, index: path.wrappedValue.startIndex)
            )
        }
    }

    var body: some View {
        NavigationView { content().environmentObject(state) }
            .navigationViewStyle(.stack)
    }

    let content: () -> NavigationNode<Root>
    @StateObject_Backport var state = NavigationState()
}

@available(iOS, introduced: 13.0, deprecated: 16.0, message: "Backport support for this call is unnecessary")
@available(tvOS, introduced: 13.0, deprecated: 16.0, message: "Backport support for this call is unnecessary")
@available(watchOS, introduced: 6.0, deprecated: 9.0, message: "Backport support for this call is unnecessary")
public struct NavigationPath_Compat: Equatable {
    public typealias Element = AnyHashable
    public typealias Iterator = Array<AnyHashable>.Iterator

    public var count: Int {
        if #available(iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            return (navigationPath as! NavigationPath).count
        } else {
            return (navigationPath as! NavigationPath_Backport).count
        }
    }
    
    public var isEmpty: Bool {
        if #available(iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            return (navigationPath as! NavigationPath).isEmpty
        } else {
            return (navigationPath as! NavigationPath_Backport).isEmpty
        }
    }

    public var codable: CodableRepresentation? {
        if #available(iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            return (navigationPath as! NavigationPath).codable.map(CodableRepresentation.init)
        } else {
            return (navigationPath as! NavigationPath_Backport).codable.map(CodableRepresentation.init)
        }
    }

    public init() {
        if #available(iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            navigationPath = NavigationPath()
        } else {
            navigationPath = NavigationPath_Backport()
        }
    }

    public init<S: Sequence>(_ elements: S) where S.Element: Hashable {
        if #available(iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            navigationPath = NavigationPath(elements)
        } else {
            navigationPath = NavigationPath_Backport(elements)
        }
    }

    public init<S: Sequence>(_ elements: S) where S.Element: Codable & Hashable {
        if #available(iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            navigationPath = NavigationPath(elements)
        } else {
            navigationPath = NavigationPath_Backport(elements)
        }
    }

    public init(_ codable: CodableRepresentation) {
        if #available(iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            navigationPath = NavigationPath(codable.codableRepresentation as! NavigationPath.CodableRepresentation)
        } else {
            navigationPath = NavigationPath_Backport(codable.codableRepresentation as! NavigationPath_Backport.CodableRepresentation)
        }
    }

    public mutating func append<V: Hashable>(_ value: V) {
        if #available(iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            var actualSelf = navigationPath as! NavigationPath
            actualSelf.append(value)
            navigationPath = actualSelf
        } else {
            var actualSelf = navigationPath as! NavigationPath_Backport
            actualSelf.append(value)
            navigationPath = actualSelf
        }
    }

    public mutating func append<V: Codable & Hashable>(_ value: V) {
        if #available(iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            var actualSelf = navigationPath as! NavigationPath
            actualSelf.append(value)
            navigationPath = actualSelf
        } else {
            var actualSelf = navigationPath as! NavigationPath_Backport
            actualSelf.append(value)
            navigationPath = actualSelf
        }
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        if #available(iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            let lhsSelf = lhs.navigationPath as! NavigationPath
            let rhsSelf = rhs.navigationPath as! NavigationPath
            return lhsSelf == rhsSelf
        } else {
            let lhsSelf = lhs.navigationPath as! NavigationPath_Backport
            let rhsSelf = rhs.navigationPath as! NavigationPath_Backport
            return lhsSelf == rhsSelf
        }
    }

    public struct CodableRepresentation: Codable {
        public init(from decoder: Decoder) throws {
            if #available(iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
                try self.init(codableRepresentation: NavigationPath.CodableRepresentation(from: decoder))
            } else {
                try self.init(codableRepresentation: NavigationPath_Backport.CodableRepresentation(from: decoder))
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            if #available(iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
                try (codableRepresentation as! NavigationPath.CodableRepresentation).encode(to: encoder)
            } else {
                try (codableRepresentation as! NavigationPath_Backport.CodableRepresentation).encode(to: encoder)
            }
        }
        
        init(codableRepresentation: Any) {
            self.codableRepresentation = codableRepresentation
        }
        
        var codableRepresentation: Any
    }

    var navigationPath: Any
}

@available(iOS, introduced: 13.0, deprecated: 16.0, message: "Backport support for this call is unnecessary")
@available(tvOS, introduced: 13.0, deprecated: 16.0, message: "Backport support for this call is unnecessary")
@available(watchOS, introduced: 6.0, deprecated: 9.0, message: "Backport support for this call is unnecessary")
@MainActor
public struct NavigationStack_Compat<Data, Root: View>: View {
    @MainActor
    public init(@ViewBuilder root: () -> Root) where Data == NavigationPath_Compat {
        if #available(iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            view = NavigationStack(root: root)
        } else {
            view = NavigationStack_Backport(root: root)
        }
    }

    @MainActor
    public init(
        path: Binding<NavigationPath_Compat>,
        @ViewBuilder root: () -> Root
    ) where Data == NavigationPath_Compat {
        if #available(iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            let path = Binding(
                get: { path.wrappedValue.navigationPath as! NavigationPath },
                set: { newValue in path.wrappedValue.navigationPath = newValue }
            )
            
            view = NavigationStack(path: path, root: root)
        } else {
            let path = Binding(
                get: { path.wrappedValue.navigationPath as! NavigationPath_Backport },
                set: { newValue in path.wrappedValue.navigationPath = newValue }
            )
            
            view = NavigationStack_Backport(path: path, root: root)
        }
    }

    @MainActor
    public init(
        path: Binding<Data>,
        @ViewBuilder root: () -> Root
    ) where Data: MutableCollection & RandomAccessCollection & RangeReplaceableCollection, Data.Element: Hashable {
        if #available(iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            view = NavigationStack(path: path, root: root)
        } else {
            view = NavigationStack_Backport(path: path, root: root)
        }
    }

    public var body: some View {
        if #available(iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            if Data.self == NavigationPath_Compat.self {
                (view as! NavigationStack<NavigationPath, Root>)
            } else {
                (view as! NavigationStack<Data, Root>)
            }
        } else {
            if Data.self == NavigationPath_Compat.self {
                (view as! NavigationStack_Backport<NavigationPath_Backport, Root>)
            } else {
                (view as! NavigationStack_Backport<Data, Root>)
            }
        }
    }

    private let view: Any
}

@available(iOS, introduced: 13.0, deprecated: 16.0, message: "Backport support for this call is unnecessary")
@available(tvOS, introduced: 13.0, deprecated: 16.0, message: "Backport support for this call is unnecessary")
@available(watchOS, introduced: 6.0, deprecated: 9.0, message: "Backport support for this call is unnecessary")
public extension View {
    @ViewBuilder
    func navigationDestination_compat<D: Hashable, C: View>(
        for type: D.Type,
        @ViewBuilder destination: @escaping (D) -> C
    ) -> some View {
        if #available(iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            navigationDestination(for: type, destination: destination)
        } else {
            navigationDestination_backport(for: type, destination: destination)
        }
    }
}

#endif
