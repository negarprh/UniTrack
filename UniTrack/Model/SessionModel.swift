//
//  SessionModel.swift
//  UniTrack
//
//  Created by Betty Dang on 2025-11-09.

import Foundation
import FirebaseFirestore

struct Session: Identifiable {
    let id: String?
    let title: String
    let courseId: String
    let startDate: Date
    let endDate: Date
    let location: String

    init(id: String? = nil,
         title: String,
         courseId: String,
         startDate: Date,
         endDate: Date,
         location: String) {
        self.id = id
        self.title = title
        self.courseId = courseId
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
    }
}

