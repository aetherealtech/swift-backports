#if os(iOS) || os(tvOS) || os(watchOS)

import Combine
import NativeBridge
import SwiftUI
import Synchronization

extension Hashable {
    func erase() -> AnyHashable {
        .init(self)
    }
}

extension Encodable {
    func jsonEncoded() -> String {
        .init(data: try! JSONEncoder().encode(self), encoding: .utf8)!
    }
}

struct RegisteredType: Hashable {
    let name: String
    let decode: ((String) -> AnyHashable?)?
    let encode: ((AnyHashable) -> String)?
    
    static func build<T: Hashable>(type: T.Type) -> Self {
        .init(type: T.self)
    }
    
    init<T: Hashable>(type: T.Type) {
        name = String(reflecting: type)
        
        if let codableType = type as? any (Hashable & Codable).Type {
            decode = { encoded in try? JSONDecoder().decode(codableType, from: encoded.data(using: .utf8)!).erase() }
            encode = { value in (value as! Encodable).jsonEncoded() }
        } else {
            decode = nil
            encode = nil
        }
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        name.hash(into: &hasher)
    }
}

enum NavigationValue: Equatable {
    struct Reified: Equatable {
        let value: AnyHashable
        let type: RegisteredType
    }
    
    struct Encoded: Equatable {
        let typeName: String
        let encoded: String
    }
    
    case reified(Reified)
    case encoded(Encoded)
    
    init<V: Hashable>(_ value: V) {
        self = .reified(.init(value: value, type: .build(type: V.self)))
    }
    
    var reified: Reified? {
        if case let .reified(reified) = self {
            return reified
        }
        
        return nil
    }

    func reify(types: Set<RegisteredType>) -> Self {
        if case let .encoded(encoded) = self {
            guard let type = types.first(where: { type in type.name == encoded.typeName }),
                  let decoded = type.decode?(encoded.encoded) else {
                return self
            }
            
            return .reified(.init(value: decoded, type: type))
        }
        
        return self
    }
}


@available(iOS, introduced: 13.0, deprecated: 16.0, message: "Backport support for this call is unnecessary")
@available(tvOS, introduced: 13.0, deprecated: 16.0, message: "Backport support for this call is unnecessary")
@available(watchOS, introduced: 6.0, deprecated: 9.0, message: "Backport support for this call is unnecessary")
struct NavigationPath_Backport: Equatable {
    typealias Element = NavigationValue
    typealias Iterator = Array<Element>.Iterator

    func makeIterator() -> Iterator {
        values.makeIterator()
    }

    var count: Int { values.count }
    var isEmpty: Bool { values.isEmpty }
    
    var codable: CodableRepresentation?

    init() {
        values = []
        codable = .init(values: [])
    }
    
    subscript(position: Int) -> Element {
        values[position]
    }

    init<S: Sequence>(_ elements: S) where S.Element: Hashable {
        values = elements.map { makeElement($0) }
        codable = nil
    }

    init<S: Sequence>(_ elements: S) where S.Element: Codable & Hashable {
        let type = RegisteredType.build(type: S.Element.self)
        values = elements.map { .reified(.init(value: $0, type: type)) }
        codable = .init(values: elements.map { .init(typeName: type.name, encoded: type.encode!($0)) })
    }

    init(_ codable: CodableRepresentation) {
        self.codable = codable
        values = codable.values.map(NavigationValue.encoded)
    }

    mutating func append<V: Hashable>(_ value: V) {
        values.append(makeElement(value))
        codable = nil
    }

    mutating func append<V: Codable & Hashable>(_ value: V) {
        let type = RegisteredType.build(type: V.self)
        values.append(makeElement(value))
        codable?.values.append(.init(typeName: type.name, encoded: type.encode!(value)))
    }

    mutating func remove(at i: Int) {
        values.remove(at: i)
        codable?.values.remove(at: i)
    }

    struct CodableRepresentation: Codable, Equatable {
        init(from decoder: Decoder) throws {
            var container = try decoder.unkeyedContainer()
            
            var values: [NavigationValue.Encoded] = []
            
            while !container.isAtEnd {
                let type = try container.decode(String.self)
                let value = try container.decode(String.self)
                values.insert(.init(typeName: type, encoded: value), at: 0)
            }
            
            self.init(values: values)
        }
        
        init(values: [NavigationValue.Encoded]) {
            self.values = values
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.unkeyedContainer()
            
            for value in values.reversed() {
                try container.encode(value.typeName)
                try container.encode(value.encoded)
            }
        }
        
        var values: [NavigationValue.Encoded]
    }
    
    private mutating func makeElement<V: Hashable>(_ value: V) -> NavigationValue {
        let type = RegisteredType.build(type: type(of: value))
        return .reified(.init(value: value, type: type))
    }
    
