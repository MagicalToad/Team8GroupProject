//
//  ActivityRowView.swift
//  Team8GroupProject
//
//  Created by Chris Xiong on 4/16/25.
//

// Created ActivityRow as its own component to reuse on homepage and activity page

import SwiftUI

struct ActivityRow: View {
    let workout: WorkoutLog
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: workout.iconName)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 35, alignment: .leading)
            VStack(alignment: .leading) {
                Text(workout.type).font(.headline)
                Text(workout.displaySummary).font(.subheadline).foregroundColor(.secondary).lineLimit(3)
            }
            Spacer()
            Text(workout.formattedDuration).font(.subheadline).foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
}

#Preview {
    NavigationStack {
        ActivityView()
            .environmentObject(ActivityViewModel())
    }
}
