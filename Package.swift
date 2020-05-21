// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "Graphiti",
    products: [
        .library(name: "Graphiti", targets: ["Graphiti"]),
    ],
    dependencies: [
        .package(url: "https://github.com/maximkrouk/GraphQL.git", from: "1.0.0-beta.1.0"),
        .package(url: "https://github.com/wickwirew/Runtime.git", from: "2.1.0")
    ],
    targets: [
        .target(
            name: "Graphiti",
            dependencies: [
                .product(name: "GraphQL", package: "GraphQL"),
                .product(name: "Runtime", package: "Runtime")
            ]
        ),
        .testTarget(name: "GraphitiTests", dependencies: [
            .target(name: "Graphiti")
        ]),
    ]
)
