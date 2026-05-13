import SwiftUI

struct DayEditorSheet: View {
    
    @EnvironmentObject var planManager: WorkoutPlanManager
    @Environment(\.dismiss) private var dismiss
    
    let dayId: UUID
    
    @State private var editedTitle: String = ""
    @State private var selectedType: DayType = .training
    @State private var showTemplates = false
    @State private var showSwapPicker = false
    
    private var day: WorkoutDay? {
        planManager.currentPlan?.weeklySchedule.first { $0.id == dayId }
    }
    
    private var otherDays: [WorkoutDay] {
        planManager.currentPlan?.weeklySchedule.filter { $0.id != dayId } ?? []
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        dayInfoHeader
                        titleSection
                        dayTypeSection
                        if selectedType == .training {
                            templateSection
                        }
                        swapSection
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Edit Day")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(ColorTheme.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { applyChanges() }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(ColorTheme.primary)
                }
            }
            .onAppear {
                editedTitle = day?.title ?? ""
                selectedType = day?.dayType ?? .training
            }
        }
    }
    
    // MARK: - Day Info Header
    
    private var dayInfoHeader: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(ColorTheme.primary.opacity(0.12))
                    .frame(width: 50, height: 50)
                Text(day?.dayOfWeek.letter ?? "")
                    .font(.system(size: 22, weight: .black))
                    .foregroundColor(ColorTheme.primary)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(day?.dayOfWeek.shortName ?? "")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Text(day?.title ?? "")
                    .font(.system(size: 13))
                    .foregroundColor(ColorTheme.textSecondary)
            }
            Spacer()
        }
        .padding(16)
        .background(ColorTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    
    // MARK: - Title Section
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("DAY TITLE")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.5)
                .foregroundColor(ColorTheme.textSecondary)
            
            TextField("e.g. Push Day, Upper Body", text: $editedTitle)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(14)
                .background(ColorTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
        }
    }
    
    // MARK: - Day Type Section
    
    private var dayTypeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("DAY TYPE")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.5)
                .foregroundColor(ColorTheme.textSecondary)
            
            HStack(spacing: 10) {
                typeButton(.training, icon: "dumbbell.fill", label: "Training")
                typeButton(.rest, icon: "bed.double.fill", label: "Rest")
                typeButton(.activeRecovery, icon: "figure.walk", label: "Recovery")
            }
        }
    }
    
    private func typeButton(_ type: DayType, icon: String, label: String) -> some View {
        let isSelected = selectedType == type
        return Button {
            withAnimation(.spring(response: 0.3)) { selectedType = type }
        } label: {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                Text(label)
                    .font(.system(size: 11, weight: .bold))
            }
            .foregroundColor(isSelected ? ColorTheme.background : ColorTheme.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isSelected ? ColorTheme.primary : ColorTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(
                isSelected ? Color.clear : Color.white.opacity(0.08), lineWidth: 1))
        }
    }
    
    // MARK: - Template Section
    
    private var templateSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("CHANGE FOCUS")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.5)
                .foregroundColor(ColorTheme.textSecondary)
            
            Text("Replace all exercises with a template")
                .font(.system(size: 12))
                .foregroundColor(ColorTheme.textSecondary.opacity(0.7))
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(DayTemplate.allCases) { template in
                    Button {
                        planManager.applyDayTemplate(dayId: dayId, template: template)
                        editedTitle = planManager.currentPlan?.weeklySchedule.first { $0.id == dayId }?.title ?? editedTitle
                        selectedType = .training
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: template.icon)
                                .font(.system(size: 14))
                                .foregroundColor(ColorTheme.primary)
                            Text(template.displayName)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            Spacer()
                        }
                        .padding(12)
                        .background(ColorTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.06), lineWidth: 1))
                    }
                }
            }
        }
    }
    
    // MARK: - Swap Section
    
    private var swapSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SWAP WITH ANOTHER DAY")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.5)
                .foregroundColor(ColorTheme.textSecondary)
            
            ForEach(otherDays) { otherDay in
                Button {
                    planManager.swapDays(dayId1: dayId, dayId2: otherDay.id)
                    dismiss()
                } label: {
                    HStack(spacing: 12) {
                        Text(otherDay.dayOfWeek.shortName)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(ColorTheme.secondary)
                            .frame(width: 36)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(otherDay.title)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            Text(otherDay.dayType.rawValue.capitalized)
                                .font(.system(size: 11))
                                .foregroundColor(ColorTheme.textSecondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.left.arrow.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(ColorTheme.textSecondary.opacity(0.5))
                    }
                    .padding(12)
                    .background(ColorTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }
    
    // MARK: - Apply
    
    private func applyChanges() {
        if selectedType != day?.dayType {
            planManager.changeDayType(dayId: dayId, to: selectedType)
        }
        if !editedTitle.isEmpty && editedTitle != day?.title {
            planManager.updateDayTitle(dayId: dayId, title: editedTitle)
        }
        dismiss()
    }
}
