import Foundation

extension CacheCatalog {
    nonisolated static func applicationSupportRegenerableLocations(
        root: URL,
        fileManager: FileManager
    ) -> [CleanupLocation] {
        guard let appDirectories = try? fileManager.contentsOfDirectory(
            at: root,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        let childPaths = [
            "Cache",
            "Caches",
            "CachedData",
            "Code Cache",
            "GPUCache",
            "DawnCache",
            "ShaderCache",
            "GrShaderCache",
            "WebGPUCache",
            "Crashpad/completed",
            "logs",
            "Logs",
            "Service Worker/CacheStorage",
            "Service Worker/ScriptCache"
        ]

        return appDirectories.flatMap { appDirectory -> [CleanupLocation] in
            guard isDirectory(appDirectory, fileManager: fileManager),
                  !ProtectedCachePolicy.isProtected(appDirectory) else {
                return []
            }

            return childPaths.compactMap { childPath in
                let cacheURL = appDirectory.appendingPathComponent(childPath)
                guard isDirectory(cacheURL, fileManager: fileManager),
                      !ProtectedCachePolicy.isProtected(cacheURL) else {
                    return nil
                }

                return CleanupLocation(
                    categoryID: .userCaches,
                    title: "\(appDirectory.lastPathComponent) \(displayName(forCachePath: childPath))",
                    detail: "Regenerable Application Support cache.",
                    url: cacheURL,
                    kind: .folder,
                    minimumProfile: .balanced,
                    risk: .low,
                    defaultSelected: true,
                    recommendedMinimumAgeDays: 2
                )
            }
        }
    }

    nonisolated static func containerCacheLocations(
        categoryID: CleanerCategoryID,
        root: URL,
        relativeCachePath: String,
        fileManager: FileManager
    ) -> [CleanupLocation] {
        guard let children = try? fileManager.contentsOfDirectory(
            at: root,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        return children.compactMap { appContainer in
            guard !ProtectedCachePolicy.isProtected(appContainer) else {
                return nil
            }

            let cacheURL = appContainer.appendingPathComponent(relativeCachePath)
            var isDirectory: ObjCBool = false
            guard fileManager.fileExists(atPath: cacheURL.path, isDirectory: &isDirectory),
                  isDirectory.boolValue,
                  !ProtectedCachePolicy.isProtected(cacheURL) else {
                return nil
            }

            return CleanupLocation(
                categoryID: categoryID,
                title: appContainer.lastPathComponent,
                detail: "Sandbox cache contents for \(appContainer.lastPathComponent).",
                url: cacheURL,
                minimumProfile: .balanced,
                risk: .low,
                defaultSelected: true,
                recommendedMinimumAgeDays: 7
            )
        }
    }
}
