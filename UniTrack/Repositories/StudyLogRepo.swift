//
//  StudyLogRepo.swift
//  UniTrack
//
//  Created by Betty Dang on 2025-11-11.
//

import FirebaseFirestore

class StudyLogRepository {
    private let db = Firestore.firestore()
    private let collectionName = "studyLogs"
    
    // Create
    func createStudyLog(_ studyLog: StudyLog, completion: @escaping (Result<Void, Error>) -> Void) {
        let data = studyLog.toDictionary()
        db.collection(collectionName).addDocument(data: data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // Read
    func getStudyLog(byId id: String, completion: @escaping (Result<StudyLog, Error>) -> Void) {
        db.collection(collectionName).document(id).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists, let data = document.data() else {
                completion(.failure(NSError(domain: "StudyLogRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "StudyLog not found."])))
                return
            }
            
            if let studyLog = StudyLog.fromDictionary(id: document.documentID, data: data) {
                completion(.success(studyLog))
            } else {
                completion(.failure(NSError(domain: "StudyLogRepository", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to decode StudyLog data."])))
            }
        }
    }
    
    // Update
    func updateStudyLog(_ studyLog: StudyLog, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let id = studyLog.id else {
            completion(.failure(NSError(domain: "StudyLogRepository", code: 400, userInfo: [NSLocalizedDescriptionKey: "Missing StudyLog ID."])))
            return
        }
        
        let data = studyLog.toDictionary()
        db.collection(collectionName).document(id).setData(data, merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // Delete
    func deleteStudyLog(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection(collectionName).document(id).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // Get all logs for Course
    func getStudyLogs(forCourseId courseId: String, completion: @escaping (Result<[StudyLog], Error>) -> Void) {
        db.collection(collectionName)
            .whereField("courseId", isEqualTo: courseId)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let logs = snapshot?.documents.compactMap { doc in
                    StudyLog.fromDictionary(id: doc.documentID, data: doc.data())
                } ?? []
                
                completion(.success(logs))
            }
    }
    
    // Get all logs for Session
    func getStudyLogs(forSessionId sessionId: String, completion: @escaping (Result<[StudyLog], Error>) -> Void) {
        db.collection(collectionName)
            .whereField("sessionId", isEqualTo: sessionId)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let logs = snapshot?.documents.compactMap { doc in
                    StudyLog.fromDictionary(id: doc.documentID, data: doc.data())
                } ?? []
                
                completion(.success(logs))
            }
    }
}
