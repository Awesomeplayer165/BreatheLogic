// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BreatheLogic",
    platforms: [.iOS(.v16), .macOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "BreatheLogic",
            targets: ["BreatheLogic"]),
    ],
    dependencies: [
        .package(url: "http://github.com/Awesomeplayer165/BreatheShared", .branch("main")),
        .package(url: "https://github.com/Awesomeplayer165/BottomSheet.git", .branch("main"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "BreatheLogic", dependencies: ["BreatheShared", "BottomSheet"]),
        .testTarget(
            name: "BreatheLogicTests",
            dependencies: ["BreatheLogic"]),
    ]
)
