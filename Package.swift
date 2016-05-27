import PackageDescription

let package = Package(
    name: "CUDD",
    targets: [
        Target(name: "CCUDDAdditional"),
        Target(name: "CUDD", dependencies: ["CCUDDAdditional"])
    ],
    dependencies: [
        .Package(url: "../CCUDD", majorVersion: 1)
    ]
)