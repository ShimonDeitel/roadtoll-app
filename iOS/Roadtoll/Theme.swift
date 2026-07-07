import SwiftUI

enum Theme {
    static let accent = Color(red: 0.180, green: 0.525, blue: 0.671)
    static let background = Color(red: 0.055, green: 0.086, blue: 0.125)
    static let card = background.opacity(0.6)
    static let titleFont = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let headlineFont = Font.system(.headline, design: .rounded)
    static let bodyFont = Font.system(.body, design: .rounded)
}
