import Foundation

private let mediumDateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateStyle = .medium
    f.timeStyle = .none
    return f
}()

extension Date {
    var formatted_medium: String {
        mediumDateFormatter.string(from: self)
    }
}
