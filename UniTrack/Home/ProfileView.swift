//
//  ProfileView.swift
//  UniTrack
//
//  Created by Negar Pirasteh on 2025-11-13.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var vm: AuthViewModel

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)

            Text(vm.role == "teacher" ? "Teacher" : "Student")
                .font(.title2)
                .bold()

            Spacer()

            Button(role: .destructive) {
                vm.signOut()
            } label: {
                Label("Sign out", systemImage: "arrow.turn.down.left")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
        .padding()
        .navigationTitle("Profile")
    }
}
