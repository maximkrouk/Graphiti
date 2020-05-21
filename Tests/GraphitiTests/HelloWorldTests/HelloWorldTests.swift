import XCTest
@testable import Graphiti
import GraphQL
import NIO

class HelloWorldTests : XCTestCase {
    final class APIContext {
        func hello() -> String {
            "world"
        }
    }
    
    struct API : FieldKeyProvider {
        typealias FieldKey = FieldKeys
        
        enum FieldKeys : String {
            case hello
            case asyncHello
        }
        
        func hello(context: APIContext, arguments: NoArguments) -> String {
            context.hello()
        }
        
        func asyncHello(context: APIContext, arguments: NoArguments, eventLoopGroup: EventLoopGroup) -> EventLoopFuture<String> {
            eventLoopGroup.next().makeSucceededFuture(context.hello())
        }
    }
    
    let schema = QLSchema<API, APIContext>([
        QLQuery([
            QLField(.hello, at: API.hello),
            QLField(.asyncHello, at: API.asyncHello),
        ])
    ])

    func testHello() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
        defer {
            XCTAssertNoThrow(try eventLoopGroup.syncShutdownGracefully())
        }

        let query = "{ hello }"
        
        let expected = GraphQLResult(
            data: [
                "hello": "world"
            ]
        )
        
        let result = try schema.execute(
            request: query,
            resolver: API(),
            context: APIContext(),
            eventLoopGroup: eventLoopGroup
        ).wait()
        
