//
//  CourseViewModel.swift
//  UniTrack
//
//  Created by Naomi on 2025-11-11.
//

import FirebaseAuth
import Foundation


struct SessionDraft: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var startDate: Date
    var endDate: Date
    var location: String
}

final class CourseViewModel: ObservableObject {
    @Published var courses: [Course] = []
    @Published var isLoading = false

    private let courseRepo = CourseRepository()
    private let sessionRepo = SessionRepository()

    init() {
        observeCourses()
    }

    private func observeCourses() {
        isLoading = true
        courseRepo.listenAllCourses { [weak self] items in
            DispatchQueue.main.async {
                self?.courses = items
                self?.isLoading = false
            }
        }
    }

    func addCourse(title: String,
                   sessionsDrafts: [SessionDraft]) {
        let teacherId = Auth.auth().currentUser?.uid ?? ""

        let newCourse = Course(
            id: nil,
            title: title,
            teacherId: teacherId
        )

        courseRepo.createCourse(newCourse) { [weak self] result in
            switch result {
            case .failure(let err):
                print("createCourse error:", err.localizedDescription)
            case .success(let courseId):
                for draft in sessionsDrafts {
                    let s = Session(
                        id: nil,
                        title: draft.title,
                        courseId: courseId,
                        startDate: draft.startDate,
                        endDate: draft.endDate,
                        location: draft.location
                    )
                    self?.sessionRepo.createSession(s) { res in
                        if case let .failure(e) = res {
                            print("createSession error:", e.localizedDescription)
                        }
                    }
                }
            }
        }
    }

    func updateCourse(_ course: Course) {
        if let id = course.id,
           let index = courses.firstIndex(where: { $0.id == id }) {
            courses[index] = course
        }

        courseRepo.updateCourse(course) { result in
            if case let .failure(err) = result {
                print("updateCourse error:", err.localizedDescription)
            }
        }
    }

    func deleteCourse(id: String) {
        courses.removeAll { $0.id == id }

        courseRepo.deleteCourse(id: id) { result in
            if case let .failure(err) = result {
                print("deleteCourse error:", err.localizedDescription)
            }
        }
    }

    func deleteCourse(at offsets: IndexSet) {
    
        let idsToDelete: [String] = offsets.compactMap { idx in
            courses[idx].id
        }

      
        courses.remove(atOffsets: offsets)

   
        for id in idsToDelete {
            deleteCourse(id: id)
        }
    }

    deinit {
        courseRepo.stopListening()
    }
}
