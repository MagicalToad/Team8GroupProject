import Foundation
struct PlanUtilities {
    static func getReminderText(plans: [Plan], now: Date = Date()) -> String {
        let calendar = Calendar.current
        
        let upcomingPlans = plans.compactMap { plan -> (plan: Plan, scheduled: Date)? in
            if let scheduled = scheduledDate(for: plan, now: now), scheduled >= now {
                return (plan, scheduled)
            }
            return nil
        }
        
        // If no upcoming plans
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
            } else if plan.selectedPlan == "Eat" {
                return "You have a Meal Planned Today at \(formatter.string(from: scheduled))"
            } else {
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
            } else if plan.selectedPlan == "Eat" {
                return "You have a Meal Planned in \(daysAway) day\(daysAway == 1 ? "" : "s")"
            } else {
                return "You have a \(plan.selectedPlan) Session in \(daysAway) day\(daysAway == 1 ? "" : "s")"
            }
        }
    }
    
    private static func scheduledDate(for plan: Plan, now: Date) -> Date? {
        var calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month], from: now)
        components.day = plan.selectedDay
        
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: plan.planTime)
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute
        components.second = timeComponents.second
        
        return calendar.date(from: components)
    }
}
