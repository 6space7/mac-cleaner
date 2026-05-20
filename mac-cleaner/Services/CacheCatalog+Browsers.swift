import Foundation

extension CacheCatalog {
    nonisolated static func chromiumCacheLocations(
        titlePrefix: String,
        root: URL,
        blockedProcessNames: [String]
    ) -> [CleanupLocation] {
        let rootCachePaths = [
            "component_crx_cache",
            "CertificateRevocation",
            "Crashpad/completed"
        ]
        let profileCachePaths = [
            "Cache",
            "Code Cache",
            "GPUCache",
            "DawnCache",
            "ShaderCache",
            "GrShaderCache",
            "WebGPUCache",
            "Service Worker/CacheStorage",
            "Service Worker/ScriptCache"
        ]

        var locations = folderLocations(
            categoryID: .browserStorage,
            titlePrefix: titlePrefix,
            detailPrefix: "\(titlePrefix) browser cache",
            root: root,
            childPaths: rootCachePaths,
            blockedProcessNames: blockedProcessNames
        )

        for profileName in chromiumProfileNames(root: root) {
            locations.append(contentsOf: folderLocations(
                categoryID: .browserStorage,
                titlePrefix: titlePrefix,
                detailPrefix: "\(titlePrefix) profile cache",
                root: root.appendingPathComponent(profileName),
                childPaths: profileCachePaths,
                blockedProcessNames: blockedProcessNames
            ))
        }

        return locations
    }

    nonisolated static func chromiumProfileNames(root: URL) -> [String] {
        var names = Set(["Default"])
        let fileManager = FileManager.default

        guard let children = try? fileManager.contentsOfDirectory(
            at: root,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            return Array(names)
        }

        for child in children {
            guard let values = try? child.resourceValues(forKeys: [.isDirectoryKey]), values.isDirectory == true else {
                continue
            }

            let name = child.lastPathComponent
            if name == "Default" || name == "Guest Profile" || name == "System Profile" || name.hasPrefix("Profile ") {
                names.insert(name)
                continue
            }

            let cacheURL = child.appendingPathComponent("Cache")
            if fileManager.fileExists(atPath: cacheURL.path) {
                names.insert(name)
            }
        }

        return names.sorted()
    }
}
