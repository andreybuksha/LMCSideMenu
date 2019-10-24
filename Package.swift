// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "LMCSideMenu",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(name: "LMCSideMenu", targets: ["LMCSideMenu"]),
    ],
    targets: [
        .target(name: "LMCSideMenu", path: "LMCSideMenu")
    ]
)
