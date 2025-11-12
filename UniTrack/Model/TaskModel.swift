//
//  TaskModel.swift
//  UniTrack
//
//  Created by Betty Dang on 2025-11-09.
//

import Foundation

struct Task: Identifiable {
        var id: String?
        var courseId: String
        var type: String
        var title: String
        var dueDate: Date
        var isDone: Bool
    
    init(id: String? = nil,courseId: String,type: String,title: String,dueDate: Date,isDone: Bool,) {
           self.id = id
           self.courseId = courseId
           self.type = type
           self.title = title
           self.dueDate = dueDate
           self.isDone = isDone
           
       }
}
