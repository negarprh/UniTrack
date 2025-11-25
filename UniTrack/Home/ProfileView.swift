//
//  ProfileView.swift
//  UniTrack
//
//  Created by Negar Pirasteh on 2025-11-13.
//


import SwiftUI

struct ProfileView: View {
    @ObservedObject var vm: AuthViewModel

    @AppStorage("focusTotalSeconds") private var totalFocusedSeconds: Int = 0
    @AppStorage("focusLastUsed") private var lastUsedTimestamp: Double = 0

    @State private var showChangePassword = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.blue.opacity(0.18), .purple.opacity(0.25)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    headerSection

                    // Only students see study stats
                    if !isTeacher {
                        studyStatsCard
                    }

                    accountCard
                    appCard
                    signOutButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showChangePassword) {
            ChangePasswordSheet(vm: vm)
        }
    }

    

    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 110, height: 110)
                    .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 4)

                Text(initials)
                    .font(.system(size: 44, weight: .semibold, design: .rounded))
                    .foregroundStyle(.blue)
            }

            VStack(spacing: 4) {
                Text(displayName)
                    .font(.title2.weight(.semibold))

                if let email = vm.email {
                    Text(email)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Text(roleLabel)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(roleColor.opacity(0.18))
                )
                .overlay(
                    Capsule()
                        .stroke(roleColor.opacity(0.7), lineWidth: 0.7)
                )
        }
        .frame(maxWidth: .infinity)
    }

    private var studyStatsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Study Summary")
                .font(.headline)

            HStack(spacing: 16) {
                statItem(
                    icon: "clock.arrow.circlepath",
                    title: "Total Focus Time",
                    value: totalFocusFormatted
                )

                statItem(
                    icon: "calendar",
                    title: "Last Session",
                    value: lastSessionText
                )
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground).opacity(0.96))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.secondary.opacity(0.12), lineWidth: 0.5)
        )
    }

    private var accountCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Account")
                .font(.headline)

            HStack {
                Image(systemName: "envelope")
                    .foregroundStyle(.blue)
                Text(vm.email ?? "No email")
                    .font(.subheadline)
                Spacer()
            }

            HStack {
                Image(systemName: "person.text.rectangle")
                    .foregroundStyle(.purple)
                Text(roleLabel)
                    .font(.subheadline)
                Spacer()
            }

            Button {
                showChangePassword = true
            } label: {
                HStack {
                    Image(systemName: "key.fill")
                        .foregroundStyle(.orange)
                    Text("Change password")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundStyle(.tertiary)
                }
                .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground).opacity(0.96))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.secondary.opacity(0.12), lineWidth: 0.5)
        )
    }

    private var appCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("App")
                .font(.headline)

            HStack {
                Image(systemName: "graduationcap.fill")
                    .foregroundStyle(.blue)
                VStack(alignment: .leading, spacing: 2) {
                    Text("UniTrack")
                        .font(.subheadline.weight(.semibold))
                    Text("Role-based planner for students and teachers")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            Text("Track courses, assignments, and focused study sessions in one place.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.top, 2)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground).opacity(0.96))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.secondary.opacity(0.12), lineWidth: 0.5)
        )
    }

    private var signOutButton: some View {
        Button(role: .destructive) {
            vm.signOut()
        } label: {
            Label("Sign out", systemImage: "arrow.turn.down.left")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .buttonStyle(.borderedProminent)
        .tint(.red)
        .padding(.top, 8)
    }

    // MARK: - Helpers

    private func statItem(icon: String, title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(.blue)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(value)
                .font(.subheadline.weight(.semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var isTeacher: Bool {
        vm.role == "teacher"
    }

    private var roleLabel: String {
        isTeacher ? "Teacher" : "Student"
    }

    private var roleColor: Color {
        isTeacher ? .orange : .green
    }

    private var displayName: String {
        if let email = vm.email, let namePart = email.split(separator: "@").first {
            let s = String(namePart)
            if s.count > 1 {
                return s.prefix(1).uppercased() + s.dropFirst()
            }
            return s.uppercased()
        }
        return "User"
    }

    private var initials: String {
        if let email = vm.email,
           let namePart = email.split(separator: "@").first,
           let first = namePart.first {
            return String(first).uppercased()
        }
        return "U"
    }

    private var totalFocusFormatted: String {
        if totalFocusedSeconds == 0 { return "No focus yet" }
        let h = totalFocusedSeconds / 3600
        let m = (totalFocusedSeconds % 3600) / 60
        if h > 0 { return "\(h)h \(m)m" }
        return "\(m)m"
    }

    private var lastSessionText: String {
        guard lastUsedTimestamp > 0 else { return "Never" }
        let date = Date(timeIntervalSince1970: lastUsedTimestamp)
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: date)
    }
}

struct ChangePasswordSheet: View {
    @ObservedObject var vm: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isBusy = false
    @State private var errorMessage: String?
    @State private var infoMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Current password") {
                    SecureField("Current password", text: $currentPassword)
                }

                Section("New password") {
                    SecureField("New password (min 6)", text: $newPassword)
                    SecureField("Confirm new password", text: $confirmPassword)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundColor(.red)
                }

                if let infoMessage {
                    Text(infoMessage)
                        .font(.footnote)
                        .foregroundColor(.green)
                }
            }
            .navigationTitle("Change password")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        submit()
                    }
                    .disabled(!canSubmit || isBusy)
                }
            }
        }
    }

    private var canSubmit: Bool {
        !currentPassword.isEmpty &&
        newPassword.count >= 6 &&
        newPassword == confirmPassword
    }

    private func submit() {
        errorMessage = nil
        infoMessage = nil
        isBusy = true

        vm.changePassword(currentPassword: currentPassword, newPassword: newPassword) { result in
            isBusy = false
            switch result {
            case .success:
                infoMessage = "Password updated successfully."
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    dismiss()
                }
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}
