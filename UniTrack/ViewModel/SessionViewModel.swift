//
//  SessionViewModel.swift
//  UniTrack
//
//  Created by Naomi on 2025-11-12.
//

import Foundation
import SwiftUI

final class SessionViewModel: ObservableObject {
    @Published var sessions: [Session] = []
    private let repo = SessionRepository()

    func load(forCourseId courseId: String) {
        repo.getSessions(forCourseId: courseId) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let items) = result { self?.sessions = items }
                else { self?.sessions = [] }
            }
        }
    }

    func add(_ s: Session, completion: (() -> Void)? = nil) {
        repo.createSession(s) { _ in completion?() }
    }

    func delete(_ s: Session, completion: (() -> Void)? = nil) {
        guard let id = s.id else { completion?(); return }
        repo.deleteSession(id: id) { _ in completion?() }
    }

    func update(_ s: Session, completion: (() -> Void)? = nil) {
        repo.updateSession(s) { _ in completion?() }
    }
}


