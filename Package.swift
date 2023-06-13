// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyToys",
    
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
    ],
    
    products: [
        .library(name: "Storage", targets: ["Storage"]),
        .library(name: "UIToys", targets: ["UIToys"]),
        .library(name: "SwiftyExtensions", targets: ["SwiftyExtensions"]),
    ],

    dependencies: [],

    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(name: "Storage", dependencies: []),
        .target(name: "UIToys", dependencies: []),
        .target(name: "SwiftyExtensions", dependencies: []),
    ]
)