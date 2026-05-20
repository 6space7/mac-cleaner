import AppKit
import SwiftUI

struct FocusedHeader: View {
    @ObservedObject var store: CleanerStore

    var body: some View {
        HStack {
            HStack(spacing: 10) {
                Image(nsImage: NSApplication.shared.applicationIconImage)
                    .resizable()
                    .interpolation(.high)
                    .frame(width: 22, height: 22)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .stroke(FocusedCleanerPalette.stroke, lineWidth: 1)
                    )

                Text("Mac Cleaner")
                    .font(.system(size: 14, weight: .semibold))
            }

            Spacer()

            HStack(spacing: 10) {
                StatusDot(isActive: store.isBusy)

                Text(store.isBusy ? "Cleaning" : "Ready")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(FocusedCleanerPalette.secondaryText)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(FocusedCleanerPalette.panelStrong, in: Capsule())
            .overlay(Capsule().stroke(FocusedCleanerPalette.stroke, lineWidth: 1))
        }
    }
}

private struct StatusDot: View {
    let isActive: Bool

    var body: some View {
        Circle()
            .fill(isActive ? FocusedCleanerPalette.amber : FocusedCleanerPalette.green)
            .frame(width: 8, height: 8)
            .shadow(color: (isActive ? FocusedCleanerPalette.amber : FocusedCleanerPalette.green).opacity(0.55), radius: 8)
    }
}
