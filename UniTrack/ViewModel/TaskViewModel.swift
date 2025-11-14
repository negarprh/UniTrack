//
//  TaskViewModel.swift
//  UniTrack
//
//  Created by Naomi on 2025-11-12.
//

import Foundation
import SwiftUI

final class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    private let repo = TaskRepository()

    func load(forCourseId courseId: String) {
        repo.getTasks(forCourseId: courseId) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let items) = result { self?.tasks = items }
                else { self?.tasks = [] }
            }
        }
    }

    func add(_ t: Task, completion: (() -> Void)? = nil) {
        repo.createTask(t) { _ in completion?() }
    }
    func update(_ t: Task, completion: (() -> Void)? = nil) {
           repo.updateTask(t) { _ in completion?() }
       }

    func toggleDone(_ t: Task) {
            var copy = t
            copy.isDone.toggle()
            update(copy)
        }

    func delete(_ t: Task, completion: (() -> Void)? = nil) {
        guard let id = t.id else { completion?(); return }
        repo.deleteTask(id: id) { _ in completion?() }
    }
}



