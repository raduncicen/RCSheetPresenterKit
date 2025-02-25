// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RCSheetPresenterKit",
    platforms: [.iOS("15.0")],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "RCSheetPresenterKit",
            targets: ["RCSheetPresenterKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/raduncicen/RCPreviewKit", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "RCSheetPresenterKit",
            dependencies: ["RCPreviewKit"]
        ),
        .testTarget(
            name: "RCSheetPresenterKitTests",
            dependencies: ["RCSheetPresenterKit"]
        ),
    ]
)
