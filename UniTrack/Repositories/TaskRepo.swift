//
//  TaskRepo.swift
//  UniTrack
//
//  Created by Betty Dang on 2025-11-09.
//

import FirebaseFirestore

class TaskRepository {
    private let db = Firestore.firestore()
    private let collectionName = "tasks"

    // Create
    func createTask(_ task: Task, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection(collectionName).addDocument(data: task.toDictionary()) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    // Read
    func getTask(byId id: String, completion: @escaping (Result<Task, Error>) -> Void) {
        db.collection(collectionName).document(id).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = document?.data(), document!.exists else {
                completion(.failure(NSError(domain: "TaskRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Task not found."])))
                return
            }

            if var task = Task.fromDictionary(data) {
                task.id = document!.documentID
                completion(.success(task))
            } else {
                completion(.failure(NSError(domain: "TaskRepository", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to decode task data."])))
            }
        }
    }

    // Update
    func updateTask(_ task: Task, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let id = task.id else {
            completion(.failure(NSError(domain: "TaskRepository", code: 400, userInfo: [NSLocalizedDescriptionKey: "Missing task ID."])))
            return
        }

        db.collection(collectionName).document(id).setData(task.toDictionary(), merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    // Delete
    func deleteTask(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection(collectionName).document(id).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
