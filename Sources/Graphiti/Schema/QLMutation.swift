import GraphQL

public final class QLMutation<Resolver : FieldKeyProvider, Context> : QLSchemaComponent<Resolver, Context> {
    let name: String
    let component: QLObjectTypeComponent<Resolver, Resolver.FieldKey, Context>

    override func update(schema: SchemaThingy) {
        schema.mutation = try! GraphQLObjectType(
            name: name,
            description: self.description,
            fields: component.fields(provider: schema),
            isTypeOf: component.isTypeOf
        )
    }

    public init(
        name: String = "Mutation",
        _ components: [QLObjectTypeComponent<Resolver, Resolver.FieldKey, Context>]
    ) {
        self.name = name
        self.component = MergerObjectTypeComponent(components: components)
    }
    
    public init(
        name: String = "Mutation",
        @QLObjectTypeBuilder<Resolver, Resolver.FieldKey, Context>
        component: () -> QLObjectTypeComponent<Resolver, Resolver.FieldKey, Context>
    ) {
        self.name = name
        self.component = component()
    }
}
