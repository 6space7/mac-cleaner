import Foundation

extension CacheCatalog {
    nonisolated static func communicationCacheLocations(home: URL) -> [CleanupLocation] {
        var locations = folderLocations(
            categoryID: .communication,
            titlePrefix: "Teams",
            detailPrefix: "Microsoft Teams renderer cache",
            root: home.appendingPathComponent("Library/Application Support/Microsoft/Teams"),
            childPaths: ["Cache", "Code Cache", "GPUCache", "logs", "tmp"],
            blockedProcessNames: ["Microsoft Teams"]
        )

        locations.append(contentsOf: folderLocations(
            categoryID: .communication,
            titlePrefix: "Telegram",
            detailPrefix: "Telegram cache",
            root: home.appendingPathComponent("Library/Group Containers/6N38VWS5BX.ru.keepcoder.Telegram"),
            childPaths: ["Library/Caches"],
            recommendedMinimumAgeDays: 7,
            blockedProcessNames: ["Telegram"]
        ))

        locations.append(contentsOf: folderLocations(
            categoryID: .communication,
            titlePrefix: "WhatsApp",
            detailPrefix: "WhatsApp renderer cache",
            root: home.appendingPathComponent("Library/Application Support/WhatsApp"),
            childPaths: ["Cache", "Code Cache", "GPUCache"],
            recommendedMinimumAgeDays: 7,
            blockedProcessNames: ["WhatsApp"]
        ))

        return locations
    }

    nonisolated static func productivityCacheLocations(home: URL) -> [CleanupLocation] {
        var locations = folderLocations(
            categoryID: .developer,
            titlePrefix: "Zed",
            detailPrefix: "Zed editor cache",
            root: home.appendingPathComponent("Library/Caches"),
            childPaths: ["Zed"],
            blockedProcessNames: ["Zed"]
        )

        locations.append(contentsOf: folderLocations(
            categoryID: .developer,
            titlePrefix: "Warp",
            detailPrefix: "Warp terminal cache",
            root: home.appendingPathComponent("Library/Caches"),
            childPaths: ["dev.warp.Warp-Stable", "SentryCrash/Warp"],
            blockedProcessNames: ["Warp"]
        ))

        locations.append(contentsOf: folderLocations(
            categoryID: .developer,
            titlePrefix: "Ghostty",
            detailPrefix: "Ghostty terminal cache",
            root: home.appendingPathComponent("Library/Caches"),
            childPaths: ["com.mitchellh.ghostty"],
            blockedProcessNames: ["Ghostty"]
        ))

        locations.append(contentsOf: folderLocations(
            categoryID: .userCaches,
            titlePrefix: "Notion",
            detailPrefix: "Notion cache",
            root: home.appendingPathComponent("Library/Caches"),
            childPaths: ["notion.id"],
            blockedProcessNames: ["Notion"]
        ))

        locations.append(contentsOf: folderLocations(
            categoryID: .userCaches,
            titlePrefix: "Obsidian",
            detailPrefix: "Obsidian cache",
            root: home.appendingPathComponent("Library/Caches"),
            childPaths: ["md.obsidian"],
            blockedProcessNames: ["Obsidian"]
        ))

        locations.append(contentsOf: folderLocations(
            categoryID: .userCaches,
            titlePrefix: "Raycast",
            detailPrefix: "Raycast cache",
            root: home.appendingPathComponent("Library/Application Support/com.raycast.macos"),
            childPaths: ["urlcache", "fsCachedData", "Cache", "Code Cache", "GPUCache"],
            blockedProcessNames: ["Raycast"]
        ))

        return locations
    }

    nonisolated static func mediaCacheLocations(home: URL) -> [CleanupLocation] {
        var locations = folderLocations(
            categoryID: .designTools,
            titlePrefix: "Steam",
            detailPrefix: "Steam regenerable cache",
            root: home.appendingPathComponent("Library/Application Support/Steam"),
            childPaths: ["appcache", "depotcache", "htmlcache", "logs", "shadercache"],
            minimumProfile: .balanced,
            risk: .low,
            defaultSelected: true,
            recommendedMinimumAgeDays: 7,
            blockedProcessNames: ["Steam"]
        )

        locations.append(contentsOf: folderLocations(
            categoryID: .designTools,
            titlePrefix: "Steam",
            detailPrefix: "Steam Library cache",
            root: home.appendingPathComponent("Library/Caches"),
            childPaths: ["com.valvesoftware.steam"],
            recommendedMinimumAgeDays: 7,
            blockedProcessNames: ["Steam"]
        ))

        locations.append(contentsOf: folderLocations(
            categoryID: .designTools,
            titlePrefix: "IINA",
            detailPrefix: "IINA media player cache",
            root: home.appendingPathComponent("Library/Caches"),
            childPaths: ["com.colliderli.iina"],
            blockedProcessNames: ["IINA"]
        ))

        locations.append(contentsOf: folderLocations(
            categoryID: .designTools,
            titlePrefix: "VLC",
            detailPrefix: "VLC media player cache",
            root: home.appendingPathComponent("Library/Caches"),
            childPaths: ["org.videolan.vlc"],
            blockedProcessNames: ["VLC"]
        ))

        return locations
    }
}
