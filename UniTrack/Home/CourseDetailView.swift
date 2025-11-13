//
//  CourseDetailView.swift
//  UniTrack
//
//  Created by Naomi on 2025-11-11.
//

import SwiftUI

struct CourseDetailView: View {
    @State var course: Course
    let onSave: (Course) -> Void

    @State private var sessions: [Session] = []
    @State private var showingAddSession = false
    private let sessionRepo = SessionRepository()

    
    @State private var tasks: [Task] = []
    @State private var showingAddTask = false
    private let taskRepo = TaskRepository()

    var body: some View {
        Form {
           
            Section("Course Info") {
                TextField("Title", text: $course.title)
                TextField("Teacher ID", text: $course.teacherId)
            }

            
            Section("Sessions") {
                if sessions.isEmpty {
                    Text("No sessions yet")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(sessions) { session in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.title).font(.headline)
                            Text(session.location)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(session.startDate.formatted(date: .abbreviated, time: .shortened)) – \(session.endDate.formatted(date: .abbreviated, time: .shortened))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .onDelete { indexSet in
                        let toDelete = indexSet.map { sessions[$0] }
                        for s in toDelete {
                            if let id = s.id {
                                sessionRepo.deleteSession(id: id) { _ in
                                    loadSessions()
                                }
                            }
                        }
                    }
                }

                Button {
                    showingAddSession = true
                } label: {
                    Label("Add Session", systemImage: "plus")
                }
            }

            
            Section("Tasks") {
                if tasks.isEmpty {
                    Text("No tasks yet")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(tasks) { task in
                        HStack {
                            // Toggle completion
                            Button {
                                var updated = task
                                updated.isDone.toggle()
                                taskRepo.updateTask(updated) { _ in
                                    loadTasks()
                                }
                            } label: {
                                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                            }
                            .buttonStyle(.plain)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(task.title).font(.headline)
                                Text("\(task.type.capitalized) • due \(task.dueDate.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                    }
                    .onDelete { indexSet in
                        let toDelete = indexSet.map { tasks[$0] }
                        for t in toDelete {
                            if let id = t.id {
                                taskRepo.deleteTask(id: id) { _ in
                                    loadTasks()
                                }
                            }
                        }
                    }
                }

                Button {
                    showingAddTask = true
                } label: {
                    Label("Add Task", systemImage: "plus")
                }
            }
        }
        .navigationTitle(course.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    onSave(course)
                }
            }
        }
        .onAppear {
            loadSessions()
            loadTasks()
        }
       
        .sheet(isPresented: $showingAddSession) {
            AddSessionForm(courseId: course.id ?? "") { newSession in
                sessionRepo.createSession(newSession) { _ in
                    loadSessions()
                }
            }
        }
        
        .sheet(isPresented: $showingAddTask) {
            AddTaskForm(courseId: course.id ?? "") { newTask in
                taskRepo.createTask(newTask) { _ in
                    loadTasks()
                }
            }
        }
    }

    
    private func loadSessions() {
        guard let courseId = course.id, !courseId.isEmpty else {
            sessions = []
            return
        }
        sessionRepo.getSessions(forCourseId: courseId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetched):
                    self.sessions = fetched
                case .failure(let error):
                    print("Error fetching sessions: \(error.localizedDescription)")
                    self.sessions = []
                }
            }
        }
    }

    private func loadTasks() {
        guard let courseId = course.id, !courseId.isEmpty else {
            tasks = []
            return
        }
        taskRepo.getTasks(forCourseId: courseId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    self.tasks = items
                case .failure(let err):
                    print("Error fetching tasks:", err.localizedDescription)
                    self.tasks = []
                }
            }
        }
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
                    DatePicker("Start", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("End", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                }
            }
            .navigationTitle("New Session")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let s = Session(
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


struct AddTaskForm: View {
    @Environment(\.dismiss) private var dismiss

    let courseId: String
    let onSave: (Task) -> Void

    @State private var title: String = ""
    @State private var type: String = "assignment"  // or "exam"
    @State private var dueDate: Date = Date()
    @State private var isDone: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Task Info") {
                    TextField("Title", text: $title)
                    Picker("Type", selection: $type) {
                        Text("Assignment").tag("assignment")
                        Text("Exam").tag("exam")
                    }
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date])
                    Toggle("Completed", isOn: $isDone)
                }
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
                            isDone: isDone
                        )
                        onSave(t)
                        dismiss()
                    }
                    .disabled(title.isEmpty || courseId.isEmpty)
                }
            }
        }
    }
}

#Preview {
    CourseDetailView(
        course: Course(
            title: "Sample Course",
            tasks: [],
            sessions: [],
            teacherId: "T001"
        ),
        onSave: { _ in }
    )
}
