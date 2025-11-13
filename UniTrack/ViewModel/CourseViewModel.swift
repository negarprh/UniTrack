//
//  CourseViewModel.swift
//  UniTrack
//
//  Created by Naomi on 2025-11-11.
//

import Foundation
import SwiftUI

final class CourseViewModel: ObservableObject {
    @Published var courses: [Course] = []
    @Published var isLoading = false
    private let repo = CourseRepository()

    init() { observeCourses() }

    private func observeCourses() {
        isLoading = true
        repo.listenAllCourses { [weak self] items in
            DispatchQueue.main.async {
                self?.courses = items
                self?.isLoading = false
            }
        }
    }

    func addCourse(title: String, teacherId: String) {
        let new = Course(title: title, tasks: [], sessions: [], teacherId: teacherId)
        repo.createCourse(new) { result in
            if case let .failure(err) = result { print("createCourse:", err.localizedDescription) }
        }
    }

    func updateCourse(_ course: Course) {
        repo.updateCourse(course) { result in
            if case let .failure(err) = result { print("updateCourse:", err.localizedDescription) }
        }
    }

    func deleteCourse(at offsets: IndexSet) {
        let toDelete = offsets.map { courses[$0] }
        for c in toDelete {
            if let id = c.id {
                repo.deleteCourse(id: id) { result in
                    if case let .failure(err) = result { print("deleteCourse:", err.localizedDescription) }
                }
            }
        }
    }

    deinit { repo.stopListening() }
}
