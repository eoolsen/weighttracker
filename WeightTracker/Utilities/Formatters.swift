import Foundation

extension Double {
    /// Standard one-decimal kg display, e.g. `82.5 kg`.
    var kgString: String { String(format: "%.1f kg", self) }
}

extension Date {
    /// Abbreviated date in the user's locale, e.g. `Jun 18, 2026`.
    var mediumDate: String { formatted(date: .abbreviated, time: .omitted) }
}
