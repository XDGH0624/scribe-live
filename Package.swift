// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ScribeLive",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .executable(name: "ScribeLiveMac", targets: ["ScribeLiveMac"]),
        .library(name: "ScribeCore", targets: ["ScribeCore"]),
        .library(name: "AudioInput", targets: ["AudioInput"]),
        .library(name: "SpeechPipeline", targets: ["SpeechPipeline"]),
        .library(name: "TranslationPipeline", targets: ["TranslationPipeline"]),
        .library(name: "LiveCaptionOverlay", targets: ["LiveCaptionOverlay"]),
        .library(name: "Notes", targets: ["Notes"])
    ],
    targets: [
        .executableTarget(
            name: "ScribeLiveMac",
            dependencies: [
                "ScribeCore",
                "AudioInput",
                "SpeechPipeline",
                "TranslationPipeline",
                "LiveCaptionOverlay",
                "Notes"
            ]
        ),
        .target(name: "ScribeCore"),
        .target(name: "AudioInput", dependencies: ["ScribeCore"]),
        .target(name: "SpeechPipeline", dependencies: ["ScribeCore", "AudioInput"]),
        .target(name: "TranslationPipeline", dependencies: ["ScribeCore"]),
        .target(name: "LiveCaptionOverlay", dependencies: ["ScribeCore"]),
        .target(name: "Notes", dependencies: ["ScribeCore"])
    ]
)
