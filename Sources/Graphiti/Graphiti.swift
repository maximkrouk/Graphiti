@_exported import enum GraphQL.Map
@_exported import enum GraphQL.MapError

import Foundation

public final class AnyType : Hashable {
    let type: Any.Type

    public init(_ type: Any.Type) {
        self.type = type
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(String(reflecting: type))
    }

    public static func == (lhs: AnyType, rhs: AnyType) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

func isProtocol(type: Any.Type) -> Bool {
    let description = String(describing: Swift.type(of: type))
    return description.hasSuffix("Protocol")
}

func fixedName(for type: Any.Type) -> String {
    return String(reflecting: type)
        .replacingOccurrences(of: " ", with: "")
        .components(separatedBy: ".")   // Separate by namespaces
        .dropFirst()                    // Drop scheme
        .applyLocalFixes()              // Handle braces & unknown contexts
        .joined(separator: "_")         // Join namespacesBack
}

private extension ArraySlice where Element == String {
    func applyLocalFixes() -> [Element] {
        let localContextKey = "unknowncontextat$"
        let localContextName = "LocalContext"
        
        func fix(_ string: String) -> String {
            var output = string.trimmingCharacters(in: ["(", ")"])
            if output.hasPrefix(localContextKey) { output = localContextName }
            return output
        }
        
        var hasLocalContexts = false
        func removeCondition(_ string: String) -> Bool {
            guard string == localContextName else { return false }
            let output = hasLocalContexts
            hasLocalContexts = true
            return output
        }
        
        var output = map(fix)
        output.removeAll(where: removeCondition)
        return output
    }
}

func isEncodable(type: Any.Type) -> Bool {
    if isProtocol(type: type) {
        return true
    }

    if let type = type as? Wrapper.Type {
        return isEncodable(type: type.wrappedType)
    }

    return type is Encodable.Type
}

