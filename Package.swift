// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "shodo",
    products: [
        .library(
            name: "shodo",
            targets: ["shodo"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "shodo",
            dependencies: []),
        .testTarget(
            name: "shodoTests",
            dependencies: ["shodo"]),
    ]
)
