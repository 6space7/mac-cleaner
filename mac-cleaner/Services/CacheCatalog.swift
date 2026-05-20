import Foundation

enum CacheCatalog {
    static let categories: [CleanerCategory] = [
        CleanerCategory(
            id: .userCaches,
            title: "User Caches",
            subtitle: "App cache folders stored in your Library.",
            systemImage: "internaldrive"
        ),
        CleanerCategory(
            id: .browserStorage,
            title: "Browser Storage",
            subtitle: "Browser cache stores and service-worker data.",
            systemImage: "safari"
        ),
        CleanerCategory(
            id: .logs,
            title: "Logs & Reports",
            subtitle: "User logs, diagnostics, and crash reports.",
            systemImage: "doc.text.magnifyingglass"
        ),
        CleanerCategory(
            id: .developer,
            title: "Developer Caches",
            subtitle: "Xcode, simulator, and build artifacts.",
            systemImage: "hammer"
        ),
        CleanerCategory(
            id: .packages,
            title: "Package Managers",
            subtitle: "Homebrew, npm, pip, Gradle, SwiftPM, and friends.",
            systemImage: "shippingbox"
        ),
        CleanerCategory(
            id: .aiTools,
            title: "AI Tools",
            subtitle: "ChatGPT, Claude, Codex, Cursor, and agent caches.",
            systemImage: "sparkles"
        ),
        CleanerCategory(
            id: .communication,
            title: "Communication",
            subtitle: "Slack, Discord, Zoom, Teams, and chat app caches.",
            systemImage: "bubble.left.and.bubble.right"
        ),
        CleanerCategory(
            id: .designTools,
            title: "Design & Media",
            subtitle: "Figma, Adobe, Sketch, video, and creative caches.",
            systemImage: "paintpalette"
        ),
        CleanerCategory(
            id: .appContainers,
            title: "App Containers",
            subtitle: "Sandboxed app cache folders.",
            systemImage: "app.connected.to.app.below.fill"
        ),
        CleanerCategory(
            id: .installers,
            title: "Installers",
            subtitle: "Old DMG, PKG, ZIP, and archive files in Downloads.",
            systemImage: "archivebox"
        ),
        CleanerCategory(
            id: .custom,
            title: "Custom Folders",
            subtitle: "Folders you choose for this cleanup session.",
            systemImage: "folder.badge.gearshape"
        )
    ]

