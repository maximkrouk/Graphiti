import GraphQL

public class QLObjectTypeComponent<ObjectType, FieldKey : RawRepresentable, Context> where FieldKey.RawValue == String {
    
    let isTypeOf: GraphQLIsTypeOf = { source, _, _ in
        return source is ObjectType
    }
    
    func field(provider: QLTypeProvider) throws -> (String, GraphQLField) {
        fatalError()
    }
    
    func fields(provider: QLTypeProvider) throws -> GraphQLFieldMap {
        fatalError()
    }
}

internal class MergerObjectTypeComponent<ObjectType, FieldKey : RawRepresentable, Context> : QLObjectTypeComponent<ObjectType, FieldKey, Context> where FieldKey.RawValue == String {
    let components: [QLObjectTypeComponent<ObjectType, FieldKey, Context>]
    
    init(components: [QLObjectTypeComponent<ObjectType, FieldKey, Context>]) {
        self.components = components
    }
    
    override func fields(provider: QLTypeProvider) throws -> GraphQLFieldMap {
        var map: GraphQLFieldMap = [:]
        
        for component in self.components {
            let (name, field) = try component.field(provider: provider)
            map[name] = field
        }
        
        return map
    }
}

@_functionBuilder
public struct QLObjectTypeBuilder<ObjectType, FieldKey : RawRepresentable, Context> where FieldKey.RawValue == String {
    public static func buildBlock(_ components: QLObjectTypeComponent<ObjectType, FieldKey, Context>...) -> QLObjectTypeComponent<ObjectType, FieldKey, Context> {
        return MergerObjectTypeComponent(components: components)
    }
}

public class QLType<Resolver: FieldKeyProvider, Context, ObjectType: Encodable & FieldKeyProvider> : QLSchemaComponent<Resolver, Context> {
    let name: String?
    let interfaces: [Any.Type]
    let component: QLObjectTypeComponent<ObjectType, ObjectType.FieldKey, Context>

    override func update(schema: SchemaThingy) {
        let objectType = try! GraphQLObjectType(
            name: self.name ?? fixedName(for: ObjectType.self),
            description: self.description,
            fields: self.component.fields(provider: schema),
            interfaces: self.interfaces.map {
                try! schema.getInterfaceType(from: $0)
            },
            isTypeOf: self.component.isTypeOf
        )

        try! schema.map(ObjectType.self, to: objectType)
    }

    public init(
        _ type: ObjectType.Type,
        name: String? = nil,
        interfaces: Any.Type...,
        fields components: [QLObjectTypeComponent<ObjectType, ObjectType.FieldKey, Context>]
    ) {
        self.name = name
        self.interfaces = interfaces
        self.component = MergerObjectTypeComponent(components: components)
    }
    
    public init(
        _ type: ObjectType.Type,
        name: String? = nil,
        interfaces: Any.Type...,
        
        @QLObjectTypeBuilder<ObjectType, ObjectType.FieldKey, Context>
        component: () -> QLObjectTypeComponent<ObjectType, ObjectType.FieldKey, Context>
    ) {
        self.name = name
        self.interfaces = interfaces
        self.component = component()
    }
}
