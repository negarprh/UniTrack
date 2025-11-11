//
//  CourseModel.swift
//  UniTrack
//
//  Created by Betty Dang on 2025-11-09.
//

import Foundation

struct Course: Identifiable {
    var id: String?              // Document ID
    let title: String
    var tasks: [Task]
    var sessions: [Session]
    let teacherId: String

    init(id: String? = nil,
         title: String,
         tasks: [Task] = [],
         sessions: [Session] = [],
         teacherId: String) {
        self.id = id
        self.title = title
        self.tasks = tasks
        self.sessions = sessions
        self.teacherId = teacherId
    }

    func toDictionary() -> [String: Any] {
        return [
            "title": title,
            "teacherId": teacherId,
            "tasks": tasks.map { $0.toDictionary() },
            "sessions": sessions.map { $0.toDictionary() }
        ]
    }
}
