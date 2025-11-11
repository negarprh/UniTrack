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
  @Published var role: String?                 // "student" | "teacher"
  @Published var isBusy = false
  @Published var errorMessage: String?
    @Published var infoMessage: String?


  private let db = Firestore.firestore()
  var email: String? { Auth.auth().currentUser?.email }

  init() {
    _ = Auth.auth().addStateDidChangeListener { [weak self] _, _ in
      self?.isSignedIn = Auth.auth().currentUser != nil
      self?.fetchRole()
    }
  }

    func signIn(email: String, password: String) {
        errorMessage = nil
        isBusy = true
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
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
            } else {
                self.fetchRole()
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
        if let error = error as NSError? {
          switch AuthErrorCode(rawValue: error.code) {
          case .invalidEmail:
            self?.errorMessage = "Invalid email address."
          case .userNotFound:
            self?.errorMessage = "No account found for this email."
          default:
            self?.errorMessage = error.localizedDescription
          }
        } else {
          self?.infoMessage = "Password reset link sent to \(cleanEmail)."
        }
      }
    }


    func signUp(email: String, password: String, role: String) {
        errorMessage = nil
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
            self.db.collection("Users").document(uid).setData([
                "email": email,
                "role": role,
                "createdAt": FieldValue.serverTimestamp()
            ], merge: true) { _ in
                self.fetchRole()
            }
        }
    }



  func signOut() { try? Auth.auth().signOut(); role = nil }

  private func fetchRole() {
    guard let uid = Auth.auth().currentUser?.uid else { role = nil; return }
    db.collection("Users").document(uid).getDocument { [weak self] snap, _ in
      self?.role = snap?.data()?["role"] as? String
    }
  }
}

