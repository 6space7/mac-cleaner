import SwiftUI

struct FocusedCleanerHomeView: View {
    @ObservedObject var store: CleanerStore

    private let metricColumns = [
        GridItem(.flexible(minimum: 132), spacing: 12),
        GridItem(.flexible(minimum: 132), spacing: 12),
        GridItem(.flexible(minimum: 132), spacing: 12),
        GridItem(.flexible(minimum: 132), spacing: 12)
    ]

    var body: some View {
        ZStack {
            FocusedCleanerPalette.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                FocusedHeader(store: store)

                Spacer(minLength: 22)

                VStack(spacing: 24) {
                    CleanupCoreButton(store: store)

                    VStack(spacing: 8) {
                        Text("Cache Cleaner")
                            .font(.system(size: 36, weight: .semibold, design: .rounded))

                        Text(store.statusMessage)
                            .font(.headline)
                            .foregroundStyle(FocusedCleanerPalette.secondaryText)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 460)
                    }
                }

                Spacer(minLength: 24)

                VStack(spacing: 12) {
                    LazyVGrid(columns: metricColumns, spacing: 12) {
                        CleanerMetricTile(
                            title: "Last Deleted",
                            value: ByteCountFormat.compact(store.lastCleanedBytes),
                            detail: lastCleanDetail,
                            symbol: "clock.arrow.circlepath"
                        )
                        CleanerMetricTile(
                            title: "Total Deleted",
                            value: ByteCountFormat.compact(store.totalCleanedBytes),
                            detail: "\(store.totalCleanedItemCount) items removed",
                            symbol: "externaldrive.badge.checkmark"
                        )
                        CleanerMetricTile(
                            title: "Safe Found",
                            value: ByteCountFormat.compact(store.recommendedBytes),
                            detail: "\(store.recommendedItemCount) current items",
                            symbol: "checkmark.shield"
                        )
                        CleanerMetricTile(
                            title: "Auto Clean",
                            value: store.autoCleanEnabled ? "On" : "Off",
                            detail: store.nextAutoCleanText,
                            symbol: "timer"
                        )
                    }

                    AutoCleanPanel(store: store)

                    if !store.cleanupFailures.isEmpty {
                        CleanupNoticeBar(store: store)
                    }
                }
            }
            .padding(28)
        }
        .foregroundStyle(FocusedCleanerPalette.text)
    }

    private var lastCleanDetail: String {
        if store.lastCleanedItemCount > 0 {
            return "\(store.lastCleanedItemCount) items removed"
        }

        guard let lastCleanedDate = store.lastCleanedDate else {
            return "No cleanup yet"
        }

        return DateFormat.relative.localizedString(for: lastCleanedDate, relativeTo: Date())
    }
}
