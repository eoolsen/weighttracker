import Foundation

enum BMI {
    static func value(weightKg: Double, heightMeters: Double) -> Double {
        precondition(heightMeters > 0, "BMI requires positive height")
        return weightKg / (heightMeters * heightMeters)
    }

    static func category(_ bmi: Double) -> String {
        switch bmi {
        case ..<18.5: return "Underweight"
        case 18.5..<25: return "Normal"
        case 25..<30: return "Overweight"
        default: return "Obese"
        }
    }
}

enum Goal {
    /// Returns how far (0–100+%) `current` has moved from `start` toward `goal`.
    /// Works for both cuts (goal < start) and bulks (goal > start).
    static func percent(start: Double, current: Double, goal: Double) -> Double {
        let totalDelta = goal - start
        guard abs(totalDelta) > 0.001 else { return 100 }
        let progressDelta = current - start
        return (progressDelta / totalDelta) * 100
    }
}
