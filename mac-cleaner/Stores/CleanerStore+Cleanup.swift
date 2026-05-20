import Foundation

extension CleanerStore {
    func requestCleanup() {
        guard canClean else { return }
        if deletionMode == .permanent {
            pendingPermanentItems = selectedItems
            shouldConfirmPermanentCleanup = true
        } else {
            cleanSelected()
        }
    }

    func confirmPermanentCleanup() {
        shouldConfirmPermanentCleanup = false
        let itemsToDelete = pendingPermanentItems.isEmpty ? selectedItems : pendingPermanentItems
        pendingPermanentItems = []
        clean(itemsToDelete, mode: .permanent)
    }

    func cancelPermanentCleanup() {
        shouldConfirmPermanentCleanup = false
        pendingPermanentItems = []
    }

    func cleanSelected() {
        guard canClean else { return }

        let selectedItems = self.selectedItems
        let mode = deletionMode
        clean(selectedItems, mode: mode)
    }

    func clean(_ itemsToClean: [CleanupItem], mode: DeletionMode) {
        guard !itemsToClean.isEmpty, !isBusy else { return }

        isCleaning = true
        cleanupFailures = []
        statusMessage = mode == .trash ? "Moving selected items to Trash..." : "Deleting selected items..."

        Task {
            let result = await Task.detached(priority: .userInitiated) {
                CleanupService().clean(items: itemsToClean, mode: mode)
            }.value

            self.applyCleanupResult(result)
        }
    }

    func applyCleanupResult(_ result: CleanupResult) {
        items.removeAll { result.cleanedIDs.contains($0.id) }
        selectedItemIDs.subtract(result.cleanedIDs)
        cleanupFailures = result.failures
        lastCleanedBytes = result.reclaimedBytes
        lastCleanedItemCount = result.cleanedIDs.count
        totalCleanedBytes += result.reclaimedBytes
        totalCleanedItemCount += result.cleanedIDs.count
        lastCleanedDate = Date()
        defaults.set(totalCleanedBytes, forKey: DefaultsKey.totalCleanedBytes)
        defaults.set(totalCleanedItemCount, forKey: DefaultsKey.totalCleanedItemCount)
        defaults.set(lastCleanedBytes, forKey: DefaultsKey.lastCleanedBytes)
        defaults.set(lastCleanedItemCount, forKey: DefaultsKey.lastCleanedItemCount)
        defaults.set(lastCleanedDate, forKey: DefaultsKey.lastCleanedDate)
        isCleaning = false

        if result.failures.isEmpty {
            statusMessage = result.reclaimedBytes > 0
                ? "\(ByteCountFormat.compact(result.reclaimedBytes)) cleaned"
                : "\(result.cleanedIDs.count) cache item\(result.cleanedIDs.count == 1 ? "" : "s") removed"
        } else {
            statusMessage = "\(ByteCountFormat.compact(result.reclaimedBytes)) cleaned, \(result.failures.count) protected cache item\(result.failures.count == 1 ? "" : "s") skipped"
        }
    }
}
