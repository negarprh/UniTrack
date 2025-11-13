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

    
    private func encode(_ task: Task) -> [String: Any] {
        return [
            "title": task.title,
            "type": task.type,
            "courseId": task.courseId,
            "dueDate": Timestamp(date: task.dueDate),
            "isDone": task.isDone
        ]
    }

    // Decode
    private func decode(id: String, _ data: [String: Any]) -> Task? {
        guard
            let title = data["title"] as? String,
            let type = data["type"] as? String,
            let courseId = data["courseId"] as? String,
            let dueTS = data["dueDate"] as? Timestamp,
            let isDone = data["isDone"] as? Bool
        else { return nil }

        return Task(
            id: id,
            courseId: courseId,
            type: type,
            title: title,
            dueDate: dueTS.dateValue(),
            isDone: isDone
        )
    }

    // Create
    func createTask(_ task: Task, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection(collectionName).addDocument(data: encode(task)) { error in
            if let error = error { completion(.failure(error)) }
            else { completion(.success(())) }
        }
    }

    // Read single
    func getTask(byId id: String, completion: @escaping (Result<Task, Error>) -> Void) {
        db.collection(collectionName).document(id).getDocument { doc, error in
            if let error = error { completion(.failure(error)); return }
            guard let d = doc?.data(), doc?.exists == true else {
                completion(.failure(NSError(domain: "TaskRepository", code: 404,
                                            userInfo: [NSLocalizedDescriptionKey: "Task not found."])))
                return
            }
            if let task = self.decode(id: doc!.documentID, d) {
                completion(.success(task))
            } else {
                completion(.failure(NSError(domain: "TaskRepository", code: 500,
                                            userInfo: [NSLocalizedDescriptionKey: "Failed to decode task data."])))
            }
        }
    }

    // Read by course
    func getTasks(forCourseId courseId: String, completion: @escaping (Result<[Task], Error>) -> Void) {
        db.collection(collectionName)
            .whereField("courseId", isEqualTo: courseId)
            .order(by: "dueDate")
            .getDocuments { snapshot, error in
                if let error = error { completion(.failure(error)); return }
                let items: [Task] = snapshot?.documents.compactMap { doc in
                    self.decode(id: doc.documentID, doc.data())
                } ?? []
                completion(.success(items))
            }
    }

    // Update
    func updateTask(_ task: Task, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let id = task.id, !id.isEmpty else {
            completion(.failure(NSError(domain: "TaskRepository", code: 400,
                                        userInfo: [NSLocalizedDescriptionKey: "Missing task ID."])))
            return
        }
        db.collection(collectionName).document(id).setData(encode(task), merge: true) { error in
            if let error = error { completion(.failure(error)) }
            else { completion(.success(())) }
        }
    }

    // Delete
    func deleteTask(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection(collectionName).document(id).delete { error in
            if let error = error { completion(.failure(error)) }
            else { completion(.success(())) }
        }
    }
}

