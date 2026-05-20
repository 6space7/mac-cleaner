import Foundation

struct CacheScanner {
    nonisolated init() {}

    nonisolated func scan(
        profile: ScanProfile,
        customLocations: [URL],
        protectRecentItems: Bool
    ) -> ScanResult {
        let fileManager = FileManager.default
        let locations = CacheCatalog.locations(
            profile: profile,
            customLocations: customLocations,
            fileManager: fileManager
        )
        .sorted { priority(for: $0) < priority(for: $1) }

        var seenPaths = Set<String>()
        var items: [CleanupItem] = []
        var skippedPaths: [String] = []

        for location in locations {
            guard fileManager.fileExists(atPath: location.url.path) else {
                continue
            }

            if isBlockedByRunningProcess(location.blockedProcessNames) {
                skippedPaths.append("\(location.url.path) (app is running)")
                continue
            }

            if ProtectedCachePolicy.isProtected(location.url) {
                continue
            }

            let scannedItems = scan(location: location, fileManager: fileManager)
            for item in scannedItems where !seenPaths.contains(item.path) && !item.isEmpty {
                seenPaths.insert(item.path)
                items.append(item)
            }
        }

        let sortedItems = items.sorted {
            if $0.bytes == $1.bytes {
                return $0.displayName.localizedStandardCompare($1.displayName) == .orderedAscending
            }
            return $0.bytes > $1.bytes
        }

        if protectRecentItems {
            return ScanResult(items: sortedItems, skippedPaths: skippedPaths)
        }

        let relaxedItems = sortedItems.map { item in
            guard item.risk != .high else { return item }
            return CleanupItem(
                id: item.id,
                url: item.url,
                categoryID: item.categoryID,
                displayName: item.displayName,
                locationTitle: item.locationTitle,
                detail: item.detail,
                bytes: item.bytes,
                fileCount: item.fileCount,
                modifiedAt: item.modifiedAt,
                risk: item.risk,
                isRecommended: item.risk != .high
            )
        }
        return ScanResult(items: relaxedItems, skippedPaths: skippedPaths)
    }

    private nonisolated func priority(for location: CleanupLocation) -> Int {
        switch location.title {
        case "Library Caches", "User Logs":
            return 50
        default:
            return location.categoryID == .userCaches ? 10 : 0
        }
    }

    private nonisolated func isBlockedByRunningProcess(_ processNames: [String]) -> Bool {
        processNames.contains { isProcessRunning($0) }
    }

    private nonisolated func isProcessRunning(_ processName: String) -> Bool {
        guard !processName.isEmpty else { return false }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/pgrep")
        process.arguments = ["-x", processName]
        process.standardOutput = Pipe()
        process.standardError = Pipe()

        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch {
            return false
        }
    }

}
