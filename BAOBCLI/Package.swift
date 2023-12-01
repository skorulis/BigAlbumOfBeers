// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BAOBCLI",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "BAOBCLI",
            targets: ["BAOBCLI"]),
    ],
    dependencies: [
		.package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(url: "git@github.com:skorulis/ASKCore.git", branch: "main"),
        .package(url: "git@github.com:nodes-vapor/slugify.git", from: "2.0.0"),
    ],
    targets: [
    	.executableTarget(
    		name: "BAOBCLI", 
    		dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Slugify", package: "slugify"),
                "ASKCore",
                
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "BAOBCLITests",
            dependencies: [
                "BAOBCLI"
            ],
            path: "UnitTests"
        )
    ]
)