    nonisolated static func locations(
        profile: ScanProfile,
        customLocations: [URL],
        fileManager: FileManager = .default
    ) -> [CleanupLocation] {
        let home = fileManager.homeDirectoryForCurrentUser
        var locations = baseLocations(home: home)

        locations.append(contentsOf: chromiumCacheLocations(
            titlePrefix: "Chrome",
            root: home.appendingPathComponent("Library/Application Support/Google/Chrome"),
            blockedProcessNames: ["Google Chrome"]
        ))
        locations.append(contentsOf: chromiumCacheLocations(
            titlePrefix: "Arc",
            root: home.appendingPathComponent("Library/Application Support/Arc/User Data"),
            blockedProcessNames: ["Arc"]
        ))
        locations.append(contentsOf: chromiumCacheLocations(
            titlePrefix: "Brave",
            root: home.appendingPathComponent("Library/Application Support/BraveSoftware/Brave-Browser"),
            blockedProcessNames: ["Brave Browser"]
        ))
        locations.append(contentsOf: chromiumCacheLocations(
            titlePrefix: "Edge",
            root: home.appendingPathComponent("Library/Application Support/Microsoft Edge"),
            blockedProcessNames: ["Microsoft Edge"]
        ))
        locations.append(contentsOf: chromiumCacheLocations(
            titlePrefix: "Helium",
            root: home.appendingPathComponent("Library/Application Support/Helium"),
            blockedProcessNames: ["Helium"]
        ))
        locations.append(contentsOf: chromiumCacheLocations(
            titlePrefix: "Vivaldi",
            root: home.appendingPathComponent("Library/Application Support/Vivaldi"),
            blockedProcessNames: ["Vivaldi"]
        ))

        locations.append(contentsOf: appSupportCacheLocations(
            categoryID: .developer,
            titlePrefix: "VS Code",
            root: home.appendingPathComponent("Library/Application Support/Code"),
            blockedProcessNames: ["Code"]
        ))
        locations.append(contentsOf: appSupportCacheLocations(
            categoryID: .developer,
            titlePrefix: "Cursor",
            root: home.appendingPathComponent("Library/Application Support/Cursor"),
            blockedProcessNames: ["Cursor"]
        ))
        locations.append(contentsOf: appSupportCacheLocations(
            categoryID: .aiTools,
            titlePrefix: "Antigravity",
            root: home.appendingPathComponent("Library/Application Support/Antigravity"),
            blockedProcessNames: ["Antigravity"]
        ))
        locations.append(contentsOf: appSupportCacheLocations(
            categoryID: .aiTools,
            titlePrefix: "Claude",
            root: home.appendingPathComponent("Library/Application Support/Claude"),
            blockedProcessNames: ["Claude"]
        ))
        locations.append(contentsOf: appSupportCacheLocations(
            categoryID: .aiTools,
            titlePrefix: "Codex",
            root: home.appendingPathComponent("Library/Application Support/Codex"),
            blockedProcessNames: ["Codex"]
        ))
        locations.append(contentsOf: appSupportCacheLocations(
            categoryID: .communication,
            titlePrefix: "Slack",
            root: home.appendingPathComponent("Library/Application Support/Slack"),
            blockedProcessNames: ["Slack"]
        ))
        locations.append(contentsOf: appSupportCacheLocations(
            categoryID: .communication,
            titlePrefix: "Discord",
            root: home.appendingPathComponent("Library/Application Support/discord"),
            blockedProcessNames: ["Discord"]
        ))
        locations.append(contentsOf: folderLocations(
            categoryID: .browserStorage,
            titlePrefix: "GoogleUpdater",
            detailPrefix: "Google updater cache",
            root: home.appendingPathComponent("Library/Application Support/Google/GoogleUpdater"),
            childPaths: ["Cache", "crx_cache", "Crashpad/completed"],
            blockedProcessNames: ["GoogleUpdater", "Google Updater"]
        ))
        locations.append(contentsOf: folderLocations(
            categoryID: .browserStorage,
            titlePrefix: "Chrome",
            detailPrefix: "Chrome cache",
            root: home.appendingPathComponent("Library/Caches"),
            childPaths: ["Google/Chrome", "com.google.Chrome"],
            blockedProcessNames: ["Google Chrome"]
        ))
        locations.append(contentsOf: folderLocations(
            categoryID: .browserStorage,
            titlePrefix: "GoogleUpdater",
            detailPrefix: "Google updater cache",
            root: home.appendingPathComponent("Library/Caches"),
            childPaths: ["com.google.Keystone.Agent", "com.google.SoftwareUpdate"],
            blockedProcessNames: ["GoogleUpdater", "Google Updater"]
        ))
        locations.append(contentsOf: folderLocations(
            categoryID: .userCaches,
            titlePrefix: "Spotify",
            detailPrefix: "Spotify cache",
            root: home.appendingPathComponent("Library/Application Support/Spotify"),
            childPaths: ["PersistentCache", "Browser/Caches", "Browser/GPUCache", "Browser/Code Cache"],
            blockedProcessNames: ["Spotify"]
        ))
        locations.append(contentsOf: folderLocations(
            categoryID: .userCaches,
            titlePrefix: "Spotify",
            detailPrefix: "Spotify cache",
            root: home.appendingPathComponent("Library/Caches"),
            childPaths: ["com.spotify.client"],
            blockedProcessNames: ["Spotify"]
        ))

        locations.append(contentsOf: packageManagerCacheLocations(home: home))
        locations.append(contentsOf: developerToolCacheLocations(home: home))
        locations.append(contentsOf: communicationCacheLocations(home: home))
        locations.append(contentsOf: productivityCacheLocations(home: home))
        locations.append(contentsOf: mediaCacheLocations(home: home))
        locations.append(contentsOf: applicationSupportRegenerableLocations(
            root: home.appendingPathComponent("Library/Application Support"),
            fileManager: fileManager
        ))

        if profile.includes(.balanced) {
            locations.append(contentsOf: containerCacheLocations(
                categoryID: .appContainers,
                root: home.appendingPathComponent("Library/Containers"),
                relativeCachePath: "Data/Library/Caches",
                fileManager: fileManager
            ))
            locations.append(contentsOf: containerCacheLocations(
                categoryID: .appContainers,
                root: home.appendingPathComponent("Library/Group Containers"),
                relativeCachePath: "Library/Caches",
                fileManager: fileManager
            ))
            locations.append(contentsOf: containerCacheLocations(
                categoryID: .appContainers,
                root: home.appendingPathComponent("Library/Containers"),
                relativeCachePath: "Data/Library/Logs",
                fileManager: fileManager
            ))
            locations.append(contentsOf: containerCacheLocations(
                categoryID: .appContainers,
                root: home.appendingPathComponent("Library/Group Containers"),
                relativeCachePath: "Library/Logs",
                fileManager: fileManager
            ))
        }

        for url in customLocations {
            locations.append(CleanupLocation(
                categoryID: .custom,
                title: url.lastPathComponent.isEmpty ? url.path : url.lastPathComponent,
                detail: "Custom folder selected for this session.",
                url: url,
                minimumProfile: .deep,
                risk: .high,
                defaultSelected: false,
                recommendedMinimumAgeDays: 30
            ))
        }

        return locations.filter { profile.includes($0.minimumProfile) }
    }
}
