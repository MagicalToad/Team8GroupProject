//
//  PlannerView.swift
//  Team8GroupProject
//
//  Created by Thoene, Zachary on 4/7/25.
//

import SwiftUI

struct PlannerView: View {
    let daysOfWeek = ["M", "T", "W", "TH", "F", "S", "SU"]
    let calendarDates = Array(1...31)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Today's Workout Section
                VStack(alignment: .leading) {
                    Text("Today")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    HStack {
                        Image(systemName: "figure.run")
                            .font(.title)
                        VStack(alignment: .leading) {
                            Text("You have a workout today!")
                                .font(.subheadline)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
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
                            ForEach(daysOfWeek, id: \.self) { day in
                                VStack {
                                    Text(day)
                                        .font(.caption)
                                        .padding(8)
                                }
                                .frame(width: 50)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
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
                            Text("\(date)")
                                .font(.system(size: 14))
                                .frame(width: 40, height: 40)
                                .cornerRadius(8)
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
    }
}

#Preview {
    PlannerView()
}
