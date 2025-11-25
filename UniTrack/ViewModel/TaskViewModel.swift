//
//  TaskViewModel.swift
//  UniTrack
//
//  Created by Naomi on 2025-11-12.
//


import Foundation

struct TaskDraft {
    var title: String
    var courseId: String
    var courseTitle: String
    var dueDate: Date
}

final class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var isLoading = false

    private let repo = TaskRepository()

    init() {
        observeTasks()
    }

    private func observeTasks() {
        isLoading = true
        repo.listenAllTasks { [weak self] items in
            DispatchQueue.main.async {
                self?.tasks = items
                self?.isLoading = false
            }
        }
    }

    func addTask(from draft: TaskDraft) {
        let newTask = Task(
            id: nil,
            title: draft.title,
            courseId: draft.courseId,
            courseTitle: draft.courseTitle,
            dueDate: draft.dueDate,
            isDone: false
        )

        repo.createTask(newTask) { result in
            if case let .failure(err) = result {
                print("addTask error:", err.localizedDescription)
            }
        }
    }

    func toggleDone(_ task: Task) {
        var updated = task
        updated.isDone.toggle()
        repo.updateTask(updated) { result in
            if case let .failure(err) = result {
                print("toggleDone error:", err.localizedDescription)
            }
        }
    }

    func deleteTask(_ task: Task) {
        guard let id = task.id else { return }
        repo.deleteTask(id: id) { result in
            if case let .failure(err) = result {
                print("deleteTask error:", err.localizedDescription)
            }
        }
    }

    deinit {
        repo.stopListening()
    }
}
