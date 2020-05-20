@_exported import enum GraphQL.Map
@_exported import enum GraphQL.MapError

public final class AnyType : Hashable {
    let type: Any.Type

    public init(_ type: Any.Type) {
        self.type = type
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(String(describing: type))
    }

    public static func == (lhs: AnyType, rhs: AnyType) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

func isProtocol(type: Any.Type) -> Bool {
    let description = String(describing: Swift.type(of: type))
    return description.hasSuffix("Protocol")
}

func fixName(_ name: String) -> String {
    // In Swift 4, String(describing: MyClass.self) appends ' #1' for locally defined classes,
    // which we consider invalid for a type name. Strip this by copying until the first space.
    var workingString = name
    
    if name.hasPrefix("(") {
        workingString = String(name.dropFirst())
    }
    
    var newName: [Character] = []
    for character in workingString {
        if character != " " {
            newName.append(character)
        } else {
            break
        }
    }

    return String(newName)
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

