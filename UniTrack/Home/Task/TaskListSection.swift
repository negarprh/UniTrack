//
//  TaskListSection.swift
//  UniTrack
//
//  Created by Naomi on 2025-11-12.
//

import SwiftUI

struct TaskListSection: View {
    @ObservedObject var viewModel: TaskViewModel
    let courseId: String
    let onEdit: (Task) -> Void
    let onAdd: () -> Void
    var body: some View {
        Section("Tasks") {
            if viewModel.tasks.isEmpty {
                Text("No tasks yet")
                    .foregroundColor(.secondary)
            } else {
                ForEach(viewModel.tasks) { task in
                    HStack {
                        
                        Button {
                            let updated = task
                            viewModel.toggleDone(updated) 
                        } label: {
                            Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(task.isDone ? .green : .gray)
                        }
                        .buttonStyle(.plain)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(task.title)
                                .font(.headline)

                            Text("\(task.type.capitalized) • due \(task.dueDate.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                       
                        Button {
                            onEdit(task)
                        } label: {
                            Image(systemName: "pencil")
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .onDelete { indexSet in
                    let toDelete = indexSet.map { viewModel.tasks[$0] }
                    for t in toDelete {
                        viewModel.delete(t)
                    }
                }
            }

            Button {
                onAdd()
            } label: {
                Label("Add Task", systemImage: "plus")
            }
            .disabled(courseId.isEmpty)
        }
    }
}

  
