import Foundation

extension CacheScanner {
    nonisolated func scan(location: CleanupLocation, fileManager: FileManager) -> [CleanupItem] {
        switch location.kind {
        case .children:
            return scanChildren(of: location, fileManager: fileManager)
        case .folder:
            guard let item = makeItem(for: location.url, location: location, fileManager: fileManager) else {
                return []
            }
            return [item]
        case .matchingFiles(let extensions, let minimumAgeDays):
            return scanMatchingFiles(
                in: location,
                extensions: extensions,
                minimumAgeDays: minimumAgeDays,
                fileManager: fileManager
            )
        case .matchingNames(let names, let minimumAgeDays):
            return scanMatchingNames(
                in: location,
                names: names,
                minimumAgeDays: minimumAgeDays,
                fileManager: fileManager
            )
        }
    }

    nonisolated func scanChildren(of location: CleanupLocation, fileManager: FileManager) -> [CleanupItem] {
        guard let children = try? fileManager.contentsOfDirectory(
            at: location.url,
            includingPropertiesForKeys: [.isDirectoryKey, .isSymbolicLinkKey, .contentModificationDateKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        return children.compactMap {
            makeItem(for: $0, location: location, fileManager: fileManager)
        }
    }

    nonisolated func scanMatchingFiles(
        in location: CleanupLocation,
        extensions allowedExtensions: Set<String>,
        minimumAgeDays: Int,
        fileManager: FileManager
    ) -> [CleanupItem] {
        guard let enumerator = fileManager.enumerator(
            at: location.url,
            includingPropertiesForKeys: [.isDirectoryKey, .isSymbolicLinkKey, .contentModificationDateKey, .fileSizeKey, .totalFileAllocatedSizeKey],
            options: [.skipsPackageDescendants, .skipsHiddenFiles],
            errorHandler: { _, _ in true }
        ) else {
            return []
        }

        let cutoff = Date().addingTimeInterval(-Double(minimumAgeDays) * 86_400)
        var items: [CleanupItem] = []

        for case let url as URL in enumerator {
            guard let values = try? url.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey, .contentModificationDateKey]) else {
                continue
            }

            if values.isSymbolicLink == true {
                enumerator.skipDescendants()
                continue
            }

            if values.isDirectory == true {
                continue
            }

            let ext = url.pathExtension.lowercased()
            guard allowedExtensions.contains(ext) else {
                continue
            }

            if let modifiedAt = values.contentModificationDate, modifiedAt > cutoff {
                continue
            }

            if let item = makeItem(for: url, location: location, fileManager: fileManager) {
                items.append(item)
            }
        }

        return items
    }

    nonisolated func scanMatchingNames(
        in location: CleanupLocation,
        names allowedNames: Set<String>,
        minimumAgeDays: Int,
        fileManager: FileManager
    ) -> [CleanupItem] {
        guard let enumerator = fileManager.enumerator(
            at: location.url,
            includingPropertiesForKeys: [.isDirectoryKey, .isSymbolicLinkKey, .contentModificationDateKey, .fileSizeKey, .totalFileAllocatedSizeKey],
            options: [.skipsPackageDescendants],
            errorHandler: { _, _ in true }
        ) else {
            return []
        }

        let cutoff = Date().addingTimeInterval(-Double(minimumAgeDays) * 86_400)
        var items: [CleanupItem] = []

        for case let url as URL in enumerator {
            guard allowedNames.contains(url.lastPathComponent) else {
                continue
            }

            guard let values = try? url.resourceValues(forKeys: [.isSymbolicLinkKey, .contentModificationDateKey]) else {
                continue
            }

            if values.isSymbolicLink == true {
                enumerator.skipDescendants()
                continue
            }

            if let modifiedAt = values.contentModificationDate, modifiedAt > cutoff {
                continue
            }

            if let item = makeItem(for: url, location: location, fileManager: fileManager) {
                items.append(item)
            }

            enumerator.skipDescendants()
        }

        return items
    }
}
