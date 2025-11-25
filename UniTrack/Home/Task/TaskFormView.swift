//
//  TaskFormView.swift
//  UniTrack
//
//  Created by Naomi on 2025-11-12.



import SwiftUI

struct TaskFormView: View {
    @Environment(\.dismiss) private var dismiss

    let existingTask: Task?
    let isTeacher: Bool

    @State private var title: String
    @State private var dueDate: Date
    @State private var courseId: String
    @State private var courseTitle: String

    @State private var courses: [Course] = []
    @State private var errorMessage: String?

    private let taskRepo = TaskRepository()
    private let courseRepo = CourseRepository()

    init(existingTask: Task?, isTeacher: Bool) {
        self.existingTask = existingTask
        self.isTeacher = isTeacher

        _title = State(wrappedValue: existingTask?.title ?? "")
        _dueDate = State(wrappedValue: existingTask?.dueDate ?? Date())
        _courseId = State(wrappedValue: existingTask?.courseId ?? "")
        _courseTitle = State(wrappedValue: existingTask?.courseTitle ?? "")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.blue.opacity(0.1), .purple.opacity(0.15)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                Form {
                    if let errorMessage {
                        Section {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.footnote)
                        }
                    }

                    Section {
                        TextField("Assignment title", text: $title)
                        DatePicker(
                            "Due date",
                            selection: $dueDate,
                            displayedComponents: [.date]
                        )
                    } header: {
                        Label("Assignment info", systemImage: "text.badge.checkmark")
                    } footer: {
                        Text("Students will see the title and due date on their dashboard.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Section {
                        if courses.isEmpty {
                            Text("No courses available yet.")
                                .foregroundColor(.secondary)
                        } else {
                            Picker("Course", selection: $courseId) {
                                ForEach(courses) { course in
                                    Text(course.title).tag(course.id ?? "")
                                }
                            }
                        }
                    } header: {
                        Label("Course", systemImage: "book.closed")
                    } footer: {
                        Text("Link the assignment to one of your existing courses.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                   
                    if isTeacher, let existing = existingTask, let id = existing.id {
                        Section {
                            Button(role: .destructive) {
                                deleteTask(id: id)
                            } label: {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Delete assignment")
                                }
                            }
                        } footer: {
                            Text("This will remove the assignment for all students.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(existingTask == nil ? "New Assignment" : "Edit Assignment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveTask() }
                        .disabled(title.isEmpty || courseId.isEmpty || !isTeacher)
                }
            }
            .onAppear(perform: loadCourses)
            .onDisappear {
                courseRepo.stopListening()
            }
            .onChange(of: courseId) { newId in
                if let match = courses.first(where: { $0.id == newId }) {
                    courseTitle = match.title
                }
            }
        }
    }


    private func loadCourses() {
        courseRepo.listenAllCourses { items in
            DispatchQueue.main.async {
                self.courses = items

                if self.courseId.isEmpty,
                   let first = items.first,
                   let id = first.id {
                    self.courseId = id
                    self.courseTitle = first.title
                }

                if let existing = existingTask,
                   let match = items.first(where: { $0.id == existing.courseId }) {
                    self.courseTitle = match.title
                }
            }
        }
    }

    private func saveTask() {
        guard isTeacher else {
            errorMessage = "Only teachers can modify assignments."
            return
        }

        let isDone = existingTask?.isDone ?? false

        let task = Task(
            id: existingTask?.id,
            title: title,
            courseId: courseId,
            courseTitle: courseTitle,
            dueDate: dueDate,
            isDone: isDone
        )

        if existingTask == nil {
            taskRepo.createTask(task) { result in
                handleResult(result)
            }
        } else {
            taskRepo.updateTask(task) { result in
                handleResult(result)
            }
        }
    }

    private func deleteTask(id: String) {
        guard isTeacher else {
            errorMessage = "Only teachers can delete assignments."
            return
        }

        taskRepo.deleteTask(id: id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    dismiss()
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func handleResult(_ result: Result<Void, Error>) {
        DispatchQueue.main.async {
            switch result {
            case .success:
                dismiss()
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
