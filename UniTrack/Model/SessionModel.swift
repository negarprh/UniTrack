//
//  SessionModel.swift
//  UniTrack
//
//  Created by Betty Dang on 2025-11-09.
//

import Foundation

struct Session: Identifiable {
    let id = UUID()
    let title: String
    let courseId: UUID            // Reference to the Course
    let startDate: Date
    let endDate: Date
    let location: String

    init(
        title: String,
        courseId: UUID,
        startDate: Date,
        endDate: Date,
        location: String
    ) {
        self.title = title
        self.courseId = courseId
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
    }
}
