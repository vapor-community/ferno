// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FirebaseRealtime",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "FirebaseRealtime",
            targets: ["FirebaseRealtime"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0-rc")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "FirebaseRealtime",
            dependencies: ["Vapor"],
            path: "Sources"),
        .testTarget(
            name: "FirebaseRealtimeTests",
            dependencies: ["FirebaseRealtime"]),
    ]
)
