// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "MarioSwift",
  platforms: [
    .macOS(.v15)
  ],
  products: [
    .library(name: "MarioKit", targets: ["MarioKit"]),
    .executable(name: "MarioApp", targets: ["MarioApp"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.17.0")
  ],
  targets: [
    .target(
      name: "MarioKit",
      resources: [
        .copy("Resources")
      ]
    ),
    .executableTarget(
      name: "MarioApp",
      dependencies: [
        "MarioKit",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .testTarget(
      name: "MarioKitTests",
      dependencies: ["MarioKit"]
    ),
  ]
)
