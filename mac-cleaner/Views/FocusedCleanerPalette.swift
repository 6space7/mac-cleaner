import SwiftUI

enum FocusedCleanerPalette {
    static let background = LinearGradient(
        colors: [
            Color(red: 0.025, green: 0.045, blue: 0.075),
            Color(red: 0.050, green: 0.075, blue: 0.110),
            Color(red: 0.035, green: 0.050, blue: 0.065)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let text = Color(red: 0.95, green: 0.97, blue: 0.96)
    static let secondaryText = Color(red: 0.68, green: 0.72, blue: 0.72)
    static let mutedText = Color(red: 0.44, green: 0.49, blue: 0.50)
    static let panel = Color.white.opacity(0.055)
    static let panelStrong = Color.white.opacity(0.085)
    static let stroke = Color.white.opacity(0.105)
    static let green = Color(red: 0.45, green: 0.88, blue: 0.62)
    static let cyan = Color(red: 0.38, green: 0.76, blue: 0.90)
    static let amber = Color(red: 0.95, green: 0.70, blue: 0.32)
    static let rose = Color(red: 0.96, green: 0.40, blue: 0.48)
}
