import GraphQL

public class QLValueComponent<EnumType : Encodable & RawRepresentable> : Descriptable, Deprecatable where EnumType.RawValue == String {
    var description: String?
    var deprecationReason: String?
    
    func update(enum: EnumThingy) {}
    
    public func description(_ description: String) -> Self {
        self.description = description
        return self
    }
    
    public func deprecationReason(_ deprecationReason: String) -> Self {
        self.deprecationReason = deprecationReason
        return self
    }
}

public class QLValue<EnumType : Encodable & RawRepresentable> : QLValueComponent<EnumType> where EnumType.RawValue == String {
    let value: EnumType

    override func update(enum: EnumThingy) {
        let value = GraphQLEnumValue(
            value: try! MapEncoder().encode(self.value),
            description: self.description,
            deprecationReason: self.deprecationReason
        )
        
        `enum`.values[self.value.rawValue] = value
    }
    
    public init(_ value: EnumType) {
        self.value = value
    }
}

final class EnumThingy {
    var values: GraphQLEnumValueMap = [:]
}

private final class MergerValue<EnumType : Encodable & RawRepresentable> : QLValueComponent<EnumType> where EnumType.RawValue == String {
    let components: [QLValueComponent<EnumType>]
    
    init(components: [QLValueComponent<EnumType>]) {
        self.components = components
    }
    
    override func update(enum: EnumThingy) {
        for component in components {
            component.update(enum: `enum`)
        }
    }
}

@_functionBuilder
public struct QLEnumTypeBuilder<EnumType : Encodable & RawRepresentable> where EnumType.RawValue == String {
    public static func buildBlock(_ components: QLValueComponent<EnumType>...) -> QLValueComponent<EnumType> {
        return MergerValue(components: components)
    }
}

public final class QLEnum<Resolver : FieldKeyProvider, Context, EnumType : Encodable & RawRepresentable> : QLSchemaComponent<Resolver, Context> where EnumType.RawValue == String {
    private let name: String?
    private let values: GraphQLEnumValueMap

    override func update(schema: SchemaThingy) {
        let enumType = try! GraphQLEnumType(
            name: self.name ?? fixName(String(describing: EnumType.self)),
            description: self.description,
            values: self.values
        )

        try! schema.map(EnumType.self, to: enumType)
    }

    public init(
        _ type: EnumType.Type,
        name: String? = nil,
        _ values: [QLValueComponent<EnumType>]
    ) {
        self.name = name
        let component = MergerValue(components: values)
        let `enum` = EnumThingy()
        component.update(enum: `enum`)
        self.values = `enum`.values
    }
    
    public init(
        _ type: EnumType.Type,
        name: String? = nil,
        @QLEnumTypeBuilder<EnumType> component: () -> QLValueComponent<EnumType>
    ) {
        self.name = name
        let component = component()
        let `enum` = EnumThingy()
        component.update(enum: `enum`)
        self.values = `enum`.values
    }
}

