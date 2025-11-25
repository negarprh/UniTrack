//
//  SessionRepository.swift
//  UniTrack
//
//  Created by Negar Pirasteh on 2025-11-25.
//


import FirebaseFirestore

class SessionRepository {
    private let db = Firestore.firestore()

    private func collection(forCourseId courseId: String) -> CollectionReference {
        db.collection("Courses")
          .document(courseId)
          .collection("Sessions")
    }

    func createSession(_ session: Session,
                       completion: @escaping (Result<Void, Error>) -> Void) {
        let col = collection(forCourseId: session.courseId)
        col.addDocument(data: session.toDictionary()) { error in
            if let error = error {
                print("createSession error:", error)
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func getSessions(forCourseId courseId: String,
                     completion: @escaping (Result<[Session], Error>) -> Void) {
        collection(forCourseId: courseId)
            .order(by: "startDate", descending: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("getSessions error:", error)
                    completion(.failure(error))
                    return
                }

                let sessions = snapshot?.documents.compactMap { doc in
                    Session.fromDictionary(id: doc.documentID, data: doc.data())
                } ?? []

                completion(.success(sessions))
            }
    }

    func updateSession(_ session: Session,
                       completion: @escaping (Result<Void, Error>) -> Void) {
        guard let id = session.id else {
            completion(.failure(NSError(
                domain: "SessionRepository",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Missing session ID."]
            )))
            return
        }

        let doc = collection(forCourseId: session.courseId).document(id)
        doc.setData(session.toDictionary(), merge: true) { error in
            if let error = error {
                print("updateSession error:", error)
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func deleteSession(_ session: Session,
                       completion: @escaping (Result<Void, Error>) -> Void) {
        guard let id = session.id else {
            completion(.failure(NSError(
                domain: "SessionRepository",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Missing session ID."]
            )))
            return
        }

        let doc = collection(forCourseId: session.courseId).document(id)
        doc.delete { error in
            if let error = error {
                print("deleteSession error:", error)
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
