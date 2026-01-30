//
//  DailyLogView.swift
//  FuelFlex
//
//  Created by DAS Sagar on 20/01/26.
//

import SwiftUI

struct DailyLogView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State var showCalendar = false
    @State private var selectedDate = Date()
    @State private var calendarMode: CalendarMode = .week
    
    enum CalendarMode: String, CaseIterable {
        case week = "WEEK"
        case month = "MONTH"
    }
    
    let meals = [
        MealRecord(name: "Morning Smoothie", time: "08:00 AM", kcal: 320, protein: 15, carbs: 45, fats: 8, imageUrl: "https://images.unsplash.com/photo-1553531384-cc64ac80f931?w=400&q=80"),
        MealRecord(name: "Grilled Salmon Bowl", time: "12:30 PM", kcal: 650, protein: 42, carbs: 35, fats: 22, imageUrl: "https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=400&q=80"),
        MealRecord(name: "Almond Protein Shake", time: "04:00 PM", kcal: 210, protein: 25, carbs: 12, fats: 6, imageUrl: "https://images.unsplash.com/photo-1593085512500-5d55148d6f0d?w=400&q=80"),
        MealRecord(name: "Quinoa Chicken Salad", time: "07:45 PM", kcal: 480, protein: 35, carbs: 40, fats: 12, imageUrl: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&q=80")
    ]
    
    
    var body: some View {
        ZStack {
            ColorTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerArea
                
//                if showCalendar {
//                    HorizontalCalendarView(selectedDate: $selectedDate, showCalendar: $showCalendar)
//                        .transition(.move(edge: .top).combined(with: .opacity))
//                }
                // --- Animated Calendar Section ---
                if showCalendar {
                    VStack(spacing: 0) {
                        // Mode Switcher (Week / Month)
                        HStack(spacing: 0) {
                            ForEach(CalendarMode.allCases, id: \.self) { mode in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        calendarMode = mode
                                    }
                                }) {
                                    Text(mode.rawValue)
                                        .font(.system(size: 10, weight: .black))
                                        .foregroundColor(calendarMode == mode ? ColorTheme.background : ColorTheme.textSecondary.opacity(0.4))
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 30)
                                        .background(calendarMode == mode ? ColorTheme.primary : Color.clear)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(4)
                        .background(ColorTheme.surface)
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        HorizontalCalendarView(
                            selectedDate: $selectedDate,
                            showCalendar: $showCalendar,
                            mode: calendarMode
                        )
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .background(ColorTheme.background)
                    .zIndex(1) // Ensure it slides over content if needed
                }
                
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Date and Counter
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("January 18, 2026")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(ColorTheme.textSecondary.opacity(0.6))
                                Text("4 MEALS LOGGED")
                                    .font(.system(size: 11, weight: .black))
                                    .foregroundColor(ColorTheme.primary)
                            }
                            Spacer()
                            
                            Button(action: {}) {
                                HStack(spacing: 6) {
                                    Image(systemName: "plus")
                                    Text("ADD MEAL")
                                }
                                .font(.system(size: 11, weight: .black))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(ColorTheme.buttonGradient)
                                .foregroundColor(ColorTheme.background)
                                .clipShape(Capsule())
                                .shadow(color: ColorTheme.primary.opacity(0.3), radius: 10, y: 5)
                            }
                        }
                        
                        // Meals List
                        VStack(spacing: 16) {
                            ForEach(meals) { meal in
                                MealCell(meal: meal)
                            }
                        }
                        
                        // Summary Card
                        summaryCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private var headerArea: some View {
        HStack {
            Button(action: {
                // Action for back button
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(ColorTheme.primary)
                    .frame(width: 44, height: 44)
                    .background(ColorTheme.surface)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 1))
            }
            
            Spacer()
            
            Text("DAILY LOG")
                .font(.system(size: 20, weight: .black, design: .rounded))
                .italic()
                .foregroundColor(ColorTheme.textPrimary)
            
            Spacer()
            
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    showCalendar.toggle()
                }
            }) {
                Image(systemName: "calendar")
                    .font(.system(size: 20))
                    .foregroundColor(showCalendar ? ColorTheme.primary : ColorTheme.textSecondary.opacity(0.4))
                    .frame(width: 44, height: 44)
                    .background(showCalendar ? ColorTheme.primary.opacity(0.1) : Color.clear)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    // MARK: - New Horizontal Calendar Component
//    struct HorizontalCalendarView: View {
//        @Binding var selectedDate: Date
//        @Binding var showCalendar: Bool
//        let calendar = Calendar.current
//        
//        // Generate all dates for the current month
//        var monthDates: [Date] {
//            guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate),
//                  let monthRange = calendar.range(of: .day, in: .month, for: selectedDate) else {
//                return []
//            }
//            
//            let firstDayOfMonth = monthInterval.start
//            
//            return monthRange.compactMap { day -> Date? in
//                calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth)
//            }
//        }
//        
//        var body: some View {
//            ScrollViewReader { proxy in
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 12) {
//                        ForEach(monthDates, id: \.self) { date in
//                            let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
//                            let isToday = calendar.isDateInToday(date)
//                            
//                            Button(action: {
//                                withAnimation(.snappy) {
//                                    selectedDate = date
//                                }
//                            }) {
//                                VStack(spacing: 6) {
//                                    Text(dayAbbreviation(for: date))
//                                        .font(.system(size: 10, weight: .black))
//                                        .foregroundColor(isSelected ? ColorTheme.background : .white.opacity(0.4))
//                                    
//                                    Text(dayNumber(for: date))
//                                        .font(.system(size: 18, weight: .black, design: .rounded))
//                                        .foregroundColor(isSelected ? ColorTheme.background : .white)
//                                }
//                                .frame(width: 60, height: 70)
//                                .background(isSelected ? ColorTheme.primary : ColorTheme.surface)
//                                .cornerRadius(16)
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 16)
//                                        .stroke(isToday && !isSelected ? ColorTheme.primary.opacity(0.5) : Color.clear, lineWidth: 1)
//                                )
//                                .shadow(color: isSelected ? ColorTheme.primary.opacity(0.3) : Color.clear, radius: 8, y: 4)
//                            }
//                            .id(date)
//                        }
//                    }
//                    .padding(.horizontal, 20)
//                    .padding(.vertical, 16)
//                }
//                .onAppear {
//                    // Center the selected date on appear
////                    proxy.scrollTo(selectedDate, anchor: .center)
//                    // Ensure the view scrolls to center the selected/current date immediately when appearing
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                        withAnimation(.easeOut) {
//                            proxy.scrollTo(selectedDate, anchor: .center)
//                        }
//                    }
//                }
//                .onChange(of: showCalendar) { newValue in
//                    if newValue {
//                        // Re-center when toggled on
//                        proxy.scrollTo(selectedDate, anchor: .center)
//                    }
//                }
//            }
//            .background(ColorTheme.background)
//        }
//        
//        func dayAbbreviation(for date: Date) -> String {
//            let formatter = DateFormatter()
//            formatter.dateFormat = "EEE"
//            return formatter.string(from: date).uppercased()
//        }
//        
//        func dayNumber(for date: Date) -> String {
//            let formatter = DateFormatter()
//            formatter.dateFormat = "d"
//            return formatter.string(from: date)
//        }
//    }
    
    // MARK: - Horizontal Calendar View
    struct HorizontalCalendarView: View {
        @Binding var selectedDate: Date
        @Binding var showCalendar: Bool
        var mode: DailyLogView.CalendarMode
        let calendar = Calendar.current
        
        // Calculates dates based on Week or Month
        var visibleDates: [Date] {
            if mode == .week {
                // Get the week containing the selected date
                guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) else { return [] }
                return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekInterval.start) }
            } else {
                // Get all days for the current month of selected date
                guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate),
                      let monthRange = calendar.range(of: .day, in: .month, for: selectedDate) else { return [] }
                return monthRange.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: monthInterval.start) }
            }
        }
        
        var body: some View {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(visibleDates, id: \.self) { date in
                            let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                            let isToday = calendar.isDateInToday(date)
                            
                            Button(action: {
                                withAnimation(.snappy) { selectedDate = date }
                            }) {
                                VStack(spacing: 6) {
                                    Text(dayAbbreviation(for: date))
                                        .font(.system(size: 10, weight: .black))
                                        .foregroundColor(isSelected ? ColorTheme.background : .white.opacity(0.4))
                                    
                                    Text(dayNumber(for: date))
                                        .font(.system(size: 18, weight: .black, design: .rounded))
                                        .foregroundColor(isSelected ? ColorTheme.background : .white)
                                }
                                .frame(width: 60, height: 75)
                                .background(isSelected ? ColorTheme.primary : ColorTheme.surface)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(isToday && !isSelected ? ColorTheme.primary.opacity(0.5) : Color.clear, lineWidth: 1)
                                )
                                .shadow(color: isSelected ? ColorTheme.primary.opacity(0.3) : Color.clear, radius: 8, y: 4)
                            }
                            .id(date)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .onAppear { centerDate(proxy: proxy, animated: false) }
                .onChange(of: showCalendar) { if $0 { centerDate(proxy: proxy) } }
                .onChange(of: mode) { _ in centerDate(proxy: proxy) }
            }
        }
        
        private func centerDate(proxy: ScrollViewProxy, animated: Bool = true) {
            // Delay slightly to allow layout to settle
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                if animated {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        proxy.scrollTo(selectedDate, anchor: .center)
                    }
                } else {
                    proxy.scrollTo(selectedDate, anchor: .center)
                }
            }
        }
        
        private func dayAbbreviation(for date: Date) -> String {
            let f = DateFormatter(); f.dateFormat = "EEE"; return f.string(from: date).uppercased()
        }
        
        private func dayNumber(for date: Date) -> String {
            let f = DateFormatter(); f.dateFormat = "d"; return f.string(from: date)
        }
    }
    
    
    
    private var summaryCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(ColorTheme.primary.opacity(0.1))
                        .frame(width: 36, height: 36)
                    Image(systemName: "chart.pie.fill")
                        .foregroundColor(ColorTheme.primary)
                        .font(.system(size: 14))
                }
                Text("DAILY SUMMARY")
                    .font(.system(size: 12, weight: .black))
                    .tracking(2)
                    .foregroundColor(ColorTheme.textPrimary)
                Spacer()
            }
            
            HStack(spacing: 12) {
                SummaryMetric(label: "REMAINING", value: "460", unit: "kcal", color: ColorTheme.textPrimary)
                SummaryMetric(label: "GOAL STATUS", value: "74%", unit: "", color: ColorTheme.primary)
            }
        }
        .padding(24)
        .background(
            LinearGradient(colors: [ColorTheme.surface, ColorTheme.background], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(24)
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.1), lineWidth: 1))
    }
}

