//
//  CourseModel.swift
//  UniTrack
//
//  Created by Betty Dang on 2025-11-09.
//
import Foundation

struct Course: Identifiable {
    let id = UUID() 
    let title: String
    var tasks: [Task]
    var sessions: [Session]
    let teacherId: String

    init(title: String, tasks: [Task] = [], sessions: [Session] = [], teacherId: String) {
        self.title = title
        self.tasks = tasks
        self.sessions = sessions
        self.teacherId = teacherId
    }
}

