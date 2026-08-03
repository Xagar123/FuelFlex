import SwiftUI

struct GoalCreationSheet: View {
    
    @EnvironmentObject var goalManager: GoalManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var category: GoalCategory = .workout
    @State private var frequency: GoalFrequency = .daily
    @State private var targetValue = ""
    @State private var unit = ""
    
    // Preset suggestions
    private let presets: [(String, GoalCategory, Double, String)] = [
        ("Complete a workout", .workout, 1, "workout"),
        ("Drink water", .hydration, 3, "liters"),
        ("Hit step goal", .steps, 10000, "steps"),
        ("Get enough sleep", .sleep, 7, "hours"),
        ("Eat protein target", .nutrition, 150, "grams"),
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // Quick presets
                        VStack(alignment: .leading, spacing: 12) {
                            Text("QUICK ADD")
                                .font(.system(size: 11, weight: .black))
                                .tracking(2)
                                .foregroundColor(ColorTheme.textSecondary)
                            
                            FlowLayout(spacing: 8) {
                                ForEach(presets, id: \.0) { preset in
                                    Button(action: { applyPreset(preset) }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: preset.1.icon)
                                                .font(.system(size: 11))
                                            Text(preset.0)
                                                .font(.system(size: 12, weight: .semibold))
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(ColorTheme.surface)
                                        .clipShape(Capsule())
                                        .overlay(Capsule().stroke(Color.white.opacity(0.1), lineWidth: 1))
                                    }
                                }
                            }
                        }
                        
                        Divider().overlay(Color.white.opacity(0.1))
                        
                        // Custom goal form
                        VStack(alignment: .leading, spacing: 16) {
                            Text("CUSTOM GOAL")
                                .font(.system(size: 11, weight: .black))
                                .tracking(2)
                                .foregroundColor(ColorTheme.textSecondary)
                            
                            // Title
                            TextField("Goal name", text: $title)
                                .font(.system(size: 15, weight: .semibold))
                                .padding()
                                .background(ColorTheme.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .foregroundColor(.white)
                            
                            // Category picker
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Category")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(ColorTheme.textSecondary)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(GoalCategory.allCases, id: \.self) { cat in
                                            Button(action: { category = cat }) {
                                                HStack(spacing: 5) {
                                                    Image(systemName: cat.icon)
                                                        .font(.system(size: 12))
                                                    Text(cat.rawValue.capitalized)
                                                        .font(.system(size: 11, weight: .bold))
                                                }
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .background(category == cat ? Color(hex: cat.color).opacity(0.2) : ColorTheme.surface)
                                                .foregroundColor(category == cat ? Color(hex: cat.color) : ColorTheme.textSecondary)
                                                .clipShape(Capsule())
                                                .overlay(
                                                    Capsule().stroke(
                                                        category == cat ? Color(hex: cat.color).opacity(0.5) : Color.white.opacity(0.08),
                                                        lineWidth: 1
                                                    )
                                                )
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // Frequency
                            HStack(spacing: 12) {
                                ForEach(GoalFrequency.allCases, id: \.self) { freq in
                                    Button(action: { frequency = freq }) {
                                        Text(freq.label)
                                            .font(.system(size: 13, weight: .bold))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(frequency == freq ? ColorTheme.primary.opacity(0.15) : ColorTheme.surface)
                                            .foregroundColor(frequency == freq ? ColorTheme.primary : ColorTheme.textSecondary)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(frequency == freq ? ColorTheme.primary.opacity(0.4) : Color.white.opacity(0.08), lineWidth: 1)
                                            )
                                    }
                                }
                            }
                            
                            // Target + Unit
                            HStack(spacing: 12) {
                                TextField("Target", text: $targetValue)
                                    .keyboardType(.decimalPad)
                                    .font(.system(size: 15, weight: .semibold))
                                    .padding()
                                    .background(ColorTheme.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .foregroundColor(.white)
                                
                                TextField("Unit", text: $unit)
                                    .font(.system(size: 15, weight: .semibold))
                                    .padding()
                                    .background(ColorTheme.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .foregroundColor(.white)
                                    .frame(width: 100)
                            }
                        }
                        
                        // Create button
                        Button(action: createGoal) {
                            Text("CREATE GOAL")
                                .font(.system(size: 14, weight: .black))
                                .tracking(1.5)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(canCreate ? ColorTheme.buttonGradient : LinearGradient(colors: [.gray.opacity(0.3), .gray.opacity(0.3)], startPoint: .leading, endPoint: .trailing))
                                .foregroundColor(canCreate ? .black : .gray)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(!canCreate)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(ColorTheme.textSecondary)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    private var canCreate: Bool {
        !title.isEmpty && (Double(targetValue) ?? 0) > 0 && !unit.isEmpty
    }
    
    private func applyPreset(_ preset: (String, GoalCategory, Double, String)) {
        title = preset.0
        category = preset.1
        targetValue = "\(Int(preset.2))"
        unit = preset.3
    }
    
    private func createGoal() {
        guard let target = Double(targetValue) else { return }
        let xp = frequency == .daily ? 10 : 50
        let goal = Goal(title: title, category: category, frequency: frequency,
                        targetValue: target, unit: unit, xpReward: xp)
        goalManager.addGoal(goal)
        dismiss()
    }
}

// MARK: - Flow Layout (for preset chips)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            let point = CGPoint(x: bounds.minX + result.positions[index].x,
                                y: bounds.minY + result.positions[index].y)
            subview.place(at: point, anchor: .topLeading, proposal: .unspecified)
        }
    }
    
    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
        
        return (positions, CGSize(width: maxWidth, height: y + rowHeight))
    }
}
