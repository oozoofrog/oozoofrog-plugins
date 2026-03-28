// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "OSLogCLI",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-argument-parser.git",
            from: "1.7.1"
        )
    ],
    targets: [
        // 라이브러리 타겟: 테스트 가능한 로직 (main.swift 제외)
        .target(
            name: "OSLogCLICore",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Sources/OSLogCLICore"
        ),
        // 실행 타겟: main.swift만 포함 (ArgumentParser @main 실행)
        .executableTarget(
            name: "OSLogCLI",
            dependencies: ["OSLogCLICore"],
            path: "Sources/OSLogCLIMain"
        ),
        // 테스트 타겟: OSLogCLICore에만 의존 (ArgumentParser main 충돌 없음)
        .testTarget(
            name: "OSLogCLITests",
            dependencies: [
                "OSLogCLICore",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Tests/OSLogCLITests"
        )
    ]
)
