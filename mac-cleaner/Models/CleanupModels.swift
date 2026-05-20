import Foundation

enum CleanerCategoryID: String, CaseIterable, Identifiable, Sendable {
    case userCaches
    case appContainers
    case browserStorage
    case logs
    case developer
    case packages
    case aiTools
    case communication
    case designTools
    case installers
    case custom

    nonisolated var id: String { rawValue }
}

struct CleanerCategory: Identifiable, Hashable, Sendable {
    let id: CleanerCategoryID
    let title: String
    let subtitle: String
    let systemImage: String
}

enum ScanProfile: String, CaseIterable, Identifiable, Sendable {
    case quick
    case balanced
    case deep

    nonisolated var id: String { rawValue }

    nonisolated var title: String {
        switch self {
        case .quick:
            return "Quick"
        case .balanced:
            return "Balanced"
        case .deep:
            return "Deep"
        }
    }

    nonisolated var detail: String {
        switch self {
        case .quick:
            return "Common user caches and logs."
        case .balanced:
            return "Adds developer and package caches."
        case .deep:
            return "Includes containers, installers, and custom folders."
        }
    }

    nonisolated var rank: Int {
        switch self {
        case .quick:
            return 0
        case .balanced:
            return 1
        case .deep:
            return 2
        }
    }

    nonisolated func includes(_ other: ScanProfile) -> Bool {
        rank >= other.rank
    }
}

enum CleanupRisk: String, CaseIterable, Identifiable, Sendable {
    case low
    case medium
    case high

    nonisolated var id: String { rawValue }

    nonisolated var title: String {
        switch self {
        case .low:
            return "Safe"
        case .medium:
            return "Review"
        case .high:
            return "Manual"
        }
    }
}

enum DeletionMode: String, CaseIterable, Identifiable, Sendable {
    case trash
    case permanent

    nonisolated var id: String { rawValue }

    nonisolated var title: String {
        switch self {
        case .trash:
            return "Move to Trash"
        case .permanent:
            return "Delete Immediately"
        }
    }

    nonisolated var detail: String {
        switch self {
        case .trash:
            return "Reversible and safer. Space is reclaimed after Trash is emptied."
        case .permanent:
            return "Frees space now, but cannot be undone."
        }
    }
}

enum AutoCleanInterval: Int, CaseIterable, Identifiable, Sendable {
    case oneHour = 1
    case twoHours = 2
    case fourHours = 4
    case eightHours = 8
    case twelveHours = 12

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .oneHour:
            return "Every hour"
        case .twoHours:
            return "Every 2 hours"
        case .fourHours:
            return "Every 4 hours"
        case .eightHours:
            return "Every 8 hours"
        case .twelveHours:
            return "Every 12 hours"
        }
    }

    var seconds: TimeInterval {
        TimeInterval(rawValue) * 3_600
    }
}

struct CleanupItem: Identifiable, Hashable, Sendable {
    let id: String
    let url: URL
    let categoryID: CleanerCategoryID
    let displayName: String
    let locationTitle: String
    let detail: String
    let bytes: Int64
    let fileCount: Int
    let modifiedAt: Date?
    let risk: CleanupRisk
    let isRecommended: Bool

    nonisolated var path: String {
        url.path
    }

    nonisolated var isEmpty: Bool {
        bytes <= 0 && fileCount == 0
    }
}

struct ScanResult: Sendable {
    let items: [CleanupItem]
    let skippedPaths: [String]
}

struct CleanupFailure: Identifiable, Hashable, Sendable {
    let id = UUID()
    let displayName: String
    let path: String
    let message: String
}

struct CleanupResult: Sendable {
    let cleanedIDs: Set<String>
    let reclaimedBytes: Int64
    let failures: [CleanupFailure]
}
