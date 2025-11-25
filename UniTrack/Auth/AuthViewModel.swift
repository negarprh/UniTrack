//
//  AuthViewModel.swift
//  UniTrack
//
//  Created by Negar Pirasteh on 2025-11-11.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isSignedIn = Auth.auth().currentUser != nil
    @Published var role: String?
    @Published var isBusy = false
    @Published var errorMessage: String?
    @Published var infoMessage: String?

    private let db = Firestore.firestore()
    var email: String? { Auth.auth().currentUser?.email }

    private var authListener: AuthStateDidChangeListenerHandle?

    init() {
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }
            self.isSignedIn = (user != nil)
            if let uid = user?.uid {
                self.fetchRole(for: uid)
            } else {
                self.role = nil
            }
        }
    }

    deinit {
        if let authListener {
            Auth.auth().removeStateDidChangeListener(authListener)
        }
    }

   
    func signIn(email: String, password: String) {
        errorMessage = nil
        infoMessage = nil
        isBusy = true

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self else { return }
            self.isBusy = false

            if let error = error as NSError? {
                switch AuthErrorCode(rawValue: error.code) {
                case .wrongPassword:
                    self.errorMessage = "Incorrect password. Please try again."
                case .invalidEmail:
                    self.errorMessage = "Invalid email format."
                case .userNotFound:
                    self.errorMessage = "No account found with this email."
                default:
                    self.errorMessage = error.localizedDescription
                }
            } else if let uid = result?.user.uid {
                self.fetchRole(for: uid)
            }
        }
    }


    func resetPassword(email: String) {
        errorMessage = nil
        infoMessage = nil

        let cleanEmail = email.trimmingCharacters(in: .whitespaces)
        guard !cleanEmail.isEmpty else {
            errorMessage = "Please enter your email first."
            return
        }

        Auth.auth().sendPasswordReset(withEmail: cleanEmail) { [weak self] error in
            guard let self else { return }

            if let error = error as NSError? {
                switch AuthErrorCode(rawValue: error.code) {
                case .invalidEmail:
                    self.errorMessage = "Invalid email address."
                case .userNotFound:
                    self.errorMessage = "No account found for this email."
                default:
                    self.errorMessage = error.localizedDescription
                }
            } else {
                self.infoMessage = "Password reset link sent to \(cleanEmail)."
            }
        }
    }

    

    func signUp(email: String, password: String) {
        errorMessage = nil
        infoMessage = nil
        isBusy = true

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self else { return }
            self.isBusy = false

            if let error = error as NSError? {
                switch AuthErrorCode(rawValue: error.code) {
                case .emailAlreadyInUse:
                    self.errorMessage = "Email already in use. Try logging in instead."
                case .invalidEmail:
                    self.errorMessage = "Invalid email format."
                case .weakPassword:
                    self.errorMessage = "Password must be at least 6 characters."
                default:
                    self.errorMessage = error.localizedDescription
                }
                return
            }

            guard let uid = result?.user.uid else { return }

            let userData: [String: Any] = [
                "email": email,
                "role": "student",
                "createdAt": FieldValue.serverTimestamp()
            ]

            self.db.collection("Users").document(uid).setData(userData, merge: true) { _ in
                self.fetchRole(for: uid)
            }
        }
    }


    func signOut() {
        do {
            try Auth.auth().signOut()
            isSignedIn = false
            role = nil
            infoMessage = nil
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }


    private func fetchRole(for uid: String) {
        db.collection("Users").document(uid).getDocument { [weak self] snap, error in
            guard let self else { return }

            if let error {
                print("fetchRole error:", error.localizedDescription)
            }

            let data = snap?.data()
            let fetchedRole = data?["role"] as? String ?? "student"

            DispatchQueue.main.async {
                self.role = fetchedRole
            }
        }
    }
    
    func changePassword(currentPassword: String, newPassword: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            let error = NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user is signed in."])
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }

        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)

        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            user.updatePassword(to: newPassword) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
        }
    }

}

