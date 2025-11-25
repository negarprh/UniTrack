//
//  SessionViewModel.swift
//  UniTrack
//
//  Created by Naomi on 2025-11-12.
//



import Foundation

final class SessionViewModel: ObservableObject {
    @Published var sessions: [Session] = []

    private let repo = SessionRepository()
    private let courseId: String

    init(courseId: String) {
        self.courseId = courseId
        load()
    }

    func load() {
        repo.getSessions(forCourseId: courseId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    self?.sessions = items
                case .failure:
                    self?.sessions = []
                }
            }
        }
    }

    func add(_ s: Session, completion: (() -> Void)? = nil) {
        repo.createSession(s) { [weak self] _ in
            self?.load()
            completion?()
        }
    }

    func delete(_ s: Session, completion: (() -> Void)? = nil) {
        repo.deleteSession(s) { [weak self] _ in
            self?.load()
            completion?()
        }
    }


    func update(_ s: Session, completion: (() -> Void)? = nil) {
        repo.updateSession(s) { [weak self] _ in
            self?.load()
            completion?()
        }
    }
}
