//
//  TaskDashboardView.swift
//  UniTrack
//
//  Created by Negar Pirasteh on 2025-11-13.
//

import SwiftUI

struct TaskDashboardView: View {
    @StateObject private var taskVM = TaskViewModel()
    @State private var showNewTask = false

    // pseudo course id used only from the dashboard
    private let dashboardCourseId = "dashboard"

    var body: some View {
        NavigationStack {
            List {
                TaskListSection(
                    viewModel: taskVM,
                    courseId: dashboardCourseId,
                    onEdit: { task in
                        // TODO: if you want an edit flow later, open TaskFormView pre-filled
                        print("Edit tapped for \(task.title)")
                    },
                    onAdd: {
                        showNewTask = true
                    }
                )
            }
            .navigationTitle("Assignments")
            .sheet(isPresented: $showNewTask) {
                TaskFormView(courseId: dashboardCourseId) { newTask in
     
                    taskVM.tasks.append(newTask)

                }
            }
        }
    }
}
