import Foundation

extension CacheCatalog {
    nonisolated static func appSupportCacheLocations(
        categoryID: CleanerCategoryID,
        titlePrefix: String,
        root: URL,
        blockedProcessNames: [String]
    ) -> [CleanupLocation] {
        folderLocations(
            categoryID: categoryID,
            titlePrefix: titlePrefix,
            detailPrefix: "\(titlePrefix) renderer and log cache",
            root: root,
            childPaths: [
                "Cache",
                "Caches",
                "Code Cache",
                "GPUCache",
                "DawnCache",
                "ShaderCache",
                "GrShaderCache",
                "WebGPUCache",
                "CachedData",
                "CachedExtensionVSIXs",
                "logs",
                "Logs",
                "Service Worker/CacheStorage",
                "Service Worker/ScriptCache"
            ],
            blockedProcessNames: blockedProcessNames
        )
    }

    nonisolated static func folderLocations(
        categoryID: CleanerCategoryID,
        titlePrefix: String,
        detailPrefix: String,
        root: URL,
        childPaths: [String],
        minimumProfile: ScanProfile = .balanced,
        risk: CleanupRisk = .low,
        defaultSelected: Bool = true,
        recommendedMinimumAgeDays: Int = 1,
        blockedProcessNames: [String] = []
    ) -> [CleanupLocation] {
        childPaths.map { childPath in
            CleanupLocation(
                categoryID: categoryID,
                title: "\(titlePrefix) \(displayName(forCachePath: childPath))",
                detail: "\(detailPrefix).",
                url: root.appendingPathComponent(childPath),
                kind: .folder,
                minimumProfile: minimumProfile,
                risk: risk,
                defaultSelected: defaultSelected,
                recommendedMinimumAgeDays: recommendedMinimumAgeDays,
                blockedProcessNames: blockedProcessNames
            )
        }
    }

    nonisolated static func isDirectory(_ url: URL, fileManager: FileManager) -> Bool {
        var isDirectory: ObjCBool = false
        return fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory) && isDirectory.boolValue
    }

    nonisolated static func displayName(forCachePath path: String) -> String {
        switch path {
        case "component_crx_cache", "crx_cache":
            return "CRX Cache"
        case "Crashpad/completed":
            return "Crash Reports"
        case "Service Worker/CacheStorage":
            return "Service Worker Cache"
        case "Service Worker/ScriptCache":
            return "Service Worker Scripts"
        case "Browser/Caches":
            return "Browser Cache"
        case "Browser/GPUCache":
            return "Browser GPU Cache"
        case "Browser/Code Cache":
            return "Browser Code Cache"
        default:
            return path
                .split(separator: "/")
                .last
                .map(String.init) ?? path
        }
    }
}
