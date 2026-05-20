import Foundation

extension CleanerStore {
    func scan() {
        guard !isBusy else { return }

        isScanning = true
        cleanupFailures = []
        skippedPaths = []
        statusMessage = "Scanning \(profile.title.lowercased()) locations..."
        let profile = self.profile
        let customLocations = self.customLocations
        let protectRecentItems = self.protectRecentItems

        Task {
            let result = await Task.detached(priority: .userInitiated) {
                CacheScanner().scan(
                    profile: profile,
                    customLocations: customLocations,
                    protectRecentItems: protectRecentItems
                )
            }.value

            self.items = result.items
            self.selectedItemIDs = Set(result.items.filter(\.isRecommended).map(\.id))
            self.skippedPaths = result.skippedPaths
            self.lastScanDate = Date()
            self.isScanning = false
            self.statusMessage = result.items.isEmpty
                ? "No cleanup candidates found"
                : "Scan complete: \(ByteCountFormat.compact(result.items.reduce(0) { $0 + $1.bytes })) found"
        }
    }

    func autoCleanRecommended() {
        autoCleanRecommended(trigger: .manual)
    }

    func autoCleanRecommended(trigger: CleanTrigger) {
        guard !isBusy else { return }

        isScanning = true
        cleanupFailures = []
        skippedPaths = []
        statusMessage = trigger == .scheduled ? "Scheduled cache scan..." : "Scanning cache..."

        let profile = ScanProfile.deep
        let customLocations: [URL] = []
        let protectRecentItems = false

        Task {
            let scanResult = await Task.detached(priority: .userInitiated) {
                CacheScanner().scan(
                    profile: profile,
                    customLocations: customLocations,
                    protectRecentItems: protectRecentItems
                )
            }.value

            let recommendedItems = scanResult.items.filter(\.isRecommended)
            self.items = scanResult.items
            self.selectedItemIDs = Set(recommendedItems.map(\.id))
            self.skippedPaths = scanResult.skippedPaths
            self.lastScanDate = Date()
            self.isScanning = false

            guard !recommendedItems.isEmpty else {
                self.statusMessage = "No cache found"
                if trigger == .scheduled {
                    self.scheduleNextAutoClean(from: Date())
                }
                return
            }

            self.isCleaning = true
            self.statusMessage = "Deleting cache..."

            let cleanupResult = await Task.detached(priority: .userInitiated) {
                CleanupService().clean(items: recommendedItems, mode: .permanent)
            }.value

            self.applyCleanupResult(cleanupResult)
            if trigger == .scheduled {
                self.scheduleNextAutoClean(from: Date())
            }
        }
    }
}
