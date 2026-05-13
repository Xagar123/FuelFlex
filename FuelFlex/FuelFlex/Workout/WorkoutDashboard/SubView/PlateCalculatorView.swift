import SwiftUI

struct PlateCalculatorView: View {
    let targetWeight: Int
    let onDismiss: () -> Void

    private let barWeight = 45
    private let availablePlates: [Double] = [45, 35, 25, 10, 5, 2.5]

    private var perSide: Double {
        max(0, Double(targetWeight - barWeight) / 2.0)
    }

    private var plates: [Double] {
        var remaining = perSide
        var result: [Double] = []
        for plate in availablePlates {
            while remaining >= plate {
                result.append(plate)
                remaining -= plate
            }
        }
        return result
    }

    private func plateColor(_ plate: Double) -> Color {
        switch plate {
        case 45: return ColorTheme.primary
        case 35: return ColorTheme.secondary
        case 25: return ColorTheme.accent
        case 10: return ColorTheme.golden
        case 5: return ColorTheme.danger
        default: return ColorTheme.textSecondary
        }
    }

    private func plateHeight(_ plate: Double) -> CGFloat {
        switch plate {
        case 45: return 100
        case 35: return 88
        case 25: return 76
        case 10: return 60
        case 5: return 48
        default: return 36
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Plate Calculator")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(ColorTheme.textSecondary)
                        .font(.title3)
                }
            }

            Text("Target: \(targetWeight) lb")
                .font(.subheadline)
                .foregroundColor(ColorTheme.textSecondary)

            Text("Per Side: \(perSide, specifier: perSide.truncatingRemainder(dividingBy: 1) == 0 ? "%.0f" : "%.1f") lb")
                .font(.title3.bold())
                .foregroundColor(ColorTheme.primary)

            if plates.isEmpty {
                Text("Bar only")
                    .foregroundColor(ColorTheme.textSecondary)
            } else {
                HStack(alignment: .center, spacing: 3) {
                    // Bar end
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray)
                        .frame(width: 8, height: 20)

                    // Plates
                    ForEach(Array(plates.enumerated()), id: \.offset) { _, plate in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(plateColor(plate))
                            .frame(width: 22, height: plateHeight(plate))
                            .overlay(
                                Text(plate.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(plate))" : "2.5")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(.black)
                                    .rotationEffect(.degrees(-90))
                            )
                    }

                    // Bar
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray)
                        .frame(height: 10)
                }
                .padding(.vertical, 8)
            }
        }
        .padding(20)
        .background(ColorTheme.surface)
        .cornerRadius(16)
        .padding(24)
    }
}
