//
//  TaskFormView.swift
//  UniTrack
//
//  Created by Naomi on 2025-11-12.
//

import SwiftUI

struct TaskFormView: View {
    @Environment(\.dismiss) private var dismiss

    let courseId: String
    let onSave: (Task) -> Void

    @State private var title = ""
    @State private var type = "assignment"
    @State private var dueDate = Date()

    var body: some View {
        NavigationStack {
            Form {
                TextField("Task Title", text: $title)

                Picker("Type", selection: $type) {
                    Text("Assignment").tag("assignment")
                    Text("Exam").tag("exam")
                }

                DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
            }
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let t = Task(
                            id: nil,
                            courseId: courseId,
                            type: type,
                            title: title,
                            dueDate: dueDate,
                            isDone: false
                        )
                        onSave(t)
                        dismiss()
                    }.disabled(title.isEmpty)
                }
            }
        }
    }
}

