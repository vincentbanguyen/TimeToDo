import SwiftUI
import Foundation

// MARK: - Color Tokens
extension Color {
    static let colorBackground = Color(.systemGroupedBackground)
    static let colorSurface = Color(.secondarySystemGroupedBackground)

    static let colorPrimary = Color.accentColor
    static let colorPrimaryLight = Color(hex: "5AC8FA")
    static let colorSecondary = Color(.secondaryLabel)

    static let colorSuccess = Color.green
    static let colorWarning = Color.orange
    static let colorError = Color.red

    static let colorTextPrimary = Color(.label)
    static let colorTextSecondary = Color(.secondaryLabel)
    static let colorTextTertiary = Color(.tertiaryLabel)

    static let colorBorder = Color(.separator)
    static let colorOverlay = Color.black.opacity(0.4)
}

// MARK: - Typography Tokens
extension Font {
    static let fontBody = Font.system(size: 17, weight: .regular)
    static let fontBodyBold = Font.system(size: 17, weight: .semibold)
    static let fontHeading = Font.system(size: 24, weight: .bold)
    static let fontHeadingLarge = Font.system(size: 32, weight: .bold)
    static let fontCaption = Font.system(size: 13, weight: .regular)
    static let fontButton = Font.system(size: 16, weight: .semibold)
}

// MARK: - Spacing Tokens
extension CGFloat {
    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 16
    static let spacingL: CGFloat = 24
    static let spacingXL: CGFloat = 32
    static let spacingXXL: CGFloat = 48
}

// MARK: - Elevation Tokens
extension View {
    func elevationLow() -> some View {
        self.shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }

    func elevationMedium() -> some View {
        self.shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
    }

    func elevationHigh() -> some View {
        self.shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Color Extension for Hex Support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
