//
//  SessionModel.swift
//  UniTrack
//
//  Created by Betty Dang on 2025-11-09.
//

import Foundation

struct Session: Identifiable {
        var id: String?
        var title: String
        var courseId: String
        var startDate: Date
        var endDate: Date
        var location: String
    init(
                id: String? = nil,
                title: String,
                courseId: String,
                startDate: Date,
                endDate: Date,
                location: String
    ) {
                self.id = id
                self.title = title
                self.courseId = courseId
                self.startDate = startDate
                self.endDate = endDate
                self.location = location
    }
}
