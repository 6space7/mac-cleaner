import Foundation

enum ProtectedCachePolicy {
    nonisolated private static let explicitlyAllowedPathFragments = [
        "/library/caches/com.apple.dt.xcode",
        "/library/caches/com.apple.dt.instruments",
        "/library/caches/com.apple.dt.xctest",
        "/library/caches/com.apple.ibtool",
        "/library/caches/com.apple.akd",
        "/library/caches/com.apple.applemediaservices",
        "/library/caches/com.apple.duetexpertd",
        "/library/caches/com.apple.e5rt.e5bundlecache",
        "/library/caches/com.apple.helpd",
        "/library/caches/com.apple.iconservices",
        "/library/caches/com.apple.parsecd",
        "/library/caches/com.apple.photoanalysisd",
        "/library/caches/com.apple.python",
        "/library/caches/com.apple.quicklook.thumbnailcache",
        "/library/caches/com.apple.webkit.networking"
    ]

    nonisolated private static let protectedPathFragments = [
        "/library/caches/cloudkit",
        "/library/caches/familycircle",
        "/library/caches/familycircled",
        "/library/caches/knowledge-agent",
        "/library/caches/ms-playwright",
        "/library/caches/com.apple.",
        "/library/application support/cloudkit",
        "/library/application support/clouddocs",
        "/library/application support/knowledge",
        "/library/application support/addressbook",
        "/library/application support/callhistory",
        "/library/application support/com.apple.tcc",
        "/library/application support/com.apple.sharedfilelist",
        "/library/application support/com.apple.siriactions",
        "/library/application support/com.apple.workflowkit",
        "/library/containers/com.apple.",
        "/library/containers/group.com.apple.",
        "/library/containers/systemgroup.com.apple.",
        "/library/group containers/com.apple.",
        "/library/group containers/group.com.apple.",
        "/library/group containers/systemgroup.com.apple.",
        "/library/mobile documents",
        "/library/messages",
        "/library/mail",
        "/library/accounts",
        "/library/calendars",
        "/library/reminders",
        "/library/safari",
        "/library/homekit"
    ]

    nonisolated private static let protectedNameFragments = [
        "familycircle",
        "familycircled",
        "cloudkit",
        "cloudd",
        "clouddocs",
        "cloudtelemetry",
        "icloud",
        "homekit",
        "homed",
        "containermanagerd",
        "knowledge-agent",
        "systempreferences",
        "systemsettings",
        "controlcenter",
        "com.apple.security",
        "com.apple.account",
        "com.apple.accounts",
        "com.apple.identityservices",
        "com.apple.icloud",
        "com.apple.imagent",
        "com.apple.imessage",
        "com.apple.mail",
        "com.apple.safari",
        "com.apple.tcc",
        "com.apple.sharedfilelist",
        "com.apple.ap.adprivacyd",
        "com.apple.bird",
        "com.apple.cloudd",
        "com.apple.cloudkit",
        "com.apple.finder",
        "com.apple.dock",
        "coreaudio",
        "coreaudiod"
    ]

    nonisolated static func isProtected(_ url: URL) -> Bool {
        let path = normalizedPath(for: url)
        let lastPathComponent = url.standardizedFileURL.lastPathComponent.lowercased()

        if isExplicitlyAllowed(path: path) {
            return false
        }

        if protectedPathFragments.contains(where: { path.contains($0) }) {
            return true
        }

        if isAppleOwnedContainer(url) {
            return true
        }

        return protectedNameFragments.contains { lastPathComponent.contains($0) }
    }

    nonisolated static func isAppleOwnedContainer(_ url: URL) -> Bool {
        let standardizedURL = url.standardizedFileURL
        let path = standardizedURL.path.lowercased()
        let lastPathComponent = standardizedURL.lastPathComponent.lowercased()

        guard path.contains("/library/containers/") || path.contains("/library/group containers/") else {
            return false
        }

        return lastPathComponent.hasPrefix("com.apple.")
            || lastPathComponent.hasPrefix("group.com.apple.")
            || lastPathComponent.hasPrefix("systemgroup.com.apple.")
    }

    nonisolated private static func isExplicitlyAllowed(path: String) -> Bool {
        explicitlyAllowedPathFragments.contains { path.contains($0) }
    }

    nonisolated private static func normalizedPath(for url: URL) -> String {
        url.standardizedFileURL.path.lowercased()
    }
}
