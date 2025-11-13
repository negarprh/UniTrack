//
//  CourseRepo.swift
//  UniTrack
//
//  Created by Betty Dang on 2025-11-09.
//

import FirebaseFirestore

class CourseRepository {
    private let db = Firestore.firestore()
    private let collectionName = "courses"

    // Create
    func createCourse(_ course: Course, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection(collectionName).addDocument(data: course.toDictionary()) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    // Read
    func getCourse(byId id: String, completion: @escaping (Result<Course, Error>) -> Void) {
        db.collection(collectionName).document(id).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let document = document, document.exists, let data = document.data() else {
                completion(.failure(NSError(domain: "CourseRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Course not found."])))
                return
            }

            if let course = Course.fromDictionary(id: document.documentID, data: data) {
                completion(.success(course))
            } else {
                completion(.failure(NSError(domain: "CourseRepository", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to decode course data."])))
            }
        }
    }

    // Update
    func updateCourse(_ course: Course, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let id = course.id else {
            completion(.failure(NSError(domain: "CourseRepository", code: 400, userInfo: [NSLocalizedDescriptionKey: "Missing course ID."])))
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

    // Delete
    func deleteCourse(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection(collectionName).document(id).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}



