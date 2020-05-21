public final class QLTypes<Resolver : FieldKeyProvider, Context> : QLSchemaComponent<Resolver, Context> {
    let types: [Any.Type]
    
    override func update(schema: SchemaThingy) {
        schema.types = self.types.map {
            try! schema.getNamedType(from: $0)
        }
    }
    
    public init(_ types: Any.Type...) {
        self.types = types
    }
}
