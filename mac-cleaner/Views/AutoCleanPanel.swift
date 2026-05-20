import SwiftUI

struct AutoCleanPanel: View {
    @ObservedObject var store: CleanerStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                Label("Auto clean", systemImage: "timer")
                    .font(.system(size: 13, weight: .semibold))

                Spacer()

                Text(store.autoCleanEnabled ? store.autoCleanInterval.title : "Off")
                    .font(.caption)
                    .foregroundStyle(FocusedCleanerPalette.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)

                Toggle("", isOn: $store.autoCleanEnabled)
                    .toggleStyle(.switch)
                    .labelsHidden()
            }

            if store.autoCleanEnabled {
                VStack(alignment: .leading, spacing: 10) {
                    Divider()
                        .overlay(FocusedCleanerPalette.stroke)

                    HStack(spacing: 10) {
                        Text("Run every")
                            .font(.caption)
                            .foregroundStyle(FocusedCleanerPalette.secondaryText)

                        ForEach(AutoCleanInterval.allCases) { interval in
                            TimeOptionButton(
                                title: shortTitle(for: interval),
                                isSelected: store.autoCleanInterval == interval
                            ) {
                                store.autoCleanInterval = interval
                            }
                        }

                        Spacer()

                        Text("Next: \(store.nextAutoCleanText)")
                            .font(.caption)
                            .foregroundStyle(FocusedCleanerPalette.secondaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(14)
        .background(FocusedCleanerPalette.panelStrong, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(FocusedCleanerPalette.stroke, lineWidth: 1))
        .animation(.easeInOut(duration: 0.2), value: store.autoCleanEnabled)
    }

    private func shortTitle(for interval: AutoCleanInterval) -> String {
        switch interval {
        case .oneHour:
            return "1h"
        case .twoHours:
            return "2h"
        case .fourHours:
            return "4h"
        case .eightHours:
            return "8h"
        case .twelveHours:
            return "12h"
        }
    }
}

private struct TimeOptionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .frame(width: 42, height: 28)
                .foregroundStyle(isSelected ? Color.black.opacity(0.86) : FocusedCleanerPalette.secondaryText)
                .background(
                    isSelected ? Color.white.opacity(0.92) : FocusedCleanerPalette.panel,
                    in: RoundedRectangle(cornerRadius: 8, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(isSelected ? Color.white.opacity(0.62) : FocusedCleanerPalette.stroke, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