    private var values: [NavigationValue] = []
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
            // Workaround for bug described here: https://stackoverflow.com/questions/68365774/nested-navigationlinks-with-isactive-true-are-not-displaying-correctly
            List {
                NavigationLink(
                    isActive: next.isActive,
                    destination: {
                        Destination(next: next).environmentObject(state)
                    },
                    label: { EmptyView() }
                )
            }.opacity(0.01)
        )
    }
    
    struct Destination: View {
        let next: NavigationState.PathIterator
        
        var body: some View {
            if let value = self.next.value {
                if let reified = state.reify(value: value) {
                    if let viewBuilder = state.viewBuilder(for: reified) {
                        NavigationNode<AnyView>(
                            content: viewBuilder(reified.value),
                            next: self.next.next
                        )
                        .environmentObject(state)
                    } else {
                        let _ = print("""
                        A NavigationLink is presenting a value of type “\(String(describing: type(of: reified.value.base)))” but there is no matching navigationDestination declaration visible from the location of the link. The link cannot be activated.
                        
                        Note: Links search for destinations in any surrounding NavigationStack, then within the same column of a NavigationSplitView.
                        """)
                        EmptyView()
                    }
                } else {
                    let _ = print("""
                    Encoded value messed up
                    """)
                    EmptyView()
                }
                
            } else {
                EmptyView()
            }
        }
        
        @EnvironmentObject var state: NavigationState
    }

    @EnvironmentObject var state: NavigationState
}

@available(iOS, introduced: 13.0, deprecated: 16.0, message: "Backport support for this call is unnecessary")
@available(tvOS, introduced: 13.0, deprecated: 16.0, message: "Backport support for this call is unnecessary")
@available(watchOS, introduced: 6.0, deprecated: 9.0, message: "Backport support for this call is unnecessary")
@MainActor
final class NavigationState: ObservableObject {
    @MainActor
    struct PathIterator {
        nonisolated(unsafe) let value: NavigationValue?
        var next: PathIterator { getNext() }

        var isActive: Binding<Bool> {
            .init(
                get: {
                    value != nil
                },
                set: { newValue in
                    if !newValue {
                        remove()
                    }
                }
            )
        }

        init<Data: MutableCollection & RandomAccessCollection & RangeReplaceableCollection>(
            path: Binding<Data>,
            index: Data.Index
        ) where Data.Element: Hashable {
            let makeValue: (Data.Element) -> NavigationValue.Reified = { value in
                .init(value: value, type: .build(type: Data.Element.self))
            }
            
            let value = index == path.wrappedValue.endIndex ? nil : makeValue(path.wrappedValue[index])
            self.value = value.map(NavigationValue.reified)
            getNext = { .init(path: path, index: path.wrappedValue.index(after: index)) }
            remove = { [value] in
                if path.wrappedValue.indices.contains(index), path.wrappedValue[index] as AnyHashable == value?.value { path.wrappedValue.remove(at: index) }
            }
        }
        
        init(
            path: Binding<NavigationPath_Backport>,
            index: Data.Index
        ) {
            value = index == path.wrappedValue.count ? nil : path.wrappedValue[index]
            getNext = { .init(path: path, index: index + 1) }
            remove = { [value] in
                if index < path.wrappedValue.count, path.wrappedValue[index] == value { path.wrappedValue.remove(at: index) }
            }
        }

        let getNext: () -> PathIterator
        let remove: () -> Void
    }

    private var viewBuilders: [RegisteredType: (AnyHashable) -> AnyView] = [:]

    func reify(value: NavigationValue) -> NavigationValue.Reified? {
        switch value {
            case let .reified(reified):
                return reified
            case let .encoded(encoded):
                guard let type = viewBuilders.keys.first(where: { type in type.name == encoded.typeName }),
                      let decoded = type.decode?(encoded.encoded) else {
                    return nil
                }
                
                return .init(value: decoded, type: type)
        }
    }
    
    func viewBuilder(for value: NavigationValue.Reified) -> ((AnyHashable) -> AnyView)? {
        viewBuilders[value.type]
    }

    func add<D: Hashable, C: View>(viewBuilder: @escaping (D) -> C, for type: D.Type) {
        let registeredType = RegisteredType.build(type: type)
        viewBuilders[registeredType] = { data in .init(viewBuilder(data.base as! D)) }
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
    
    init(
        type: D.Type,
        destination: @escaping (D) -> C
    ) {
        self.type = type
        self.destination = destination
    }

    @EnvironmentObject private var state: NavigationState
    
    private let destination: (D) -> C
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
        self.root = root()
        self.path = .init(path: path, index: 0)
    }

    init(
        path: Binding<Data>,
        @ViewBuilder root: () -> Root
    ) where Data: MutableCollection & RandomAccessCollection & RangeReplaceableCollection, Data.Element: Hashable {
        self.root = root()
        self.path = .init(path: path, index: path.wrappedValue.startIndex)
    }

