import Foundation

enum CleanupLocationKind: Sendable, Hashable {
    case children
    case folder
    case matchingFiles(extensions: Set<String>, minimumAgeDays: Int)
    case matchingNames(names: Set<String>, minimumAgeDays: Int)
}

struct CleanupLocation: Identifiable, Hashable, Sendable {
    let id: String
    let categoryID: CleanerCategoryID
    let title: String
    let detail: String
    let url: URL
    let kind: CleanupLocationKind
    let minimumProfile: ScanProfile
    let risk: CleanupRisk
    let defaultSelected: Bool
    let recommendedMinimumAgeDays: Int
    let blockedProcessNames: [String]

    nonisolated init(
        categoryID: CleanerCategoryID,
        title: String,
        detail: String,
        url: URL,
        kind: CleanupLocationKind = .children,
        minimumProfile: ScanProfile = .quick,
        risk: CleanupRisk = .low,
        defaultSelected: Bool = true,
        recommendedMinimumAgeDays: Int = 1,
        blockedProcessNames: [String] = []
    ) {
        self.categoryID = categoryID
        self.title = title
        self.detail = detail
        self.url = url
        self.kind = kind
        self.minimumProfile = minimumProfile
        self.risk = risk
        self.defaultSelected = defaultSelected
        self.recommendedMinimumAgeDays = recommendedMinimumAgeDays
        self.blockedProcessNames = blockedProcessNames
        self.id = "\(categoryID.rawValue):\(url.path):\(title)"
    }
}
