import SwiftUI

struct CleanerMetricTile: View {
    let title: String
    let value: String
    let detail: String
    let symbol: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(FocusedCleanerPalette.green)
                .frame(width: 30, height: 30)
                .background(FocusedCleanerPalette.green.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(title.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(FocusedCleanerPalette.mutedText)

                Text(value)
                    .font(.system(size: 18, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Text(detail)
                    .font(.caption)
                    .foregroundStyle(FocusedCleanerPalette.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(minHeight: 86)
        .background(FocusedCleanerPalette.panel, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(FocusedCleanerPalette.stroke, lineWidth: 1))
    }
}
