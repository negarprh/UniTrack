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
    
    static func fromDictionary(id: String, data: [String: Any]) -> Course? {
        guard
            let title = data["title"] as? String,
            let teacherId = data["teacherId"] as? String
        else {
            return nil
        }
        
        let taskArray = (data["tasks"] as? [[String: Any]]) ?? []
        let sessionArray = (data["sessions"] as? [[String: Any]]) ?? []
        
        let tasks = taskArray.compactMap { Task.fromDictionary($0) }
        
        // If sessions do not have an id inside, pass nil
        let sessions = sessionArray.compactMap { sessionDict in
            Session.fromDictionary(id: sessionDict["id"] as? String ?? "", data: sessionDict)
        }
        
        return Course(id: id, title: title, tasks: tasks, sessions: sessions, teacherId: teacherId)
    }
}
