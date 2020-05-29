// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Leo",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
    ],
    products: [
        .library(name: "Leo", targets: ["Leo"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "Leo", dependencies: []),
        .testTarget(name: "LeoTests", dependencies: ["Leo"]),
    ]
)
