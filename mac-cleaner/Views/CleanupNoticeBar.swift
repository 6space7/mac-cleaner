import SwiftUI

struct CleanupNoticeBar: View {
    @ObservedObject var store: CleanerStore

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: store.cleanupFailures.isEmpty ? "exclamationmark.triangle" : "xmark.octagon")
                .foregroundStyle(store.cleanupFailures.isEmpty ? FocusedCleanerPalette.amber : FocusedCleanerPalette.rose)

            Text(message)
                .font(.caption)
                .foregroundStyle(FocusedCleanerPalette.secondaryText)
                .lineLimit(2)

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(FocusedCleanerPalette.panel, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(FocusedCleanerPalette.stroke, lineWidth: 1))
    }

    private var message: String {
        if let failure = store.cleanupFailures.first {
            let remainingCount = store.cleanupFailures.count - 1
            let suffix = remainingCount > 0 ? " (+\(remainingCount) more)" : ""
            return "Skipped \(failure.displayName): \(failure.message)\(suffix)"
        }

        return "Some cache folders were skipped because their apps are running."
    }
}
