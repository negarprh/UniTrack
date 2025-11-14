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

    init() {
        observeCourses()
    }


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
       
        let newId = UUID().uuidString

        let newCourse = Course(
            id: newId,
            title: title,
            tasks: [],
            sessions: [],
            teacherId: teacherId
        )

        courses.append(newCourse)


        repo.createCourse(newCourse) { result in
            if case let .failure(err) = result {
                print("createCourse:", err.localizedDescription)
            }
        }
    }

    func updateCourse(_ course: Course) {
        if let id = course.id,
           let index = courses.firstIndex(where: { $0.id == id }) {
            courses[index] = course
        }


        repo.updateCourse(course) { result in
            if case let .failure(err) = result {
                print("updateCourse:", err.localizedDescription)
            }
        }
    }

    func deleteCourse(at offsets: IndexSet) {
        let idsToDelete: [String] = offsets.compactMap { idx in
            courses[idx].id
        }

        courses.remove(atOffsets: offsets)

        for id in idsToDelete {
            repo.deleteCourse(id: id) { result in
                if case let .failure(err) = result {
                    print("deleteCourse:", err.localizedDescription)
                }
            }
        }
    }

    deinit {
        repo.stopListening()
    }
}
