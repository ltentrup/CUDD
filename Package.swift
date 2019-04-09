// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "CUDD",
    products: [
        .library(name: "CUDD", targets: ["CUDD"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ltentrup/CCUDD.git", from: "1.0.0"),
    ],
    targets: [
        .target(name: "CUDD", dependencies: ["CCUDD"]),
        .testTarget(name: "CUDDTests", dependencies: ["CUDD"]),
    ]
)