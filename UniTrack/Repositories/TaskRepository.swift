//
//  TaskRepository.swift
//  UniTrack
//
//  Created by Negar Pirasteh on 2025-11-25.
//



import FirebaseFirestore

class TaskRepository {
    private let db = Firestore.firestore()
    private let collectionName = "Tasks"
    private var listener: ListenerRegistration?

    func listenAllTasks(_ onChange: @escaping ([Task]) -> Void) {
        listener?.remove()

        listener = db.collection(collectionName)
            .order(by: "dueDate", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("listenAllTasks error:", error)
                    onChange([])
                    return
                }

                let items: [Task] = snapshot?.documents.compactMap { doc in
                    Task.fromDictionary(id: doc.documentID, data: doc.data())
                } ?? []

                onChange(items)
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    func createTask(_ task: Task, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection(collectionName).addDocument(data: task.toDictionary()) { error in
            if let error = error {
                print("createTask error:", error)
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func updateTask(_ task: Task, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let id = task.id else {
            completion(.failure(NSError(
                domain: "TaskRepository",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Missing task ID."]
            )))
            return
        }

        db.collection(collectionName).document(id).setData(task.toDictionary(), merge: true) { error in
            if let error = error {
                print("updateTask error:", error)
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func deleteTask(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection(collectionName).document(id).delete { error in
            if let error = error {
                print("deleteTask error:", error)
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }


    func getTasks(forCourseId courseId: String,
                  completion: @escaping (Result<[Task], Error>) -> Void) {
        db.collection(collectionName)
            .whereField("courseId", isEqualTo: courseId)
            .order(by: "dueDate", descending: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                let items: [Task] = snapshot?.documents.compactMap { doc in
                    Task.fromDictionary(id: doc.documentID, data: doc.data())
                } ?? []

                completion(.success(items))
            }
    }
}
