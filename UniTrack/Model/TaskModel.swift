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
    let title: String
    let type: String
    let dueDate: Date
    let isCompleted: Bool
    let courseId: String

    func toDictionary() -> [String: Any] {
        return [
            "title": title,
            "type": type,
            "dueDate": Timestamp(date: dueDate),
            "isCompleted": isCompleted,
            "courseId": courseId
        ]
    }

    static func fromDictionary(_ data: [String: Any]) -> Task? {
        guard
            let title = data["title"] as? String,
            let type = data["type"] as? String,
            let dueTimestamp = data["dueDate"] as? Timestamp,
            let isCompleted = data["isCompleted"] as? Bool,
            let courseId = data["courseId"] as? String
        else {
            return nil
        }

        return Task(
            id: data["id"] as? String,
            title: title,
            type: type,
            dueDate: dueTimestamp.dateValue(),
            isCompleted: isCompleted,
            courseId: courseId
        )
    }
}

