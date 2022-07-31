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
    dependencies: [.package(url: "git@github.com:pointfreeco/swift-custom-dump.git",
                            exact:  "0.5.0")],
    targets: [
        .target(
            name: "shodo",
            dependencies: []),
        .testTarget(
            name: "shodoTests",
            dependencies: [.target(name: "shodo"), .product(name: "CustomDump", package: "swift-custom-dump")]),
    ]
)
