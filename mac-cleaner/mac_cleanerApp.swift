//
//  mac_cleanerApp.swift
//  mac-cleaner
//
//  Created by 6space7 on 20/5/26.
//

import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
}

@main
struct mac_cleanerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var store = CleanerStore()

    var body: some Scene {
        WindowGroup("Mac Cleaner", id: "main") {
            ContentView(store: store)
                .frame(minWidth: 860, minHeight: 620)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandMenu("Cleaner") {
                Button("Start Cleanup") {
                    store.autoCleanRecommended()
                }
                .keyboardShortcut("r", modifiers: [.command])
                .disabled(store.isBusy)

                Toggle("Auto Clean", isOn: Binding(
                    get: { store.autoCleanEnabled },
                    set: { store.autoCleanEnabled = $0 }
                ))
            }
        }

        MenuBarExtra("Mac Cleaner", systemImage: "sparkles") {
            CleanerMenuBarView(store: store)
        }
    }
}
