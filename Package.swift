import PackageDescription

let package = Package(
    name: "CUDD",
    dependencies: [
        .Package(url: "../CCUDD", majorVersion: 1)
    ]
)