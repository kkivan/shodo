// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Shodo",
    products: [
        .library(
            name: "Shodo",
            targets: ["Shodo"]),
    ],
    dependencies: [.package(url: "git@github.com:pointfreeco/swift-custom-dump.git",
                            exact:  "0.5.0")],
    targets: [
        .target(
            name: "Shodo",
            dependencies: []),
        .testTarget(
            name: "ShodoTests",
            dependencies: [.target(name: "Shodo"),
                           .product(name: "CustomDump", package: "swift-custom-dump")]),
    ]
)
