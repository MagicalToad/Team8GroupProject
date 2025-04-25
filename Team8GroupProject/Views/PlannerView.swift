//
//  PlannerView.swift
//  Team8GroupProject
//
//  Created by Thoene, Zachary on 4/7/25.
//

import SwiftUI
import Foundation

struct PlannerView: View {
    let calendarDates = Array(1...31)
    
    @EnvironmentObject var planStore: PlanStore
    
    func scheduledDate(for plan: Plan) -> Date? {
        var calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents([.year, .month], from: now)
        components.day = plan.selectedDay
        
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: plan.planTime)
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute
        components.second = timeComponents.second
        
        return calendar.date(from: components)
    }
    
    var reminderText: String {
        let calendar = Calendar.current
        let now = Date()
        
        
        let upcomingPlans = planStore.plans.compactMap { plan -> (plan: Plan, scheduled: Date)? in
            if let scheduled = scheduledDate(for: plan), scheduled >= now {
                return (plan, scheduled)
            }
            return nil
        }
        
        guard let nextPlan = upcomingPlans.min(by: { $0.scheduled < $1.scheduled }) else {
            return "No upcoming plans"
        }
        
        let plan = nextPlan.plan
        let scheduled = nextPlan.scheduled
        
        if calendar.isDate(scheduled, inSameDayAs: now) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            if plan.selectedPlan == "Workout" {
                return "You have a \(plan.selectedPlan) Today at \(formatter.string(from: scheduled))"
            }
            else if plan.selectedPlan == "Eat" {
                return "You have a Meal Planned Today at \(formatter.string(from: scheduled))"
            }
            else {
                return "You have a \(plan.selectedPlan) Session Today at \(formatter.string(from: scheduled))"
            }
        } else {
            let diffComponents = calendar.dateComponents([.day], from: now, to: scheduled)
            
            var daysAway = diffComponents.day ?? 1
            if daysAway == 0 {
                daysAway = 1
            }
            else{
                daysAway = daysAway + 1
            }
            if plan.selectedPlan == "Workout" {
                return "You have a \(plan.selectedPlan) in \(daysAway) day\(daysAway == 1 ? "" : "s")"
            }
            else if plan.selectedPlan == "Eat"{
                return "You have a Meal Planned in \(daysAway) day\(daysAway == 1 ? "" : "s")"
            }
            else {
                return "You have a \(plan.selectedPlan) Session in \(daysAway + 1) day\(daysAway == 1 ? "" : "s")"
            }
        }
    }
    
    var currentWeek: [(abbreviation: String, day: Int)] {
        let calendar = Calendar.current
        guard let weekStart = Date().startOfWeek(using: calendar) else { return [] }
        let formatter = DateFormatter()
        formatter.dateFormat = "E" // E.g., "Mon", "Tue", etc.
        var weekDays: [(abbreviation: String, day: Int)] = []
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: weekStart) {
                let dayNum = calendar.component(.day, from: date)
                let abbr = formatter.string(from: date)
                weekDays.append((abbreviation: abbr, day: dayNum))
            }
        }
        return weekDays
    }
    
    func hasPlan(for day: Int) -> Bool {
        planStore.plans.contains { $0.selectedDay == day }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Today's Workout Section
                VStack(alignment: .leading) {
                    Text("Today")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    HStack {
                        Image(systemName: "bell.circle.fill")
                            .font(.title)
                        VStack(alignment: .leading) {
                            Text(reminderText)
                                .font(.subheadline)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Weekly Schedule
                VStack(alignment: .leading) {
                    Text("This Week")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(currentWeek, id: \.day) { dayInfo in
                                NavigationLink(destination: DayDetailsView(selectedDay: dayInfo.day)
                                                .environmentObject(planStore)) {
                                    Text(dayInfo.abbreviation)
                                        .font(.caption)
                                        .frame(width: 50, height: 50)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(10)
                                        .foregroundColor(.black)
                                        // Underline if there's a plan for that day.
                                        .underline(hasPlan(for: dayInfo.day), color: .black)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Monthly Calendar
                VStack(alignment: .leading) {
                    Text("This Month")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                        ForEach(calendarDates, id: \.self) { date in
                            NavigationLink(destination: DayDetailsView(selectedDay: date)
                                            .environmentObject(planStore)) {
                                Text("\(date)")
                                    .font(.system(size: 14))
                                    .frame(width: 40, height: 40)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                    .padding(2)
                                    .foregroundColor(.black)
                                    .underline(hasPlan(for: date), color: .black)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("My Planner")
        .navigationBarTitleDisplayMode(.inline)
    }
}


// This is Where the Plan information will be stored and how to add plans to the planner


struct Plan: Identifiable, Codable {
    let id: UUID
    let selectedDay: Int
    let selectedPlan: String
    let customDescription: String
    let repeatPlan: Bool
    let repeatOption: String?
    let planTime: Date
    let groupID: UUID?
}

class PlanStore: ObservableObject {
    @Published var plans: [Plan] = [] {
        didSet {
            savePlans()
        }
    }
    init() {
        loadPlans()
    }
    
    private let plansKey = "savedPlans"
    
    private func savePlans() {
        if let data = try? JSONEncoder().encode(plans) {
            UserDefaults.standard.set(data, forKey: plansKey)
        } else {
            print("Failed to encode plans")
        }
    }
    
    private func loadPlans() {
        if let data = UserDefaults.standard.data(forKey: plansKey),
           let savedPlans = try? JSONDecoder().decode([Plan].self, from: data) {
            self.plans = savedPlans
        }
    }
    
    func addPlan(_ plan: Plan) {
        plans.append(plan)
    }
    
    func removePlan(_ plan: Plan) {
        if let group = plan.groupID {
            plans.removeAll { $0.groupID == group }
        } else {
            plans.removeAll { $0.id == plan.id }
        }
    }
}

extension Date {
    func startOfWeek(using calendar: Calendar = Calendar.current) -> Date? {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components)
    }
}

struct DayDetailsView: View {
    var selectedDay: Int
    @EnvironmentObject var planStore: PlanStore
    @State private var showAddPlanSheet: Bool = false
    
    var body: some View {
        VStack {
            if filteredPlans.isEmpty {
                Text("No plans for day \(selectedDay)")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List {
                    ForEach(filteredPlans) { plan in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(plan.selectedPlan)
                                    .font(.headline)
                                if !plan.customDescription.isEmpty {
                                    Text(plan.customDescription)
                                        .font(.subheadline)
                                }
                            }
                            Spacer()
                            Text(timeFormatted(plan.planTime))
                                .font(.subheadline)
                        }
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    .onDelete(perform: deletePlan)
                }
                .listStyle(PlainListStyle())
            }
            
            Button(action: {
                showAddPlanSheet = true
            }) {
                Text("Add Plans")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .foregroundColor(.black)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
            .padding(.vertical)
            .sheet(isPresented: $showAddPlanSheet) {
                NavigationView {
                    AddPlansView(selectedDay: selectedDay)
                        .environmentObject(planStore)
                }
            }
            
            Spacer()
        }
        .navigationTitle("Plan for Day \(selectedDay)")
        
    }
    
    var filteredPlans: [Plan] {
        planStore.plans
            .filter { $0.selectedDay == selectedDay }
            .sorted { $0.planTime < $1.planTime }
    }
    
    func timeFormatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    func deletePlan(at offsets: IndexSet) {
        for index in offsets {
            let plan = filteredPlans[index]
            planStore.removePlan(plan)
        }
    }
}

struct DayDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DayDetailsView(selectedDay: 15)
                .environmentObject(PlanStore())
        }
    }
}


struct AddPlansView: View {
    var selectedDay: Int
    let defaultPlans = ["Workout", "Cardio", "Eat"]
    @State private var selectedPlan = "Workout"
    @State private var customDescription = ""
    
    @State private var repeatPlan = false
    let repeatOptions = ["Daily", "Weekly", "Monthly"]
    @State private var selectedRepeatOption = "Weekly"
    
    @State private var selectedTime: Date = Date()
    
    @State private var feedbackMessage = ""
    
    @EnvironmentObject var planStore: PlanStore
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Add Plans to Day \(selectedDay)")
                .font(.title)
                .bold()
            
            // Default plan selection
            Text("Select Plan")
                .font(.subheadline)
            Picker("Select Plan", selection: $selectedPlan) {
                ForEach(defaultPlans, id: \.self) { plan in
                    Text(plan)
                }
            }
            .frame(maxWidth: .infinity)
            .pickerStyle(MenuPickerStyle())
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            // Custom description field
            Text("Custom Description (Optional)")
                .font(.subheadline)
            TextField("Enter custom description", text: $customDescription)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
            
            // Time Picker
            Text("Select Time")
                .font(.subheadline)
            DatePicker("Select Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(CompactDatePickerStyle())
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            
            // Repeat options
            Toggle("Repeat Plan", isOn: $repeatPlan)
                .padding(.horizontal)
                .background(Color(.systemGray6))
                .foregroundColor(.black)
                .cornerRadius(10)
                .tint(.blue)
            if repeatPlan {
                Text("Repeat Frequency")
                    .font(.subheadline)
                Picker("Repeat Frequency", selection: $selectedRepeatOption) {
                    ForEach(repeatOptions, id: \.self) { option in
                        Text(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
            }
            
            // Save Button
            Button(action: {
                savePlan()
            }) {
                Text("Save Plan")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .foregroundColor(.black)
                    .cornerRadius(10)
            }
            .padding(.top)
            
            if !feedbackMessage.isEmpty {
                Text(feedbackMessage)
                    .foregroundColor(.gray)
                    .font(.subheadline)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Add Plans")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
    
    private func savePlan() {
        // Create a groupID if this is a recurring plan.
        let groupID: UUID? = repeatPlan ? UUID() : nil
        
        // Create an array to hold new plan entries.
        var newPlans: [Plan] = []
        
        // Create the base plan
        let basePlan = Plan(
            id: UUID(),
            selectedDay: selectedDay,
            selectedPlan: selectedPlan,
            customDescription: customDescription,
            repeatPlan: repeatPlan,
            repeatOption: repeatPlan ? selectedRepeatOption : nil,
            planTime: selectedTime,
            groupID: groupID
        )
        newPlans.append(basePlan)
        
        if repeatPlan {
            // Determine step: Daily = 1, Weekly = 7, Monthly = no additional copies.
            let calendar = Calendar.current
            let currentDate = Date()
            let numDays = calendar.range(of: .day, in: .month, for: currentDate)?.count ?? 31
            var step = 1
            if selectedRepeatOption == "Weekly" {
                step = 7
            } else if selectedRepeatOption == "Monthly" {
                step = numDays + 1
            }
            // Add additional recurring plans
            for day in stride(from: selectedDay + step, through: 31, by: step) {
                let recurringPlan = Plan(
                    id: UUID(),
                    selectedDay: day,
                    selectedPlan: selectedPlan,
                    customDescription: customDescription,
                    repeatPlan: repeatPlan,
                    repeatOption: selectedRepeatOption,
                    planTime: selectedTime,
                    groupID: groupID
                )
                newPlans.append(recurringPlan)
            }
        }
        
        // Add each new plan to the PlanStore. This will trigger the store's save logic.
        for plan in newPlans {
            planStore.addPlan(plan)
        }
        
        feedbackMessage = "Plan saved!"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dismiss()
        }
    }
}
