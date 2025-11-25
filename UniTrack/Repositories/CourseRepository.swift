//
//  CourseRepository.swift
//  UniTrack
//
//  Created by Negar Pirasteh on 2025-11-25.
//


import FirebaseFirestore

class CourseRepository {
    private let db = Firestore.firestore()
    private let collectionName = "Courses"
    private var listener: ListenerRegistration?

    // Create course and return its Firestore ID
    func createCourse(_ course: Course,
                      completion: @escaping (Result<String, Error>) -> Void) {
        var ref: DocumentReference?

        ref = db.collection(collectionName).addDocument(data: course.toDictionary()) { error in
            if let error = error {
                completion(.failure(error))
            } else if let id = ref?.documentID {
                completion(.success(id))
            } else {
                completion(.failure(NSError(
                    domain: "CourseRepository",
                    code: 500,
                    userInfo: [NSLocalizedDescriptionKey: "Missing course ID."]
                )))
            }
        }
    }

    func listenAllCourses(_ onChange: @escaping ([Course]) -> Void) {
        listener?.remove()

        listener = db.collection(collectionName)
            .order(by: "title", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("listenAllCourses error:", error.localizedDescription)
                    onChange([])
                    return
                }

                let items: [Course] = snapshot?.documents.compactMap { doc in
                    Course.fromDictionary(id: doc.documentID, data: doc.data())
                } ?? []

                onChange(items)
            }
    }

    func updateCourse(_ course: Course,
                      completion: @escaping (Result<Void, Error>) -> Void) {
        guard let id = course.id else {
            completion(.failure(NSError(
                domain: "CourseRepository",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Missing course ID."]
            )))
            return
        }

        db.collection(collectionName).document(id).setData(course.toDictionary(), merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func deleteCourse(id: String,
                      completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection(collectionName).document(id).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }
}
