//
//  WelcomeView.swift
//  UniTrack
//
//  Created by Negar Pirasteh on 2025-11-11.
//

// Home/WelcomeView.swift
import SwiftUI
import FirebaseAuth

struct WelcomeView: View {
  @ObservedObject var vm: AuthViewModel
  var body: some View {
    VStack(spacing: 12) {
      Text("Welcome to UniTrack")
        .font(.title)
        .bold()

      Text("Email: \(Auth.auth().currentUser?.email ?? "-")")
        .font(.footnote)
        .foregroundStyle(.secondary)

      Button("Sign Out") {
        vm.signOut()
      }
      .buttonStyle(.borderedProminent)
    }
    .padding()
  }
}
