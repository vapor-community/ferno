// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Ferno",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "Ferno",
            targets: ["Ferno"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.8.0"),
        .package(url: "https://github.com/vapor/jwt.git", from: "4.0.0-rc.2.1")
    ],
    targets: [
        .target(
            name: "Ferno",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "JWT", package: "jwt")
            ]
        ),
        .testTarget(
            name: "FernoTests",
            dependencies: [
                .target(name: "Ferno"),
                .product(name: "XCTVapor", package: "vapor")
            ]
        ),
    ]
)
