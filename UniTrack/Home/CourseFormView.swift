//
//  CourseFormView.swift
//  UniTrack
//
//  Created by Naomi on 2025-11-11.
//

import SwiftUI

struct CourseFormView: View {
    @Environment(\.dismiss) private var dismiss

        @State private var title: String = ""
        @State private var teacherId: String = ""
        let onSave: (String, String) -> Void

        var body: some View {
            NavigationStack {
                Form {
                    Section("Course Info") {
                        TextField("Course title", text: $title)
                        TextField("Teacher ID", text: $teacherId)
                    }
                }
                .navigationTitle("New Course")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            onSave(title, teacherId)
                            dismiss()
                        }
                        .disabled(title.isEmpty || teacherId.isEmpty)
                    }
                }
            }
        }
}

#Preview {
    CourseFormView{ _, _ in }
}