        XCTAssertEqual(result, expected)
    }
    
    func testHelloAsync() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
        defer {
            XCTAssertNoThrow(try eventLoopGroup.syncShutdownGracefully())
        }
        
        let query = "{ asyncHello }"
        
        let expected = GraphQLResult(
            data: [
                "asyncHello": "world"
            ]
        )
        
        let result = try schema.execute(
            request: query,
            resolver: API(),
            context: APIContext(),
            eventLoopGroup: eventLoopGroup
        ).wait()
        
        XCTAssertEqual(result, expected)
    }

    func testBoyhowdy() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
        defer {
            XCTAssertNoThrow(try eventLoopGroup.syncShutdownGracefully())
        }

        let query = "{ boyhowdy }"

        let expectedErrors = GraphQLResult(
            errors: [
                GraphQLError(
                    message: "Cannot query field \"boyhowdy\" on type \"Query\".",
                    locations: [SourceLocation(line: 1, column: 3)]
                )
            ]
        )

        let result = try schema.execute(
            request: query,
            resolver: API(),
            context: APIContext(),
            eventLoopGroup: eventLoopGroup
        ).wait()
        
        XCTAssertEqual(result, expectedErrors)
    }
    
    struct ID : Codable {
        let id: String
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.id = try container.decode(String.self)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(self.id)
        }
    }

    func testScalar() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer {
            XCTAssertNoThrow(try eventLoopGroup.syncShutdownGracefully())
        }
        
        struct ScalarRoot : FieldKeyProvider {
            typealias FieldKey = FieldKeys
            
            enum FieldKeys : String {
                case float
                case id
            }
            
            struct FloatArguments : Codable {
                let float: Float
            }
            
            func float(context: NoContext, arguments: FloatArguments) -> Float {
                return arguments.float
            }
            
            struct DateArguments : Codable {
                let id: ID
            }
            
            func id(context: NoContext, arguments: DateArguments) -> ID {
                return arguments.id
            }
        }

        let schema = QLSchema<ScalarRoot, NoContext>([
            QLScalar(Float.self)
            .description("The `Float` scalar type represents signed double-precision fractional values as specified by [IEEE 754](http://en.wikipedia.org/wiki/IEEE_floating_point)."),

            QLScalar(ID.self),

            QLQuery([
                QLField(.float, at: ScalarRoot.float),
                QLField(.id, at: ScalarRoot.id),
            ])
        ])

        var query: String
        var expected = GraphQLResult(data: ["float": 4.0])
        var result: GraphQLResult

        query = "query Query($float: Float!) { float(float: $float) }"
        
        result = try schema.execute(
            request: query,
            resolver: ScalarRoot(),
            context: NoContext(),
            eventLoopGroup: eventLoopGroup,
            variables: ["float": 4]
        ).wait()

        XCTAssertEqual(result, expected)

        query = "query Query { float(float: 4) }"
        
        result = try schema.execute(
            request: query,
            resolver: ScalarRoot(),
            context: NoContext(),
            eventLoopGroup: eventLoopGroup
        ).wait()
        
        XCTAssertEqual(result, expected)
        
        query = "query Query($id: String!) { id(id: $id) }"
        expected = GraphQLResult(data: ["id": "85b8d502-8190-40ab-b18f-88edd297d8b6"])
        
        result = try schema.execute(
            request: query,
            resolver: ScalarRoot(),
            context: NoContext(),
            eventLoopGroup: eventLoopGroup,
            variables: ["id": "85b8d502-8190-40ab-b18f-88edd297d8b6"]
        ).wait()
        
        XCTAssertEqual(result, expected)
        
        query = #"query Query { id(id: "85b8d502-8190-40ab-b18f-88edd297d8b6") }"#
        
        result = try schema.execute(
            request: query,
            resolver: ScalarRoot(),
            context: NoContext(),
            eventLoopGroup: eventLoopGroup
        ).wait()
        
        XCTAssertEqual(result, expected)
    }

    func testInput() throws {
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
        defer {
            XCTAssertNoThrow(try group.syncShutdownGracefully())
        }

        struct Foo : Codable, FieldKeyProvider {
            typealias FieldKey = FieldKeys
            
            enum FieldKeys : String {
                case id
                case name
            }
            
            let id: String
            let name: String?

            static func fromInput(_ input: FooInput) -> Foo {
                return Foo(id: input.id, name: input.name)
            }
        }

        struct FooInput : Codable, FieldKeyProvider {
            typealias FieldKey = FieldKeys
            
            enum FieldKeys : String {
                case id
                case name
            }
            
            let id: String
            let name: String?
        }
        
        struct FooRoot : FieldKeyProvider {
            typealias FieldKey = FieldKeys
            
            enum FieldKeys : String {
                case foo
                case addFoo
            }
            
            func foo(context: NoContext, arguments: NoArguments) -> Foo {
                return Foo(id: "123", name: "bar")
            }
            
            struct AddFooArguments : Codable {
                let input: FooInput
            }
            
            func addFoo(context: NoContext, arguments: AddFooArguments) -> Foo {
                return Foo.fromInput(arguments.input)
            }
        }

        let generatedSchema = QLSchema<FooRoot, NoContext>([
            QLType(Foo.self, fields: [
                Graphiti.QLField(.id, at: \Foo.id),
                Graphiti.QLField(.name, at: \Foo.name)
            ]),

            QLQuery([
                QLField(.foo, at: FooRoot.foo),
            ]),

            QLInput(FooInput.self, [
                QLInputField(.id, at: \.id),
                QLInputField(.name, at: \.name)
            ]),

            QLMutation([
                QLField(.addFoo, at: FooRoot.addFoo),
            ]),
        ])

        let mutationForGen = "mutation addFoo($input: HelloWorldTests_LocalContext_FooInput!) { addFoo(input:$input) { id, name } }"
        let variablesForGen: [String: Map] = ["input" : [ "id" : "123", "name" : "bob" ]]
        
        let expectedForGen = GraphQLResult(
            data: ["addFoo" : [ "id" : "123", "name" : "bob" ]]
        )
        
        do {
            let result = try generatedSchema.execute(
                request: mutationForGen,
                resolver: FooRoot(),
                context: NoContext(),
                eventLoopGroup: group,
                variables: variablesForGen
            ).wait()
            
            XCTAssertEqual(result, expectedForGen)
            debugPrint(result)
        } catch {
            debugPrint(error)
        }
        
        let customSchema = QLSchema<FooRoot, NoContext>([
            QLType(Foo.self, fields: [
                Graphiti.QLField(.id, at: \Foo.id),
                Graphiti.QLField(.name, at: \Foo.name)
            ]),

            QLQuery([
                QLField(.foo, at: FooRoot.foo),
            ]),

            QLInput(FooInput.self, name: "FooInput", [
                QLInputField(.id, at: \.id),
                QLInputField(.name, at: \.name)
            ]),

            QLMutation([
                QLField(.addFoo, at: FooRoot.addFoo),
            ]),
        ])
        
        let mutationForCustom = "mutation addFoo($input: FooInput!) { addFoo(input:$input) { id, name } }"
        let variablesForCustom: [String: Map] = ["input" : [ "id" : "123", "name" : "bob" ]]
        
        let expectedForCustom = GraphQLResult(
            data: ["addFoo" : [ "id" : "123", "name" : "bob" ]]
        )
        
        do {
            let result = try customSchema.execute(
                request: mutationForCustom,
                resolver: FooRoot(),
                context: NoContext(),
                eventLoopGroup: group,
                variables: variablesForCustom
            ).wait()
            
            XCTAssertEqual(result, expectedForCustom)
            debugPrint(result)
        } catch {
            debugPrint(error)
        }
    }
}

extension HelloWorldTests {
    static var allTests: [(String, (HelloWorldTests) -> () throws -> Void)] {
        return [
            ("testHello", testHello),
            ("testHelloAsync", testHelloAsync),
            ("testBoyhowdy", testBoyhowdy),
        ]
    }
}
