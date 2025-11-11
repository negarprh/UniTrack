//
//  StudyLogModel.swift
//  UniTrack
//
//  Created by Betty Dang on 2025-11-09.
//

import Foundation

struct StudyLog {
    let int = UUID()
    let date: String
    let mins: Int
    let courseId: Course
    let sessionId: Session
    
    init(date: String, mins: Int, courseId: Course, sessionId: Session) {
        self.date = date
        self.mins = mins
        self.courseId = courseId
        self.sessionId = sessionId
    }
   
}
