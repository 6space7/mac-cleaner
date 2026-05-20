import AppKit
import SwiftUI

struct CleanerMenuBarView: View {
    @ObservedObject var store: CleanerStore
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading) {
            Text("Mac Cleaner")

            Text("Total: \(ByteCountFormat.compact(store.totalCleanedBytes))")
                .foregroundStyle(.secondary)

            Text("Items: \(store.totalCleanedItemCount)")
                .foregroundStyle(.secondary)

            Text("Last: \(lastCleanText)")
                .foregroundStyle(.secondary)

            if store.autoCleanEnabled {
                Text("Next: \(store.nextAutoCleanText)")
                    .foregroundStyle(.secondary)
            }

            Divider()

            Button(store.isBusy ? "Working..." : "Start Cleanup") {
                store.autoCleanRecommended()
            }
            .disabled(store.isBusy)

            Toggle("Auto Clean", isOn: $store.autoCleanEnabled)

            Menu("Interval") {
                Picker("Interval", selection: $store.autoCleanInterval) {
                    ForEach(AutoCleanInterval.allCases) { interval in
                        Text(interval.title).tag(interval)
                    }
                }
            }
            .disabled(!store.autoCleanEnabled)

            Divider()

            Button("Open Window") {
                openWindow(id: "main")
                NSApp.activate(ignoringOtherApps: true)
            }

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
    }

    private var lastCleanText: String {
        guard let lastCleanedDate = store.lastCleanedDate else {
            return "Never"
        }

        return DateFormat.relative.localizedString(for: lastCleanedDate, relativeTo: Date())
    }
}