// MARK: - Components

struct MealCell: View {
    let meal: MealRecord
    
    var body: some View {
        HStack(spacing: 0) {
            // Left Side: Image with Gradient Fade
            ZStack(alignment: .trailing) {
                AsyncImage(url: URL(string: meal.imageUrl)) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    ColorTheme.surface
                }
                .frame(width: 120, height: 120)
                
                // Masking Gradient
                LinearGradient(
                    colors: [Color.clear, ColorTheme.surface],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 60)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            // Right Side: Content
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(meal.name)
                            .font(.system(size: 16, weight: .bold))
                            .lineLimit(1)
                            .foregroundColor(ColorTheme.textPrimary)
                        Text(meal.time)
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(ColorTheme.textSecondary.opacity(0.4))
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: -4) {
                        Text("\(meal.kcal)")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .italic()
                            .foregroundColor(ColorTheme.primary)
                            .shadow(color: ColorTheme.primary.opacity(0.4), radius: 6)
                        Text("kcal")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(ColorTheme.textSecondary.opacity(0.4))
                    }
                }
                
                Spacer(minLength: 0)
                
                HStack(spacing: 8) {
                    MacroPill(label: "P", value: "\(meal.protein)g", color: ColorTheme.primary)
                    MacroPill(label: "C", value: "\(meal.carbs)g", color: ColorTheme.secondary)
                    MacroPill(label: "F", value: "\(meal.fats)g", color: ColorTheme.accent)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
        }
        .frame(height: 120)
        .background(ColorTheme.surface)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.05), lineWidth: 1))
    }
}

struct MacroPill: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 9, weight: .black))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(ColorTheme.textPrimary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.15))
        .cornerRadius(8)
    }
}

struct SummaryMetric: View {
    let label: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(ColorTheme.textSecondary.opacity(0.4))
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(color)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(ColorTheme.textSecondary.opacity(0.4))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

#Preview {
    DailyLogView()
}
