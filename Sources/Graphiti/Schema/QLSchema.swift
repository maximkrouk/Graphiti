import GraphQL
import Foundation
import NIO

public typealias NoContext = Void

public class QLSchemaComponent<Resolver : FieldKeyProvider, Context> : Descriptable {
    var description: String? = nil
    
    public func description(_ description: String) -> Self {
        self.description = description
        return self
    }
    
    func update(schema: SchemaThingy) {}
}



final class SchemaThingy : QLTypeProvider {
    private class _STTypeProvider: QLTypeProvider {
        var graphQLTypeMap: [AnyType: GraphQLType] = [
            AnyType(Bool.self): GraphQLBoolean,
            AnyType(Double.self): GraphQLFloat,
            AnyType(Int.self): GraphQLInt,
            AnyType(String.self): GraphQLString,
            AnyType(UUID.self): GraphQLString,
        ]
    }
    
    init(typeProvider: QLTypeProvider?) {
        self.underlyingTypeProvider = typeProvider ?? _STTypeProvider()
    }
    
    var graphQLTypeMap: [AnyType : GraphQLType] {
        get { underlyingTypeProvider.graphQLTypeMap }
        set { underlyingTypeProvider.graphQLTypeMap = newValue }
    }
    
    var underlyingTypeProvider: QLTypeProvider
    var query: GraphQLObjectType? = nil
    var mutation: GraphQLObjectType? = nil
    var subscription: GraphQLObjectType? = nil
    var types: [GraphQLNamedType] = []
    var directives: [GraphQLDirective] = []
}

private final class QLMergerSchemaComponent<Resolver : FieldKeyProvider, Context> : QLSchemaComponent<Resolver, Context> {
    let components: [QLSchemaComponent<Resolver, Context>]
    
    init(components: [QLSchemaComponent<Resolver, Context>]) {
        self.components = components
    }
    
    override func update(schema: SchemaThingy) {
        for component in self.components {
            component.update(schema: schema)
        }
    }
}

@_functionBuilder
public struct QLSchemaBuilder<Resolver : FieldKeyProvider, Context> {
    public static func buildBlock(_ components: QLSchemaComponent<Resolver, Context>...) -> QLSchemaComponent<Resolver, Context> {
        return QLMergerSchemaComponent(components: components)
    }
}

public class QLSchema<Resolver: FieldKeyProvider, Context> {
    public var schema: GraphQLSchema

    public init(customTypeProvider: QLTypeProvider? = nil, _ component: [QLSchemaComponent<Resolver, Context>]) {
        let component = QLMergerSchemaComponent(components: component)
        let thingy = SchemaThingy(typeProvider: customTypeProvider)
        component.update(schema: thingy)

        guard let query = thingy.query else {
            fatalError("Query type is required.")
        }

        self.schema = try! GraphQLSchema(
            query: query,
            mutation: thingy.mutation,
            subscription: thingy.subscription,
            types: thingy.types,
            directives: thingy.directives
        )
    }
    
    public init(
        customTypeProvider: QLTypeProvider? = nil,
        @QLSchemaBuilder<Resolver, Context> component: () -> QLSchemaComponent<Resolver, Context>
    ) {
        let component = component()
        let thingy = SchemaThingy(typeProvider: customTypeProvider)
        component.update(schema: thingy)

        guard let query = thingy.query else {
            fatalError("Query type is required.")
        }

        self.schema = try! GraphQLSchema(
            query: query,
            mutation: thingy.mutation,
            subscription: thingy.subscription,
            types: thingy.types,
            directives: thingy.directives
        )
    }
}

extension QLSchema {
    public func execute(
        request: String,
        resolver: Resolver,
        context: Context,
        eventLoopGroup: EventLoopGroup,
        variables: [String: Map] = [:],
        operationName: String? = nil
    ) -> Future<GraphQLResult> {
        do {
            return try graphql(
                schema: self.schema,
                request: request,
                rootValue: resolver,
                context: context,
                eventLoopGroup: eventLoopGroup,
                variableValues: variables,
                operationName: operationName
            )
        } catch {
            return eventLoopGroup.next().makeFailedFuture(error)
        }
    }
}
