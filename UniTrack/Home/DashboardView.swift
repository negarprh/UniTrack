//
//  DashboardView.swift
//  UniTrack
//
//  Created by Negar Pirasteh on 2025-11-13.
//

import SwiftUI

struct DashboardView: View {
    @ObservedObject var vm: AuthViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text(vm.role == "teacher" ? "Teacher Dashboard" : "Student Dashboard")
                            .font(.largeTitle)
                            .bold()
                        Text("Quick access to your tools")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)

                    // Courses
                    NavigationLink {
                        CourseListView()
                    } label: {
                        DashboardButton(title: "Courses",
                                        subtitle: "View and manage your courses",
                                        systemImage: "book.closed")
                    }

                
                    // Tasks / Assignments
                    NavigationLink {
                        TaskDashboardView()
                    } label: {
                        DashboardButton(title: "Assignments",
                                        subtitle: "See upcoming tasks",
                                        systemImage: "checklist")
                    }


                    // Focus Timer
                    NavigationLink {
                        FocusTimerView()
                    } label: {
                        DashboardButton(title: "Focus Timer",
                                        subtitle: "Stay on track while studying",
                                        systemImage: "timer")
                    }

                    // Profile
                    NavigationLink {
                        ProfileView(vm: vm)
                    } label: {
                        DashboardButton(title: "Profile",
                                        subtitle: "View account and sign out",
                                        systemImage: "person.crop.circle")
                    }

                    Spacer()
                }
                .padding()
            }
        }
    }
}


struct DashboardButton: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.title2)
                .frame(width: 40, height: 40)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
}
