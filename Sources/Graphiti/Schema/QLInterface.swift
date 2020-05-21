import GraphQL

public final class QLInterface<Resolver : FieldKeyProvider, Context, InterfaceType, FieldKey : RawRepresentable> : QLSchemaComponent<Resolver, Context> where FieldKey.RawValue == String {
    let name: String?
    let component: QLObjectTypeComponent<InterfaceType, FieldKey, Context>

    override func update(schema: SchemaThingy) {
        let interfaceType = try! GraphQLInterfaceType(
            name: self.name ?? fixedName(for: InterfaceType.self),
            description: self.description,
            fields: self.component.fields(provider: schema),
            resolveType: nil
        )

        try! schema.map(InterfaceType.self, to: interfaceType)
    }

    public init(
        _ type: InterfaceType.Type,
        fieldKeys: FieldKey.Type,
        name: String? = nil,
        _ components: [QLObjectTypeComponent<InterfaceType, FieldKey, Context>]
    )  {
        self.name = name
        self.component = MergerObjectTypeComponent(components: components)
    }
    
    public init(
        _ type: InterfaceType.Type,
        fieldKeys: FieldKey.Type,
        name: String? = nil,
        
        @QLObjectTypeBuilder<InterfaceType, FieldKey, Context>
        component: () -> QLObjectTypeComponent<InterfaceType, FieldKey, Context>
    )  {
        self.name = name
        self.component = component()
    }
}
