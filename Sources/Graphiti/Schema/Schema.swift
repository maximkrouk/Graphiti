import GraphQL
import Foundation
import NIO

public typealias NoContext = Void

public class SchemaComponent<Resolver : FieldKeyProvider, Context> : Descriptable {
    var description: String? = nil
    
    public func description(_ description: String) -> Self {
        self.description = description
        return self
    }
    
    func update(schema: SchemaThingy) {}
}



final class SchemaThingy : TypeProvider {
    private class _STTypeProvider: TypeProvider {
        var graphQLTypeMap: [AnyType: GraphQLType] = [
            AnyType(Bool.self): GraphQLBoolean,
            AnyType(Double.self): GraphQLFloat,
            AnyType(Float.self): GraphQLFloat,
            AnyType(Int.self): GraphQLInt,
            AnyType(String.self): GraphQLString,
            AnyType(UUID.self): GraphQLString,
        ]
    }
    
    init(typeProvider: TypeProvider?) {
        self.underlyingTypeProvider = typeProvider ?? _STTypeProvider()
    }
    
    var graphQLTypeMap: [AnyType : GraphQLType] {
        get { underlyingTypeProvider.graphQLTypeMap }
        set { underlyingTypeProvider.graphQLTypeMap = newValue }
    }
    
    var underlyingTypeProvider: TypeProvider
    var query: GraphQLObjectType? = nil
    var mutation: GraphQLObjectType? = nil
    var subscription: GraphQLObjectType? = nil
    var types: [GraphQLNamedType] = []
    var directives: [GraphQLDirective] = []
}

private final class MergerSchemaComponent<RootType : FieldKeyProvider, Context> : SchemaComponent<RootType, Context> {
    let components: [SchemaComponent<RootType, Context>]
    
    init(components: [SchemaComponent<RootType, Context>]) {
        self.components = components
    }
    
    override func update(schema: SchemaThingy) {
        for component in self.components {
            component.update(schema: schema)
        }
    }
}
//
//@_functionBuilder
//public struct SchemaBuilder<RootType : FieldKeyProvider, Context> {
//    public static func buildBlock(_ components: SchemaComponent<RootType, Context>...) -> SchemaComponent<RootType, Context> {
//        return MergerSchemaComponent(components: components)
//    }
//}
//
//public final class Schema<RootType : FieldKeyProvider, Context> {
//    private let schema: GraphQLSchema
//
//    public init(@SchemaBuilder<RootType, Context> component: () -> SchemaComponent<RootType, Context>) {
//        let component = component()
//        let thingy = SchemaThingy()
//        component.update(schema: thingy)
//
//        guard let query = thingy.query else {
//            fatalError("Query type is required.")
//        }
//
//        self.schema = try! GraphQLSchema(
//            query: query,
//            mutation: thingy.mutation,
//            subscription: thingy.subscription,
//            types: thingy.types,
//            directives: thingy.directives
//        )
//    }
//}
//
//extension Schema {
//    public func execute(
//        request: String,
//        root: RootType,
//        context: Context,
//        eventLoopGroup: EventLoopGroup,
//        variables: [String: Map] = [:],
//        operationName: String? = nil
//    ) -> Future<GraphQLResult> {
//        do {
//            return try graphql(
//                schema: self.schema,
//                request: request,
//                rootValue: root,
//                context: context,
//                eventLoopGroup: eventLoopGroup,
//                variableValues: variables,
//                operationName: operationName
//            )
//        } catch {
//            return eventLoopGroup.next().newFailedFuture(error: error)
//        }
//    }
//}

public class Schema<Resolver: FieldKeyProvider, Context> {
    public var schema: GraphQLSchema

    public init(customTypeProvider: TypeProvider? = nil, _ component: [SchemaComponent<Resolver, Context>]) {
        let component = MergerSchemaComponent(components: component)
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

extension Schema {
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
