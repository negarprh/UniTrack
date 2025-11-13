//
//  StudyLogModel.swift
//  UniTrack
//
//  Created by Betty Dang on 2025-11-11.
//

import Foundation
import FirebaseFirestore

struct StudyLog: Identifiable {
    var id: String?          
    let date: Date
    let mins: Int
    let courseId: String      
    let sessionId: String
    
    init(id: String? = nil,
             date: Date,
             mins: Int,
             courseId: String,
             sessionId: String) {
            self.id = id
            self.date = date
            self.mins = mins
            self.courseId = courseId
            self.sessionId = sessionId
        }

    func toDictionary() -> [String: Any] {
        return [
            "date": Timestamp(date: date),
            "mins": mins,
            "courseId": courseId,
            "sessionId": sessionId
        ]
    }
    
    static func fromDictionary(id: String, data: [String: Any]) -> StudyLog? {
        guard
            let date = data["date"] as? Timestamp,
            let mins = data["mins"] as? Int,
            let courseId = data["courseId"] as? String,
            let sessionId = data["sessionId"] as? String
        else {
            return nil
        }
        
        return StudyLog(
            id: id,
            date: date.dateValue(),
            mins: mins,
            courseId: courseId,
            sessionId: sessionId
        )
    }
}
