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

    func toDictionary() -> [String: Any] {
        [
            "title": title,
            "courseId": courseId,
            "startDate": Timestamp(date: startDate),
            "endDate": Timestamp(date: endDate),
            "location": location
        ]
    }

    static func fromDictionary(id: String, data: [String: Any]) -> Session? {
        guard
            let title = data["title"] as? String,
            let courseId = data["courseId"] as? String,
            let startTimestamp = data["startDate"] as? Timestamp,
            let endTimestamp = data["endDate"] as? Timestamp,
            let location = data["location"] as? String
        else {
            return nil
        }

        return Session(
            id: id,
            title: title,
            courseId: courseId,
            startDate: startTimestamp.dateValue(),
            endDate: endTimestamp.dateValue(),
            location: location
        )
    }

    var weekdayText: String {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f.string(from: startDate)
    }

    var timeRangeText: String {
        let f = DateFormatter()
        f.dateStyle = .none
        f.timeStyle = .short
        return "\(f.string(from: startDate)) – \(f.string(from: endDate))"
    }
}
