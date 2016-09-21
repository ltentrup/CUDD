import PackageDescription

let package = Package(
    name: "CUDD",
    dependencies: [
        .Package(url: "https://github.com/ltentrup/CCUDD.git", majorVersion: 1)
    ]
)