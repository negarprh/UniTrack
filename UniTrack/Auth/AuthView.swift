//
//  AuthView.swift
//  UniTrack
//
//  Created by Negar Pirasteh on 2025-11-13.
//

import SwiftUI

struct AuthView: View {
    @ObservedObject var vm: AuthViewModel

    @State private var mode = 0
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false

    
    @State private var showResetAlert = false
    @State private var resetText = ""

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.blue.opacity(0.25), .purple.opacity(0.25)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 22) {
                VStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.25))
                            .frame(width: 84, height: 84)
                        Image(systemName: "graduationcap.fill")
                            .font(.system(size: 40, weight: .semibold))
                            .foregroundStyle(.white)
                    }

                    Text("UniTrack")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text(mode == 0 ? "Sign in to continue" : "Create your account")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                }
                .padding(.top, 6)

                VStack(alignment: .leading, spacing: 14) {
                    Picker("", selection: $mode) {
                        Text("Sign In").tag(0)
                        Text("Sign Up").tag(1)
                    }
                    .pickerStyle(.segmented)

                    HStack(spacing: 10) {
                        Image(systemName: "envelope.fill")
                            .foregroundStyle(.secondary)
                        TextField("Email", text: $email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                    }
                    .modifier(FieldStyle())

                    HStack(spacing: 10) {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(.secondary)
                        if showPassword {
                            TextField("Password (min 6)", text: $password)
                        } else {
                            SecureField("Password (min 6)", text: $password)
                        }
                        Button { showPassword.toggle() } label: {
                            Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .modifier(FieldStyle())

                    if mode == 0 {
                        HStack {
                            Spacer()
                            Button("Forgot password?") {
                                vm.resetPassword(email: email)
                            }
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.blue)
                        }
                    }

                    Button {
                        submit()
                    } label: {
                        Text(mode == 0 ? "Sign In" : "Create Account")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .contentShape(Rectangle())
                    }
                    .background(
                        .blue,
                        in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                    )
                    .foregroundStyle(.white)
                    .shadow(color: .blue.opacity(0.25), radius: 6, y: 3)
                    .disabled(!isValid || vm.isBusy)
                    .opacity((!isValid || vm.isBusy) ? 0.7 : 1)

                    if vm.isBusy {
                        HStack(spacing: 8) {
                            ProgressView()
                            Text("Working…")
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 4)
                    }

                    if let error = vm.errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(error)
                                .font(.footnote)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 8)
                    }

                    if let info = vm.infoMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(info)
                                .font(.footnote)
                                .foregroundColor(.green)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 8)
                    }
                }
                .padding(20)
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(.white.opacity(0.35), lineWidth: 0.5)
                )
                .padding(.horizontal, 22)

                Spacer(minLength: 0)
            }
            .padding(.top, 40)
            .onChange(of: vm.infoMessage) { _, msg in
                guard let msg else { return }
                resetText = msg
                showResetAlert = true
            }
            .onChange(of: vm.errorMessage) { _, msg in
                guard let msg else { return }
                resetText = msg
                showResetAlert = true
            }
            .alert("Message", isPresented: $showResetAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(resetText)
            }
        }
    }

    private var isValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty && password.count >= 6
    }

    private func submit() {
        let e = email.trimmingCharacters(in: .whitespaces)
        let p = password

        if mode == 0 {
            vm.signIn(email: e, password: p)
        } else {
            vm.signUp(email: e, password: p)
        }
    }
}

// Reusable input style
private struct FieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(
                .thinMaterial,
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(.secondary.opacity(0.25), lineWidth: 1)
            )
    }
}
