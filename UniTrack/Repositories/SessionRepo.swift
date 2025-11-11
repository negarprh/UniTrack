//
//  SessionRepo.swift
//  UniTrack
//
//  Created by Betty Dang on 2025-11-09.
//

import FirebaseFirestore

class SessionRepository {
    private let db = Firestore.firestore()
    private let collectionName = "sessions"
    
    // Create
    func createSession(_ session: Session, completion: @escaping (Result<Void, Error>) -> Void) {
        let data: [String: Any] = [
            "title": session.title,
            "courseId": session.courseId,
            "startDate": Timestamp(date: session.startDate),
            "endDate": Timestamp(date: session.endDate),
            "location": session.location
        ]
        
        db.collection(collectionName).addDocument(data: data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // Read
    func getSession(byId id: String, completion: @escaping (Result<Session, Error>) -> Void) {
        db.collection(collectionName).document(id).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = document?.data(), document!.exists else {
                completion(.failure(NSError(domain: "SessionRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Session not found."])))
                return
            }
            
            if let session = self.decodeSession(id: document!.documentID, data: data) {
                completion(.success(session))
            } else {
                completion(.failure(NSError(domain: "SessionRepository", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to decode session data."])))
            }
        }
    }
    
    // Update
    func updateSession(_ session: Session, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let id = session.id else {
            completion(.failure(NSError(domain: "SessionRepository", code: 400, userInfo: [NSLocalizedDescriptionKey: "Missing session ID."])))
            return
        }

        let data: [String: Any] = [
            "title": session.title,
            "courseId": session.courseId,
            "startDate": Timestamp(date: session.startDate),
            "endDate": Timestamp(date: session.endDate),
            "location": session.location
        ]
        
        db.collection(collectionName).document(id).setData(data, merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // Delete
    func deleteSession(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection(collectionName).document(id).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // Get All Sessions for a Course
    func getSessions(forCourseId courseId: String, completion: @escaping (Result<[Session], Error>) -> Void) {
        db.collection(collectionName)
            .whereField("courseId", isEqualTo: courseId)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let sessions = snapshot?.documents.compactMap { doc in
                    self.decodeSession(id: doc.documentID, data: doc.data())
                } ?? []
                
                completion(.success(sessions))
            }
    }
    
    // Decode Firestore data manually
    private func decodeSession(id: String, data: [String: Any]) -> Session? {
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
}
