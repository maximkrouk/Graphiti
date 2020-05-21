import XCTest
import NIO
@testable import Graphiti
import GraphQL

class StarWarsQueryTests : XCTestCase {
    private let starWarsAPI = StarWarsAPI()
    private let starWarsStore = StarWarsStore()
    
    func testHeroNameQuery() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
        defer {
            XCTAssertNoThrow(try eventLoopGroup.syncShutdownGracefully())
        }
        
        let query = """
        query HeroNameQuery {
            hero {
                name
            }
        }
        """

        let expected = GraphQLResult(
            data: [
                "hero": [
                    "name": "R2-D2",
                ],
            ]
        )
        
        let result = try starWarsSchema.execute(
            request: query,
            resolver: self.starWarsAPI,
            context: self.starWarsStore,
            eventLoopGroup: eventLoopGroup
        ).wait()
        
        print(result)
        
        XCTAssertEqual(result, expected)
    }

    func testHeroNameAndFriendsQuery() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
        defer {
            XCTAssertNoThrow(try eventLoopGroup.syncShutdownGracefully())
        }

        let query = "query HeroNameAndFriendsQuery {" +
                    "    hero {" +
                    "        id" +
                    "        name" +
                    "        friends {" +
                    "            name" +
                    "        }" +
                    "    }" +
                    "}"

        let expected = GraphQLResult(
            data: [
                "hero": [
                    "id": "5F3F16DE-B5BC-49B9-B280-313171F71E47",
                    "name": "R2-D2",
                    "friends": [
                        ["name": "Luke Skywalker"],
                        ["name": "Han Solo"],
                        ["name": "Leia Organa"],
                    ],
                ],
            ]
        )

        let result = try starWarsSchema.execute(
            request: query,
            resolver: self.starWarsAPI,
            context: self.starWarsStore,
            eventLoopGroup: eventLoopGroup
        ).wait()
        
        XCTAssertEqual(result, expected)
    }

    func testNestedQuery() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
        defer {
            XCTAssertNoThrow(try eventLoopGroup.syncShutdownGracefully())
        }

        let query = "query NestedQuery {" +
                    "    hero {" +
                    "        name" +
                    "        friends {" +
                    "            name" +
                    "            appearsIn" +
                    "            friends {" +
                    "                name" +
                    "            }" +
                    "        }" +
                    "    }" +
                    "}"

        let expected = GraphQLResult(
            data: [
                "hero": [
                    "name": "R2-D2",
                    "friends": [
                        [
                            "name": "Luke Skywalker",
                            "appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"],
                            "friends": [
                                ["name": "Han Solo"],
                                ["name": "Leia Organa"],
                                ["name": "C-3PO"],
                                ["name": "R2-D2"],
                            ],
                        ],
                        [
                            "name": "Han Solo",
                            "appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"],
                            "friends": [
                                ["name": "Luke Skywalker"],
                                ["name": "Leia Organa"],
                                ["name": "R2-D2"],
                            ],
                        ],
                        [
                            "name": "Leia Organa",
                            "appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"],
                            "friends": [
                                ["name": "Luke Skywalker"],
                                ["name": "Han Solo"],
                                ["name": "C-3PO"],
                                ["name": "R2-D2"],
                            ],
                        ],
                    ],
                ],
            ]
        )

        let result = try starWarsSchema.execute(
            request: query,
            resolver: self.starWarsAPI,
            context: self.starWarsStore,
            eventLoopGroup: eventLoopGroup
        ).wait()
        
        XCTAssertEqual(result, expected)
    }

    func testFetchLukeQuery() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
        defer {
            XCTAssertNoThrow(try eventLoopGroup.syncShutdownGracefully())
        }

        let query = "query FetchLukeQuery {" +
                    "    human(id: \"B340240F-57AB-4AD6-A71F-EBFE5E7ACC6C\") {" +
                    "        name" +
                    "    }" +
                    "}"

        let expected = GraphQLResult(
            data: [
                "human": [
                    "name": "Luke Skywalker",
                ],
            ]
        )

        let result = try starWarsSchema.execute(
             request: query,
            resolver: self.starWarsAPI,
            context: self.starWarsStore,
            eventLoopGroup: eventLoopGroup
        ).wait()
        
        XCTAssertEqual(result, expected)
    }

    func testFetchSomeIDQuery() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
        defer {
            XCTAssertNoThrow(try eventLoopGroup.syncShutdownGracefully())
        }

        let query = "query FetchSomeIDQuery($someId: String!) {" +
                    "    human(id: $someId) {" +
                    "        name" +
                    "    }" +
                    "}"

        var params: [String: Map]
        var expected: GraphQLResult
        var result: GraphQLResult

        params = [
            "someId": "B340240F-57AB-4AD6-A71F-EBFE5E7ACC6C",
        ]

        expected = GraphQLResult(
            data: [
                "human": [
                    "name": "Luke Skywalker",
                ],
            ]
        )

        result = try starWarsSchema.execute(
             request: query,
            resolver: self.starWarsAPI,
            context: self.starWarsStore,
            eventLoopGroup: eventLoopGroup,
            variables: params
        ).wait()
        
        XCTAssertEqual(result, expected)

        params = [
            "someId": "0511AC38-E359-43AA-827F-9666279BD280",
        ]

        expected = GraphQLResult(
            data: [
                "human": [
                    "name": "Han Solo",
                ],
            ]
        )

        result = try starWarsSchema.execute(
             request: query,
            resolver: self.starWarsAPI,
            context: self.starWarsStore,
            eventLoopGroup: eventLoopGroup,
            variables: params
        ).wait()
        
        XCTAssertEqual(result, expected)

        params = [
            "someId": "not a valid id",
        ]

        expected = GraphQLResult(
            data: [
                "human": nil,
            ]
        )

        result = try starWarsSchema.execute(
             request: query,
            resolver: self.starWarsAPI,
            context: self.starWarsStore,
            eventLoopGroup: eventLoopGroup,
            variables: params
        ).wait()
        
        // There will also be a decoding error
        XCTAssertEqual(result.data, expected.data)
    }

    func testFetchLukeAliasedQuery() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
        defer {
            XCTAssertNoThrow(try eventLoopGroup.syncShutdownGracefully())
        }

        let query = "query FetchLukeAliasedQuery {" +
                    "    luke: human(id: \"B340240F-57AB-4AD6-A71F-EBFE5E7ACC6C\") {" +
                    "        name" +
                    "    }" +
                    "}"

        let expected = GraphQLResult(
            data: [
                "luke": [
                    "name": "Luke Skywalker",
                ],
            ]
        )

        let result = try starWarsSchema.execute(
             request: query,
            resolver: self.starWarsAPI,
            context: self.starWarsStore,
            eventLoopGroup: eventLoopGroup
        ).wait()
        
        XCTAssertEqual(result, expected)
    }

    func testFetchLukeAndLeiaAliasedQuery() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
        defer {
            XCTAssertNoThrow(try eventLoopGroup.syncShutdownGracefully())
        }

        let query = "query FetchLukeAndLeiaAliasedQuery {" +
                    "    luke: human(id: \"B340240F-57AB-4AD6-A71F-EBFE5E7ACC6C\") {" +
                    "        name" +
                    "    }" +
                    "    leia: human(id: \"ECA47EF3-022B-4398-9E20-EC64594C3BAE\") {" +
                    "        name" +
                    "    }" +
                    "}"

        let expected = GraphQLResult(
            data: [
                "luke": [
                    "name": "Luke Skywalker",
                ],
                "leia": [
                    "name": "Leia Organa",
                ],
            ]
        )

        let result = try starWarsSchema.execute(
             request: query,
            resolver: self.starWarsAPI,
            context: self.starWarsStore,
            eventLoopGroup: eventLoopGroup
        ).wait()
        
        XCTAssertEqual(result, expected)
    }

    func testDuplicateFieldsQuery() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
        defer {
            XCTAssertNoThrow(try eventLoopGroup.syncShutdownGracefully())
        }

        let query = "query DuplicateFieldsQuery {" +
                    "    luke: human(id: \"B340240F-57AB-4AD6-A71F-EBFE5E7ACC6C\") {" +
                    "        name" +
                    "        homePlanet { name }" +
                    "    }" +
                    "    leia: human(id: \"ECA47EF3-022B-4398-9E20-EC64594C3BAE\") {" +
                    "        name" +
                    "        homePlanet  { name }" +
                    "    }" +
                    "}"

        let expected = GraphQLResult(
            data: [
                "luke": [
                    "name": "Luke Skywalker",
                    "homePlanet": ["name":"Tatooine"],
                ],
                "leia": [
                    "name": "Leia Organa",
                    "homePlanet": ["name":"Alderaan"],
                ],
            ]
        )

        let result = try starWarsSchema.execute(
             request: query,
            resolver: self.starWarsAPI,
            context: self.starWarsStore,
            eventLoopGroup: eventLoopGroup
        ).wait()
        
        XCTAssertEqual(result, expected)
    }

    func testUseFragmentQuery() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
        defer {
            XCTAssertNoThrow(try eventLoopGroup.syncShutdownGracefully())
        }

        let query = "query UseFragmentQuery {" +
                    "    luke: human(id: \"B340240F-57AB-4AD6-A71F-EBFE5E7ACC6C\") {" +
                    "        ...HumanFragment" +
                    "    }" +
                    "    leia: human(id: \"ECA47EF3-022B-4398-9E20-EC64594C3BAE\") {" +
                    "        ...HumanFragment" +
                    "    }" +
                    "}" +
                    "fragment HumanFragment on Human {" +
                    "    name" +
                    "    homePlanet { name }" +
                    "}"

        let expected = GraphQLResult(
            data: [
                "luke": [
                    "name": "Luke Skywalker",
                    "homePlanet": ["name":"Tatooine"],
                ],
                "leia": [
                    "name": "Leia Organa",
                    "homePlanet": ["name":"Alderaan"],
                ],
            ]
        )

        let result = try starWarsSchema.execute(
             request: query,
            resolver: self.starWarsAPI,
            context: self.starWarsStore,
            eventLoopGroup: eventLoopGroup
        ).wait()
        
        XCTAssertEqual(result, expected)
    }

    func testCheckTypeOfR2Query() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
        defer {
            XCTAssertNoThrow(try eventLoopGroup.syncShutdownGracefully())
        }

        let query = "query CheckTypeOfR2Query {" +
                    "    hero {" +
                    "        __typename" +
                    "        name" +
                    "    }" +
                    "}"

        let expected = GraphQLResult(
            data: [
                "hero": [
                    "__typename": "Droid",
                    "name": "R2-D2",
                ],
            ]
        )

        let result = try starWarsSchema.execute(
             request: query,
            resolver: self.starWarsAPI,
            context: self.starWarsStore,
            eventLoopGroup: eventLoopGroup
        ).wait()
        
        XCTAssertEqual(result, expected)
    }

    func testCheckTypeOfLukeQuery() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
        defer {
            XCTAssertNoThrow(try eventLoopGroup.syncShutdownGracefully())
        }

        let query = "query CheckTypeOfLukeQuery {" +
                    "    hero(episode: EMPIRE) {" +
                    "        __typename" +
                    "        name" +
                    "    }" +
                    "}"

        let expected = GraphQLResult(
            data: [
                "hero": [
                    "__typename": "Human",
                    "name": "Luke Skywalker",
                ],
            ]
        )

        let result = try starWarsSchema.execute(
             request: query,
            resolver: self.starWarsAPI,
            context: self.starWarsStore,
            eventLoopGroup: eventLoopGroup
        ).wait()
        
        XCTAssertEqual(result, expected)
    }

    func testSecretBackstoryQuery() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
        defer {
            XCTAssertNoThrow(try eventLoopGroup.syncShutdownGracefully())
        }

        let query = "query SecretBackstoryQuery {\n" +
                    "    hero {\n" +
                    "        name\n" +
                    "        secretBackstory\n" +
                    "    }\n" +
                    "}\n"

        let expected = GraphQLResult(
            data: [
                "hero": [
                    "name": "R2-D2",
                    "secretBackstory": nil,
                ]
            ],
            errors: [
                GraphQLError(
                    message: "secretBackstory is secret.",
                    locations: [SourceLocation(line: 4, column: 9)],
                    path: ["hero", "secretBackstory"]
                )
            ]
        )

        let result = try starWarsSchema.execute(
             request: query,
            resolver: self.starWarsAPI,
            context: self.starWarsStore,
            eventLoopGroup: eventLoopGroup
        ).wait()
        
        XCTAssertEqual(result, expected)
    }

    func testSecretBackstoryListQuery() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
        defer {
            XCTAssertNoThrow(try eventLoopGroup.syncShutdownGracefully())
        }

        let query = "query SecretBackstoryListQuery {\n" +
                    "    hero {\n" +
                    "        name\n" +
                    "        friends {\n" +
                    "            name\n" +
                    "            secretBackstory\n" +
                    "        }\n" +
                    "    }\n" +
                    "}\n"

        let expected = GraphQLResult(
            data: [
                "hero": [
                    "name": "R2-D2",
                    "friends": [
                        [
                            "name": "Luke Skywalker",
                            "secretBackstory": nil,
                        ],
                        [
                            "name": "Han Solo",
                            "secretBackstory": nil,
                        ],
                        [
                            "name": "Leia Organa",
                            "secretBackstory": nil,
                        ]
                    ]
                ]
            ],
            errors: [
                GraphQLError(
                    message: "secretBackstory is secret.",
                    locations: [SourceLocation(line: 6, column: 13)],
                    path: ["hero", "friends", 0, "secretBackstory"]
                ),
                GraphQLError(
                    message: "secretBackstory is secret.",
                    locations: [SourceLocation(line: 6, column: 13)],
                    path: ["hero", "friends", 1, "secretBackstory"]
                ),
                GraphQLError(
                    message: "secretBackstory is secret.",
                    locations: [SourceLocation(line: 6, column: 13)],
                    path: ["hero", "friends", 2, "secretBackstory"]
                )
            ]
        )

        let result = try starWarsSchema.execute(
             request: query,
            resolver: self.starWarsAPI,
            context: self.starWarsStore,
            eventLoopGroup: eventLoopGroup
        ).wait()
        
        XCTAssertEqual(result, expected)
    }

    func testSecretBackstoryAliasQuery() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
        defer {
            XCTAssertNoThrow(try eventLoopGroup.syncShutdownGracefully())
        }

        let query = "query SecretBackstoryAliasQuery {\n" +
                    "    mainHero: hero {\n" +
                    "        name\n" +
                    "        story: secretBackstory\n" +
                    "    }\n" +
                    "}\n"

        let expected = GraphQLResult(
            data: [
                "mainHero": [
                    "name": "R2-D2",
                    "story": nil,
                ]
            ],
            errors: [
                GraphQLError(
                    message: "secretBackstory is secret.",
                    locations: [SourceLocation(line: 4, column: 9)],
                    path: ["mainHero", "story"]
                )
            ]
        )

        let result = try starWarsSchema.execute(
             request: query,
            resolver: self.starWarsAPI,
            context: self.starWarsStore,
            eventLoopGroup: eventLoopGroup
        ).wait()
        
        XCTAssertEqual(result, expected)
    }

    func testNonNullableFieldsQuery() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
        defer {
            XCTAssertNoThrow(try eventLoopGroup.syncShutdownGracefully())
        }
        
        struct A : Codable, FieldKeyProvider {
            typealias FieldKey = FieldKeys
            
            enum FieldKeys : String {
                case nullableA
                case nonNullA
                case `throws`
            }
        
            func nullableA(context: NoContext, arguments: NoArguments) -> A? {
                return A()
            }
            
            func nonNullA(context: NoContext, arguments: NoArguments) -> A {
                return A()
            }
            
            func `throws`(context: NoContext, arguments: NoArguments) throws -> String {
                struct 🏃 : Error, CustomStringConvertible {
                    let description: String
                }
                
                throw 🏃(description: "catch me if you can.")
            }
        }
        
        struct Root : FieldKeyProvider {
            typealias FieldKey = FieldKeys
            
            enum FieldKeys : String {
                case nullableA
            }
            
            func nullableA(context: NoContext, arguments: NoArguments) -> A? {
                return A()
            }
        }

        let schema = QLSchema<Root, NoContext>([
            QLType(A.self, fields: [
                QLField(.nullableA, at: A.nullableA, overridingType: (QLTypeReference<A>?).self),
                QLField(.nonNullA, at: A.nonNullA, overridingType: QLTypeReference<A>.self),
                QLField(.throws, at: A.throws),
            ]),

            QLQuery([
                QLField(.nullableA, at: Root.nullableA),
            ]),
        ])

        let query = "query {\n" +
                    "    nullableA {\n" +
                    "        nullableA {\n" +
                    "            nonNullA {\n" +
                    "                nonNullA {\n" +
                    "                    throws\n" +
                    "                }\n" +
                    "            }\n" +
                    "        }\n" +
                    "    }\n" +
                    "}\n"

        let expected = GraphQLResult(
            data: [
                "nullableA": [
                    "nullableA": nil,
                ],
            ],
            errors: [
                GraphQLError(
                    message: "catch me if you can.",
                    locations: [SourceLocation(line: 6, column: 21)],
                    path: ["nullableA", "nullableA", "nonNullA", "nonNullA", "throws"]
                ),
            ]
        )

        let result = try schema.execute(
             request: query,
            resolver: Root(),
            context: NoContext(),
            eventLoopGroup: eventLoopGroup
        ).wait()
        
        XCTAssertEqual(result, expected)
    }

    func testSearchQuery() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
        defer {
            XCTAssertNoThrow(try eventLoopGroup.syncShutdownGracefully())
        }

        let query = "query {" +
            "    search(query: \"o\") {" +
            "        ... on Planet {" +
            "            name " +
            "            diameter " +
            "        }" +
            "        ... on Human {" +
            "            name " +
            "        }" +
            "        ... on Droid {" +
            "            name " +
            "            primaryFunction " +
            "        }" +
            "    }" +
            "}"

        var expected = GraphQLResult(
            data: [
                "search": [
                    [ "name": "Tatooine", "diameter": 10465 ],
                    [ "name": "Han Solo" ],
                    [ "name": "Leia Organa" ],
                    [ "name": "C-3PO", "primaryFunction": "Protocol" ],
                ],
            ]
        )
        
        func sortSearchResultData(_ result: inout GraphQLResult) {
            let searchResults = result.data!.dictionary!["search"]!.array!.map { $0.dictionary! }
            result.data = Map([
                "search": Map(
                    searchResults.sorted {
                        $0["name"]!.string! < $1["name"]!.string!
                    }.map { Map($0) }
                )
            ])
        }
        

        // Order matters, so
        var result = try starWarsSchema.execute(
             request: query,
            resolver: self.starWarsAPI,
            context: self.starWarsStore,
            eventLoopGroup: eventLoopGroup
        ).wait()
        
        sortSearchResultData(&result)
        sortSearchResultData(&expected)
        
        XCTAssertEqual(result, expected)
    }
}

extension StarWarsQueryTests {
    static var allTests: [(String, (StarWarsQueryTests) -> () throws -> Void)] {
        return [
            ("testHeroNameQuery", testHeroNameQuery),
            ("testHeroNameAndFriendsQuery", testHeroNameAndFriendsQuery),
            ("testNestedQuery", testNestedQuery),
            ("testFetchLukeQuery", testFetchLukeQuery),
            ("testFetchSomeIDQuery", testFetchSomeIDQuery),
            ("testFetchLukeAliasedQuery", testFetchLukeAliasedQuery),
            ("testFetchLukeAndLeiaAliasedQuery", testFetchLukeAndLeiaAliasedQuery),
            ("testDuplicateFieldsQuery", testDuplicateFieldsQuery),
            ("testUseFragmentQuery", testUseFragmentQuery),
            ("testCheckTypeOfR2Query", testCheckTypeOfR2Query),
            ("testCheckTypeOfLukeQuery", testCheckTypeOfLukeQuery),
            ("testSecretBackstoryQuery", testSecretBackstoryQuery),
            ("testSecretBackstoryListQuery", testSecretBackstoryListQuery),
            ("testNonNullableFieldsQuery", testNonNullableFieldsQuery),
        ]
    }
}
