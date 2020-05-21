import GraphQL

public class QLInputObjectTypeComponent<InputObjectType, FieldKey : RawRepresentable, Context> where FieldKey.RawValue == String {
    
    func field(provider: QLTypeProvider) throws -> (String, InputObjectField) {
        fatalError()
    }
    
    func fields(provider: QLTypeProvider) throws -> InputObjectConfigFieldMap {
        fatalError()
    }
}

private class MergerInputObjectTypeComponent<InputObjectType, FieldKey : RawRepresentable, Context> : QLInputObjectTypeComponent<InputObjectType, FieldKey, Context> where FieldKey.RawValue == String {
    let components: [QLInputObjectTypeComponent<InputObjectType, FieldKey, Context>]
    
    init(components: [QLInputObjectTypeComponent<InputObjectType, FieldKey, Context>]) {
        self.components = components
    }
    
    override func fields(provider: QLTypeProvider) throws -> InputObjectConfigFieldMap {
        var map: InputObjectConfigFieldMap = [:]
        
        for component in self.components {
            let (name, field) = try component.field(provider: provider)
            map[name] = field
        }
        
        return map
    }
}

@_functionBuilder
public struct QLInputObjectTypeBuilder<InputObjectType, FieldKey : RawRepresentable, Context> where FieldKey.RawValue == String {
    public static func buildBlock(_ components: QLInputObjectTypeComponent<InputObjectType, FieldKey, Context>...) -> QLInputObjectTypeComponent<InputObjectType, FieldKey, Context> {
        return MergerInputObjectTypeComponent(components: components)
    }
}

public final class QLInput<Resolver : FieldKeyProvider, Context, InputObjectType : Decodable & FieldKeyProvider> : QLSchemaComponent<Resolver, Context> {
    let name: String?
    let component: QLInputObjectTypeComponent<InputObjectType, InputObjectType.FieldKey, Context>

    override func update(schema: SchemaThingy) {
        let inputObjectType = try! GraphQLInputObjectType(
            name: self.name ?? fixedName(for: InputObjectType.self),
            description: self.description,
            fields: self.component.fields(provider: schema)
        )

        try! schema.map(InputObjectType.self, to: inputObjectType)
    }

    public init(
        _ type: InputObjectType.Type,
        name: String? = nil,
        _ components: [QLInputObjectTypeComponent<InputObjectType, InputObjectType.FieldKey, Context>]
    ) {
        self.name = name
        self.component = MergerInputObjectTypeComponent(components: components)
    }
    
    public init(
        _ type: InputObjectType.Type,
        name: String? = nil,
        
        @QLInputObjectTypeBuilder<InputObjectType, InputObjectType.FieldKey, Context>
        component: () -> QLInputObjectTypeComponent<InputObjectType, InputObjectType.FieldKey, Context>
    ) {
        self.name = name
        self.component = component()
    }
}
