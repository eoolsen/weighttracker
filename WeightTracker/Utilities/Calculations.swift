import Foundation

func bmi(weightKg: Double, heightMeters: Double) -> Double {
    guard heightMeters > 0 else { return 0 }
    return weightKg / (heightMeters * heightMeters)
}

func bmiCategory(_ bmi: Double) -> String {
    switch bmi {
    case ..<18.5: return "Underweight"
    case 18.5..<25: return "Normal"
    case 25..<30: return "Overweight"
    default: return "Obese"
    }
}

/// Returns how far (0–100+%) the current weight has moved from start toward goal.
/// Works for both cutting (goal < start) and bulking (goal > start).
func goalPercent(startKg: Double, currentKg: Double, goalKg: Double) -> Double {
    let totalDelta = goalKg - startKg
    guard abs(totalDelta) > 0.001 else { return 100 }
    let progressDelta = currentKg - startKg
    return (progressDelta / totalDelta) * 100
}
