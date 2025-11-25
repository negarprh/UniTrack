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
    @State private var teacherName: String = ""
    @State private var sessionDrafts: [SessionDraft] = []
    @State private var showingAddSessionSheet = false

    let onSave: (String, String, [SessionDraft]) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.blue.opacity(0.1), .purple.opacity(0.18)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                Form {
                    Section {
                        TextField("Course title", text: $title)
                        TextField("Teacher name", text: $teacherName)
                    } header: {
                        Label("Course Info", systemImage: "book.closed")
                    } footer: {
                        Text("This information appears in the course list and on the student dashboard.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Section {
                        if sessionDrafts.isEmpty {
                            Text("No weekly sessions added yet.")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(sessionDrafts) { draft in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(draft.title)
                                        .font(.subheadline.weight(.semibold))
                                    Text(timeRangeText(for: draft))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(draft.location)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 2)
                            }
                            .onDelete { indexSet in
                                sessionDrafts.remove(atOffsets: indexSet)
                            }
                        }

                        Button {
                            showingAddSessionSheet = true
                        } label: {
                            Label("Add Session", systemImage: "plus")
                        }
                    } header: {
                        Label("Weekly Sessions", systemImage: "calendar")
                    } footer: {
                        Text("Add one or more weekly time slots for this course.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Course")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(title, teacherName, sessionDrafts)
                        dismiss()
                    }
                    .disabled(title.isEmpty || teacherName.isEmpty)
                }
            }
            .sheet(isPresented: $showingAddSessionSheet) {
                NewSessionDraftForm { draft in
                    sessionDrafts.append(draft)
                }
            }
        }
    }

    private func timeRangeText(for draft: SessionDraft) -> String {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        return "\(f.string(from: draft.startDate)) – \(f.string(from: draft.endDate))"
    }
}

struct NewSessionDraftForm: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: (SessionDraft) -> Void

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
                    Button("Add") {
                        let draft = SessionDraft(
                            title: title,
                            startDate: startDate,
                            endDate: endDate,
                            location: location
                        )
                        onSave(draft)
                        dismiss()
                    }
                    .disabled(title.isEmpty || location.isEmpty)
                }
            }
        }
    }
}
