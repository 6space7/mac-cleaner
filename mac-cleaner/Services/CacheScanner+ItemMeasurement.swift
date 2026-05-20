import Foundation

extension CacheScanner {
    nonisolated func makeItem(
        for url: URL,
        location: CleanupLocation,
        fileManager: FileManager
    ) -> CleanupItem? {
        guard !ProtectedCachePolicy.isProtected(url) else {
            return nil
        }

        let stats = measure(url: url, fileManager: fileManager)
        guard stats.exists else {
            return nil
        }

        let modifiedAt = stats.latestModificationDate
        let isOldEnough = modifiedAt.map {
            Date().timeIntervalSince($0) >= Double(location.recommendedMinimumAgeDays) * 86_400
        } ?? true
        let isRecommended = location.defaultSelected && location.risk != .high && isOldEnough

        return CleanupItem(
            id: url.standardizedFileURL.path,
            url: url,
            categoryID: location.categoryID,
            displayName: url.lastPathComponent.isEmpty ? location.title : url.lastPathComponent,
            locationTitle: location.title,
            detail: location.detail,
            bytes: stats.bytes,
            fileCount: stats.itemCount,
            modifiedAt: modifiedAt,
            risk: location.risk,
            isRecommended: isRecommended
        )
    }

    nonisolated func measure(url: URL, fileManager: FileManager) -> FileStats {
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
            return FileStats(exists: false, bytes: 0, itemCount: 0, latestModificationDate: nil)
        }

        let keys: Set<URLResourceKey> = [
            .isDirectoryKey,
            .isSymbolicLinkKey,
            .contentModificationDateKey,
            .fileSizeKey,
            .fileAllocatedSizeKey,
            .totalFileAllocatedSizeKey,
            .totalFileSizeKey
        ]

        var bytes: Int64 = 0
        var itemCount = 0
        var latestModificationDate: Date?

        func accumulate(_ resourceURL: URL) {
            guard let values = try? resourceURL.resourceValues(forKeys: keys) else {
                return
            }

            itemCount += 1
            if let date = values.contentModificationDate {
                if latestModificationDate == nil || date > latestModificationDate! {
                    latestModificationDate = date
                }
            }

            if values.isDirectory != true {
                let size = values.totalFileAllocatedSize
                    ?? values.fileAllocatedSize
                    ?? values.totalFileSize
                    ?? values.fileSize
                    ?? 0
                bytes += Int64(size)
            }
        }

        accumulate(url)

        guard isDirectory.boolValue else {
            return FileStats(
                exists: true,
                bytes: bytes,
                itemCount: itemCount,
                latestModificationDate: latestModificationDate
            )
        }

        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: Array(keys),
            options: [.skipsPackageDescendants],
            errorHandler: { _, _ in true }
        ) else {
            return FileStats(
                exists: true,
                bytes: bytes,
                itemCount: itemCount,
                latestModificationDate: latestModificationDate
            )
        }

        for case let childURL as URL in enumerator {
            guard let values = try? childURL.resourceValues(forKeys: [.isSymbolicLinkKey]) else {
                continue
            }

            if values.isSymbolicLink == true {
                enumerator.skipDescendants()
            }
            accumulate(childURL)
        }

        return FileStats(
            exists: true,
            bytes: bytes,
            itemCount: itemCount,
            latestModificationDate: latestModificationDate
        )
    }
}

struct FileStats {
    let exists: Bool
    let bytes: Int64
    let itemCount: Int
    let latestModificationDate: Date?
}
