//
//  CourseDetailView.swift
//  UniTrack
//
//  Created by Naomi on 2025-11-11.
//

import SwiftUI

struct CourseDetailView: View {
    @Environment(\.dismiss) private var dismiss

    @State var course: Course
    let isTeacher: Bool
    let onSave: (Course) -> Void
    let onDelete: (Course) -> Void

    @StateObject private var sessionVM: SessionViewModel

    @State private var showingAddSession = false

    init(course: Course,
         isTeacher: Bool,
         onSave: @escaping (Course) -> Void,
         onDelete: @escaping (Course) -> Void) {
        _course = State(initialValue: course)
        self.isTeacher = isTeacher
        self.onSave = onSave
        self.onDelete = onDelete

        _sessionVM = StateObject(
            wrappedValue: SessionViewModel(courseId: course.id ?? "")
        )
    }

    var body: some View {
        Form {
           
            Section {
                if isTeacher {
                    TextField("Course title", text: $course.title)
                    TextField("Teacher id / name", text: $course.teacherId)
                } else {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(course.title)
                            .font(.headline)
                        Text("Teacher: \(course.teacherId)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Label("Course Info", systemImage: "info.circle")
            }

            
            Section {
                if sessionVM.sessions.isEmpty {
                    HStack(spacing: 10) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .foregroundStyle(.secondary)
                        Text("No weekly sessions yet")
                            .foregroundColor(.secondary)
                    }
                } else {
                    ForEach(sessionVM.sessions) { session in
                        sessionRow(session)
                    }
                    .onDelete { indexSet in
                        guard isTeacher else { return }
                        let items = indexSet.map { sessionVM.sessions[$0] }
                        for s in items {
                            sessionVM.delete(s)
                        }
                    }
                }

                if isTeacher {
                    Button {
                        showingAddSession = true
                    } label: {
                        Label("Add Session", systemImage: "plus")
                    }
                }
            } header: {
                Label("Weekly Sessions", systemImage: "calendar")
            }
        }
        .navigationTitle(course.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if isTeacher, course.id != nil {
                    Button(role: .destructive) {
                        onDelete(course)
                        dismiss()
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }

            if isTeacher {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(course)
                    }
                }
            }
        }
        .onAppear {
            if course.id != nil {
                sessionVM.load()
            }
        }
        .sheet(isPresented: $showingAddSession) {
            AddSessionForm(courseId: course.id ?? "") { newSession in
                sessionVM.add(newSession)
            }
        }
    }

    private func sessionRow(_ session: Session) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(session.weekdayText)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.blue.opacity(0.12))
                )
                .foregroundStyle(.blue)

            VStack(alignment: .leading, spacing: 4) {
                Text(session.title)
                    .font(.subheadline.weight(.semibold))
                Text(session.timeRangeText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(session.location)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 2)
    }
}

struct AddSessionForm: View {
    @Environment(\.dismiss) private var dismiss

    let courseId: String
    let onSave: (Session) -> Void

    @State private var title: String = ""
    @State private var location: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date().addingTimeInterval(3600)

    var body: some View {
        NavigationStack {
            Form {
                Section("Session Info") {
                    TextField("Title", text: $title)
                    TextField("Location", text: $location)
                    DatePicker("Start", selection: $startDate,
                               displayedComponents: [.date, .hourAndMinute])
                    DatePicker("End", selection: $endDate,
                               displayedComponents: [.date, .hourAndMinute])
                }
            }
            .navigationTitle("New Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let s = Session(
                            id: nil,
                            title: title,
                            courseId: courseId,
                            startDate: startDate,
                            endDate: endDate,
                            location: location
                        )
                        onSave(s)
                        dismiss()
                    }
                    .disabled(title.isEmpty || location.isEmpty || courseId.isEmpty)
                }
            }
        }
    }
}
