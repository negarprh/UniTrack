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

    private let dashboardCourseId = "dashboard"

    var body: some View {
        NavigationStack {
            List {
                TaskListSection(
                    viewModel: taskVM,
                    courseId: dashboardCourseId,
                    onEdit: { task in
                  
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
