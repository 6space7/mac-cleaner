import SwiftUI

struct CleanupCoreButton: View {
    @ObservedObject var store: CleanerStore
    @State private var isHovering = false

    var body: some View {
        Button {
            store.autoCleanRecommended()
        } label: {
            CleanupCoreVisual(isBusy: store.isBusy, isHovering: isHovering)
        }
        .buttonStyle(.plain)
        .disabled(store.isBusy)
        .accessibilityLabel(store.isBusy ? "Cleaning cache" : "Start cache cleanup")
        .help(store.isBusy ? "Cleaning" : "Start cleanup")
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.18)) {
                isHovering = hovering
            }
        }
    }
}

private struct CleanupCoreVisual: View {
    let isBusy: Bool
    let isHovering: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            FocusedCleanerPalette.green.opacity(0.32),
                            FocusedCleanerPalette.cyan.opacity(0.18),
                            FocusedCleanerPalette.panel.opacity(0.72)
                        ],
                        center: .center,
                        startRadius: 18,
                        endRadius: 96
                    )
                )

            Circle()
                .stroke(FocusedCleanerPalette.stroke, lineWidth: 1)

            Circle()
                .trim(from: 0.08, to: isBusy ? 0.88 : 0.64)
                .stroke(
                    AngularGradient(
                        colors: [
                            FocusedCleanerPalette.green,
                            FocusedCleanerPalette.cyan,
                            FocusedCleanerPalette.amber,
                            FocusedCleanerPalette.green
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 7, lineCap: .round)
                )
                .rotationEffect(.degrees(isBusy ? 360 : 24))
                .animation(isBusy ? .linear(duration: 1.4).repeatForever(autoreverses: false) : .easeOut(duration: 0.3), value: isBusy)

            Image(systemName: isBusy ? "arrow.triangle.2.circlepath" : "sparkles")
                .font(.system(size: 40, weight: .semibold))
                .foregroundStyle(.white)
                .symbolEffect(.pulse, options: .repeating, value: isBusy)

            VStack(spacing: 2) {
                Spacer()

                Text(isBusy ? "Cleaning" : "Start")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white.opacity(0.94))
                    .padding(.bottom, 34)
            }
        }
        .frame(width: 170, height: 170)
        .scaleEffect(isHovering && !isBusy ? 1.035 : 1)
        .shadow(color: FocusedCleanerPalette.green.opacity(isHovering ? 0.28 : 0.18), radius: isHovering ? 34 : 28, x: 0, y: 14)
    }
}
