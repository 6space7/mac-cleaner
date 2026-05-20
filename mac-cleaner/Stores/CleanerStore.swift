import Foundation
import Combine

@MainActor
final class CleanerStore: ObservableObject {
    @Published var profile: ScanProfile {
        didSet { defaults.set(profile.rawValue, forKey: DefaultsKey.profile) }
    }
    @Published var deletionMode: DeletionMode {
        didSet { defaults.set(deletionMode.rawValue, forKey: DefaultsKey.deletionMode) }
    }
    @Published var protectRecentItems: Bool {
        didSet { defaults.set(protectRecentItems, forKey: DefaultsKey.protectRecentItems) }
    }
    @Published var autoCleanEnabled: Bool {
        didSet {
            defaults.set(autoCleanEnabled, forKey: DefaultsKey.autoCleanEnabled)
            configureAutoCleanTimer()
        }
    }
    @Published var autoCleanInterval: AutoCleanInterval {
        didSet {
            defaults.set(autoCleanInterval.rawValue, forKey: DefaultsKey.autoCleanInterval)
            configureAutoCleanTimer()
        }
    }
    @Published var items: [CleanupItem] = []
    @Published var selectedItemIDs: Set<String> = []
    @Published var searchText: String = ""
    @Published var isScanning = false
    @Published var isCleaning = false
    @Published var lastScanDate: Date?
    @Published var lastCleanedBytes: Int64 = 0
    @Published var lastCleanedItemCount = 0
    @Published var totalCleanedBytes: Int64 = 0
    @Published var totalCleanedItemCount = 0
    @Published var lastCleanedDate: Date?
    @Published var nextAutoCleanDate: Date?
    @Published var skippedPaths: [String] = []
    @Published var cleanupFailures: [CleanupFailure] = []
    @Published var statusMessage = "Ready to scan"
    @Published var customLocations: [URL] = []
    @Published var shouldConfirmPermanentCleanup = false
    @Published var pendingPermanentItems: [CleanupItem] = []

    let categories = CacheCatalog.categories

    let defaults = UserDefaults.standard
    var autoCleanTimer: Timer?

    init() {
        let profileRaw = UserDefaults.standard.string(forKey: DefaultsKey.profile)
        self.profile = profileRaw.flatMap(ScanProfile.init(rawValue:)) ?? .balanced

        let deletionRaw = UserDefaults.standard.string(forKey: DefaultsKey.deletionMode)
        self.deletionMode = deletionRaw.flatMap(DeletionMode.init(rawValue:)) ?? .trash

        if UserDefaults.standard.object(forKey: DefaultsKey.protectRecentItems) == nil {
            self.protectRecentItems = true
        } else {
            self.protectRecentItems = UserDefaults.standard.bool(forKey: DefaultsKey.protectRecentItems)
        }

        if UserDefaults.standard.object(forKey: DefaultsKey.autoCleanEnabled) == nil {
            self.autoCleanEnabled = false
        } else {
            self.autoCleanEnabled = UserDefaults.standard.bool(forKey: DefaultsKey.autoCleanEnabled)
        }

        let intervalRaw = UserDefaults.standard.integer(forKey: DefaultsKey.autoCleanInterval)
        self.autoCleanInterval = AutoCleanInterval(rawValue: intervalRaw) ?? .fourHours

        self.totalCleanedBytes = (UserDefaults.standard.object(forKey: DefaultsKey.totalCleanedBytes) as? NSNumber)?.int64Value ?? 0
        self.totalCleanedItemCount = UserDefaults.standard.integer(forKey: DefaultsKey.totalCleanedItemCount)
        self.lastCleanedBytes = (UserDefaults.standard.object(forKey: DefaultsKey.lastCleanedBytes) as? NSNumber)?.int64Value ?? 0
        self.lastCleanedItemCount = UserDefaults.standard.integer(forKey: DefaultsKey.lastCleanedItemCount)
        self.lastCleanedDate = UserDefaults.standard.object(forKey: DefaultsKey.lastCleanedDate) as? Date
        self.nextAutoCleanDate = UserDefaults.standard.object(forKey: DefaultsKey.nextAutoCleanDate) as? Date

        configureAutoCleanTimer()
    }

    var isBusy: Bool {
        isScanning || isCleaning
    }

    var canClean: Bool {
        !selectedItemIDs.isEmpty && !isBusy
    }

    var totalBytes: Int64 {
        items.reduce(0) { $0 + $1.bytes }
    }

    var selectedBytes: Int64 {
        items.filter { selectedItemIDs.contains($0.id) }.reduce(0) { $0 + $1.bytes }
    }

    var recommendedBytes: Int64 {
        items.filter(\.isRecommended).reduce(0) { $0 + $1.bytes }
    }

    var recommendedItemCount: Int {
        items.filter(\.isRecommended).count
    }

    var nextAutoCleanText: String {
        guard autoCleanEnabled else { return "Off" }
        guard let nextAutoCleanDate else { return "Soon" }
        return DateFormat.relative.localizedString(for: nextAutoCleanDate, relativeTo: Date())
    }

    var selectedItems: [CleanupItem] {
        items.filter { selectedItemIDs.contains($0.id) }
    }

    var filteredItems: [CleanupItem] {
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSearch.isEmpty else {
            return items
        }

        return items.filter {
            $0.displayName.localizedCaseInsensitiveContains(trimmedSearch)
            || $0.path.localizedCaseInsensitiveContains(trimmedSearch)
            || $0.locationTitle.localizedCaseInsensitiveContains(trimmedSearch)
        }
    }

    var primaryCleanupTitle: String {
        deletionMode == .trash ? "Move Selected to Trash" : "Delete Selected"
    }

    var pendingPermanentBytes: Int64 {
        pendingPermanentItems.reduce(0) { $0 + $1.bytes }
    }

}

enum DefaultsKey {
    static let profile = "CleanerProfile"
    static let deletionMode = "CleanerDeletionMode"
    static let protectRecentItems = "CleanerProtectRecentItems"
    static let autoCleanEnabled = "CleanerAutoCleanEnabled"
    static let autoCleanInterval = "CleanerAutoCleanInterval"
    static let lastCleanedBytes = "CleanerLastCleanedBytes"
    static let lastCleanedItemCount = "CleanerLastCleanedItemCount"
    static let totalCleanedBytes = "CleanerTotalCleanedBytes"
    static let totalCleanedItemCount = "CleanerTotalCleanedItemCount"
    static let lastCleanedDate = "CleanerLastCleanedDate"
    static let nextAutoCleanDate = "CleanerNextAutoCleanDate"
}

enum CleanTrigger {
    case manual
    case scheduled
}
