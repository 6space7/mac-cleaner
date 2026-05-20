import Foundation

struct CleanupService {
    nonisolated init() {}

    nonisolated func clean(items: [CleanupItem], mode: DeletionMode) -> CleanupResult {
        let fileManager = FileManager.default
        var cleanedIDs = Set<String>()
        var reclaimedBytes: Int64 = 0
        var failures: [CleanupFailure] = []
        var privilegedRetryItems: [CleanupItem] = []

        for item in items {
            guard !ProtectedCachePolicy.isProtected(item.url) else {
                continue
            }

            guard fileManager.fileExists(atPath: item.path) else {
                cleanedIDs.insert(item.id)
                continue
            }

            do {
                switch mode {
                case .trash:
                    _ = try fileManager.trashItem(at: item.url, resultingItemURL: nil)
                case .permanent:
                    try fileManager.removeItem(at: item.url)
                }

                cleanedIDs.insert(item.id)
                reclaimedBytes += item.bytes
            } catch {
                if !fileManager.fileExists(atPath: item.path) {
                    cleanedIDs.insert(item.id)
                    reclaimedBytes += item.bytes
                    continue
                }

                if shouldRetryWithAdminPermission(error: error, item: item, mode: mode) {
                    privilegedRetryItems.append(item)
                    continue
                }

                failures.append(
                    CleanupFailure(
                        displayName: item.displayName,
                        path: item.path,
                        message: cleanupMessage(for: error)
                    )
                )
            }
        }

        if !privilegedRetryItems.isEmpty {
            let privilegedResult = deleteWithAdminPermission(privilegedRetryItems, fileManager: fileManager)
            cleanedIDs.formUnion(privilegedResult.cleanedIDs)
            reclaimedBytes += privilegedResult.reclaimedBytes
            failures.append(contentsOf: privilegedResult.failures)
        }

        return CleanupResult(
            cleanedIDs: cleanedIDs,
            reclaimedBytes: reclaimedBytes,
            failures: failures
        )
    }

    private nonisolated func shouldRetryWithAdminPermission(
        error: Error,
        item: CleanupItem,
        mode: DeletionMode
    ) -> Bool {
        guard mode == .permanent, item.isRecommended, item.risk != .high else {
            return false
        }

        return isPermissionError(error)
    }

    private nonisolated func deleteWithAdminPermission(
        _ items: [CleanupItem],
        fileManager: FileManager
    ) -> CleanupResult {
        let existingItems = items.filter {
            !ProtectedCachePolicy.isProtected($0.url)
            && fileManager.fileExists(atPath: $0.path)
        }
        guard !existingItems.isEmpty else {
            return CleanupResult(
                cleanedIDs: Set(items.map(\.id)),
                reclaimedBytes: 0,
                failures: []
            )
        }

        let process = Process()
        let output = Pipe()
        let scriptLines = [
            "on run argv",
            "set commandText to \"/bin/rm -rf --\"",
            "repeat with rawPath in argv",
            "set commandText to commandText & \" \" & quoted form of rawPath",
            "end repeat",
            "do shell script commandText with administrator privileges",
            "end run"
        ]

        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = scriptLines.flatMap { ["-e", $0] } + existingItems.map(\.path)
        process.standardOutput = output
        process.standardError = output

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return CleanupResult(
                cleanedIDs: [],
                reclaimedBytes: 0,
                failures: existingItems.map {
                    CleanupFailure(
                        displayName: $0.displayName,
                        path: $0.path,
                        message: "admin prompt could not be shown"
                    )
                }
            )
        }

        let outputData = output.fileHandleForReading.readDataToEndOfFile()
        let outputText = String(data: outputData, encoding: .utf8) ?? ""

        var cleanedIDs = Set<String>()
        var reclaimedBytes: Int64 = 0
        var failures: [CleanupFailure] = []

        for item in existingItems {
            if fileManager.fileExists(atPath: item.path) {
                failures.append(
                    CleanupFailure(
                        displayName: item.displayName,
                        path: item.path,
                        message: adminPermissionFailureMessage(status: process.terminationStatus, output: outputText)
                    )
                )
            } else {
                cleanedIDs.insert(item.id)
                reclaimedBytes += item.bytes
            }
        }

        return CleanupResult(
            cleanedIDs: cleanedIDs,
            reclaimedBytes: reclaimedBytes,
            failures: failures
        )
    }

    private nonisolated func adminPermissionFailureMessage(status: Int32, output: String) -> String {
        let lowercasedOutput = output.lowercased()

        if status == -128 || lowercasedOutput.contains("user canceled") || lowercasedOutput.contains("cancelled") {
            return "admin permission was not granted"
        }

        if lowercasedOutput.contains("not allowed") || lowercasedOutput.contains("operation not permitted") {
            return "macOS privacy settings blocked access"
        }

        return "admin delete did not remove it"
    }

    private nonisolated func isPermissionError(_ error: Error) -> Bool {
        let nsError = error as NSError

        if nsError.domain == NSCocoaErrorDomain {
            let cocoaCode = CocoaError.Code(rawValue: nsError.code)
            switch cocoaCode {
            case .fileReadNoPermission, .fileWriteNoPermission:
                return true
            default:
                break
            }
        }

        if nsError.domain == NSPOSIXErrorDomain {
            return nsError.code == 1 || nsError.code == 13
        }

        if let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? NSError,
           underlyingError.domain == NSPOSIXErrorDomain {
            return underlyingError.code == 1 || underlyingError.code == 13
        }

        return false
    }

    private nonisolated func cleanupMessage(for error: Error) -> String {
        let nsError = error as NSError
        guard nsError.domain == NSCocoaErrorDomain else {
            return nsError.localizedFailureReason ?? nsError.localizedDescription
        }

        let cocoaCode = CocoaError.Code(rawValue: nsError.code)

        switch cocoaCode {
        case .fileReadNoPermission, .fileWriteNoPermission:
            return "macOS denied permission"
        case .fileWriteVolumeReadOnly:
            return "the volume is read-only"
        case .fileNoSuchFile:
            return "it was already removed"
        default:
            return nsError.localizedFailureReason ?? nsError.localizedDescription
        }
    }
}
