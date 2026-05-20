import Foundation

extension CleanerStore {
    func items(for categoryID: CleanerCategoryID) -> [CleanupItem] {
        filteredItems.filter { $0.categoryID == categoryID }
    }

    func totalBytes(for categoryID: CleanerCategoryID) -> Int64 {
        items.filter { $0.categoryID == categoryID }.reduce(0) { $0 + $1.bytes }
    }

    func selectedBytes(for categoryID: CleanerCategoryID) -> Int64 {
        items.filter { $0.categoryID == categoryID && selectedItemIDs.contains($0.id) }.reduce(0) { $0 + $1.bytes }
    }

    func itemCount(for categoryID: CleanerCategoryID) -> Int {
        items.filter { $0.categoryID == categoryID }.count
    }

    func selectRecommended() {
        selectedItemIDs = Set(items.filter(\.isRecommended).map(\.id))
    }

    func clearSelection() {
        selectedItemIDs.removeAll()
    }

    func toggleSelection(for item: CleanupItem, isSelected: Bool) {
        if isSelected {
            selectedItemIDs.insert(item.id)
        } else {
            selectedItemIDs.remove(item.id)
        }
    }

    func toggleCategory(_ categoryID: CleanerCategoryID, isSelected: Bool) {
        let ids = items.filter { $0.categoryID == categoryID }.map(\.id)
        if isSelected {
            selectedItemIDs.formUnion(ids)
        } else {
            selectedItemIDs.subtract(ids)
        }
    }

    func isCategoryFullySelected(_ categoryID: CleanerCategoryID) -> Bool {
        let ids = items.filter { $0.categoryID == categoryID }.map(\.id)
        return !ids.isEmpty && ids.allSatisfy { selectedItemIDs.contains($0) }
    }

    func addCustomLocation(_ url: URL) {
        guard !customLocations.contains(url) else { return }
        customLocations.append(url)
        profile = .deep
        statusMessage = "Added \(url.lastPathComponent.isEmpty ? url.path : url.lastPathComponent) to Deep Scan"
    }
}
