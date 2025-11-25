//
//  TaskModel.swift
//  UniTrack
//
//  Created by Betty Dang on 2025-11-11.
//


import Foundation
import FirebaseFirestore

struct Task: Identifiable {
    var id: String?
    var title: String
    var courseId: String
    var courseTitle: String
    var dueDate: Date
    var isDone: Bool

    init(
        id: String? = nil,
        title: String,
        courseId: String,
        courseTitle: String,
        dueDate: Date,
        isDone: Bool = false
    ) {
        self.id = id
        self.title = title
        self.courseId = courseId
        self.courseTitle = courseTitle
        self.dueDate = dueDate
        self.isDone = isDone
    }

    func toDictionary() -> [String: Any] {
        [
            "title": title,
            "courseId": courseId,
            "courseTitle": courseTitle,
            "dueDate": Timestamp(date: dueDate),
            "isDone": isDone
        ]
    }

    static func fromDictionary(id: String, data: [String: Any]) -> Task? {
        guard
            let title = data["title"] as? String,
            let courseId = data["courseId"] as? String,
            let courseTitle = data["courseTitle"] as? String,
            let dueTs = data["dueDate"] as? Timestamp,
            let isDone = data["isDone"] as? Bool
        else {
            return nil
        }

        return Task(
            id: id,
            title: title,
            courseId: courseId,
            courseTitle: courseTitle,
            dueDate: dueTs.dateValue(),
            isDone: isDone
        )
    }
}
