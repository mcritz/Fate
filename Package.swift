// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Fateball",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.1.1"),


        // 🖋🐘 Swift ORM (queries, models, relations, etc) built on PostgreSQL.
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),
        // 🍃 Leaf
        .package(url: "https://github.com/vapor/leaf", from: "3.0.2"),
        // 👤 Authentication and Authorization framework for Fluent.
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.1"),
        // 🔐 Crypto
        .package(url: "https://github.com/vapor/auth.git", from: "3.3.1"),
    ],
    targets: [
        .target(name: "App", dependencies: ["Authentication", "FluentPostgreSQL", "Leaf", "Vapor"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)
