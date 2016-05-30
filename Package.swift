import PackageDescription

let package = Package(
    name: "CUDD",
    targets: [
        Target(name: "CUDD")
    ],
    dependencies: [
        .Package(url: "../CCUDD", majorVersion: 1)
    ]
)