    var body: some View {
        NavigationView {
            NavigationNode(
                content: root.environmentObject(state),
                next: path
            )
            .environmentObject(state)
        }
        .navigationViewStyle(.stack)
    }

    let root: Root
    let path: NavigationState.PathIterator
    @StateObject_Backport var state = NavigationState()
}

@available(iOS, introduced: 13.0, deprecated: 16.0, message: "Backport support for this call is unnecessary")
@available(tvOS, introduced: 13.0, deprecated: 16.0, message: "Backport support for this call is unnecessary")
@available(watchOS, introduced: 6.0, deprecated: 9.0, message: "Backport support for this call is unnecessary")
public struct NavigationPath: Equatable {
    public typealias Element = AnyHashable
    public typealias Iterator = Array<AnyHashable>.Iterator

    public var count: Int {
        if #available(iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            return (navigationPath as! NavigationPath_Native).count
        } else {
            return (navigationPath as! NavigationPath_Backport).count
        }
    }
    
    public var isEmpty: Bool {
        if #available(iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            return (navigationPath as! NavigationPath_Native).isEmpty
        } else {
            return (navigationPath as! NavigationPath_Backport).isEmpty
        }
    }

    public var codable: CodableRepresentation? {
        if #available(iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            return (navigationPath as! NavigationPath_Native).codable.map(CodableRepresentation.init)
        } else {
            return (navigationPath as! NavigationPath_Backport).codable.map(CodableRepresentation.init)
        }
    }

    public init() {
        if #available(iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            navigationPath = NavigationPath_Native()
        } else {
            navigationPath = NavigationPath_Backport()
        }
    }

    public init<S: Sequence>(_ elements: S) where S.Element: Hashable {
        if #available(iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            navigationPath = NavigationPath_Native(elements)
        } else {
            navigationPath = NavigationPath_Backport(elements)
        }
    }

    public init<S: Sequence>(_ elements: S) where S.Element: Codable & Hashable {
        if #available(iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            navigationPath = NavigationPath_Native(elements)
        } else {
            navigationPath = NavigationPath_Backport(elements)
        }
    }

    public init(_ codable: CodableRepresentation) {
        if #available(iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            navigationPath = NavigationPath_Native(codable.codableRepresentation as! NavigationPath_Native.CodableRepresentation)
        } else {
            navigationPath = NavigationPath_Backport(codable.codableRepresentation as! NavigationPath_Backport.CodableRepresentation)
        }
    }

    public mutating func append<V: Hashable>(_ value: V) {
        if #available(iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            var actualSelf = navigationPath as! NavigationPath_Native
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
            var actualSelf = navigationPath as! NavigationPath_Native
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
            let lhsSelf = lhs.navigationPath as! NavigationPath_Native
            let rhsSelf = rhs.navigationPath as! NavigationPath_Native
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
                try self.init(codableRepresentation: NavigationPath_Native.CodableRepresentation(from: decoder))
            } else {
                try self.init(codableRepresentation: NavigationPath_Backport.CodableRepresentation(from: decoder))
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            if #available(iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
                try (codableRepresentation as! NavigationPath_Native.CodableRepresentation).encode(to: encoder)
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
public struct NavigationStack<Data, Root: View>: View {
    @MainActor
    public init(@ViewBuilder root: () -> Root) where Data == NavigationPath {
        if #available(iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            view = NavigationStack_Native(root: root)
        } else {
            view = NavigationStack_Backport(root: root)
        }
    }

    @MainActor
    public init(
        path: Binding<NavigationPath>,
        @ViewBuilder root: () -> Root
    ) where Data == NavigationPath {
        if #available(iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            let path = Binding(
                get: { path.wrappedValue.navigationPath as! NavigationPath_Native },
                set: { newValue in path.wrappedValue.navigationPath = newValue }
            )
            
            view = NavigationStack_Native(path: path, root: root)
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
            view = NavigationStack_Native(path: path, root: root)
        } else {
            view = NavigationStack_Backport(path: path, root: root)
        }
    }

    public var body: some View {
        if #available(iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            if Data.self == NavigationPath.self {
                (view as! NavigationStack_Native<NavigationPath_Native, Root>)
            } else {
                (view as! NavigationStack_Backport<Data, Root>)
            }
        } else {
            if Data.self == NavigationPath.self {
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
    func navigationDestination<D: Hashable, C: View>(
        for type: D.Type,
        @ViewBuilder destination: @escaping (D) -> C
    ) -> some View {
        if #available(iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            navigationDestination_native(for: type, destination: destination)
        } else {
            navigationDestination_backport(for: type, destination: destination)
        }
    }
}

#endif
