//
//  TaskModel.swift
//  UniTrack
//
//  Created by Betty Dang on 2025-11-09.
//

import Foundation

struct Task: Identifiable {
    let id = UUID()
    let title: String
    let type: String
    let dueDate: Date
    let isCompleted: Bool
    let CourseId: Course  // task belong to spicific course
    
    init(title: String, type: String, dueDate: Date, isCompleted: Bool, CourseId: Course) {
        self.title = title
        self.type = type
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.CourseId = CourseId
    }
}
