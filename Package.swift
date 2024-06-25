// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DecodeFrames",
    platforms: [.iOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DecodeFrames",
            targets: ["DecodeFrames"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DecodeFrames",
            resources: [
                // Paths are defined relative to your sources root!
                .copy("Resources/."),
//                .process("Resources"),
                
                // You can also just copy an entire folder if needed
//                .copy("Resources/MockFiles/")
            ]),
        .testTarget(
            name: "DecodeFramesTests",
            dependencies: ["DecodeFrames"]),
    ]
)
