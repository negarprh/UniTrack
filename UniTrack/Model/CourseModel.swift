//
//  CourseModel.swift
//  UniTrack
//
//  Created by Betty Dang on 2025-11-09.
//

import Foundation
import FirebaseFirestore

struct Course: Identifiable {
    var id: String?
    var title: String
    var tasks: [Task]
    var sessions: [Session]
    var teacherId: String

    init(
        id: String? = nil,
        title: String,
        tasks: [Task] = [],
        sessions: [Session] = [],
        teacherId: String
    ) {
        self.id = id
        self.title = title
        self.tasks = tasks
        self.sessions = sessions
        self.teacherId = teacherId
    }

    func toDictionary() -> [String: Any] {
        return [
            "title": title,
            "teacherId": teacherId
        ]
    }

    static func fromDictionary(id: String, data: [String: Any]) -> Course? {
        guard
            let title = data["title"] as? String,
            let teacherId = data["teacherId"] as? String
        else { return nil }

        return Course(id: id, title: title, tasks: [], sessions: [], teacherId: teacherId)
    }
}
