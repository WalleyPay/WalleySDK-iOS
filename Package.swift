// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WalleyCheckout",
    platforms: [.iOS(.v10)],
    products: [
        .library(
            name: "WalleyCheckout",
            targets: ["WalleyCheckout"]),
    ],
    targets: [
        .target(
            name: "WalleyCheckout",
            dependencies: []),
        .testTarget(
            name: "WalleyCheckoutTests",
            dependencies: ["WalleyCheckout"]),
    ]
)
