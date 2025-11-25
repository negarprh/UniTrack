//
//  DashboardView.swift
//  UniTrack
//
//  Created by Negar Pirasteh on 2025-11-13.
//


import SwiftUI


struct ZenQuote: Codable {
    let q: String
    let a: String
}



struct DashboardView: View {
    @ObservedObject var vm: AuthViewModel
    @State private var showTeacherTimerAlert = false
    @StateObject private var holidayVM = HolidaySummaryViewModel()

    
    @State private var quoteText: String = ""
    @State private var quoteAuthor: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.blue.opacity(0.18), .purple.opacity(0.25)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        overviewCard
                        shortcutsSection
                        apiPlaceholderCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .alert("Student-only feature", isPresented: $showTeacherTimerAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("The focus timer is designed for student study sessions.")
            }
        }
        .onAppear {
            fetchDailyQuote()
        }
    }



    private var isTeacher: Bool {
        vm.role == "teacher"
    }

    private var displayRole: String {
        isTeacher ? "Teacher" : "Student"
    }

    private func fetchDailyQuote() {
        guard let url = URL(string: "https://zenquotes.io/api/today") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard
                let data = data,
                let decoded = try? JSONDecoder().decode([ZenQuote].self, from: data),
                let first = decoded.first
            else { return }

            DispatchQueue.main.async {
                self.quoteText = first.q
                self.quoteAuthor = first.a
            }
        }.resume()
    }



    private var headerSection: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Welcome back")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("UniTrack")
                    .font(.system(size: 32, weight: .bold, design: .rounded))

                Text("\(displayRole) dashboard")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(displayRole)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isTeacher ? Color.orange.opacity(0.15) : Color.green.opacity(0.18))
                )
                .overlay(
                    Capsule()
                        .stroke(isTeacher ? Color.orange.opacity(0.7) : Color.green.opacity(0.7), lineWidth: 0.7)
                )
        }
    }

    private var overviewCard: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Today's Quote")
                    .font(.headline)

               
                if quoteText.isEmpty {
                    Text(isTeacher ? "Thank you for teaching." : "Small wins add up.")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 4)
                } else {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("“\(quoteText)”")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)

                        if !quoteAuthor.isEmpty {
                            Text("- \(quoteAuthor)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.top, 4)
                }
            }

            Spacer()

            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 60, height: 60)
                Image(systemName: isTeacher ? "person.2.fill" : "studentdesk")
                    .font(.title2)
                    .foregroundStyle(isTeacher ? .orange : .blue)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(.white.opacity(0.25), lineWidth: 0.6)
        )
    }

    private var shortcutsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Shortcuts")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            if isTeacher {
                teacherShortcuts
            } else {
                studentShortcuts
            }
        }
    }

    private var studentShortcuts: some View {
        VStack(spacing: 14) {
            NavigationLink {
                TaskDashboardView(isTeacher: false)
            } label: {
                DashboardButton(
                    title: "Assignments",
                    subtitle: "View all upcoming work",
                    systemImage: "checklist",
                    accent: .blue,
                    isPrimary: true
                )
            }

            NavigationLink {
                FocusTimerView()
            } label: {
                DashboardButton(
                    title: "Focus Timer",
                    subtitle: "Pomodoro study sessions",
                    systemImage: "timer",
                    accent: .green,
                    isPrimary: true
                )
            }

            NavigationLink {
                CourseListView(isTeacher: false)
            } label: {
                DashboardButton(
                    title: "Courses",
                    subtitle: "See your course list",
                    systemImage: "book.closed",
                    accent: .indigo,
                    isPrimary: false
                )
            }

            NavigationLink {
                ProfileView(vm: vm)
            } label: {
                DashboardButton(
                    title: "Profile",
                    subtitle: "Account & sign out",
                    systemImage: "person.crop.circle",
                    accent: .purple,
                    isPrimary: false
                )
            }
        }
    }

    private var teacherShortcuts: some View {
        VStack(spacing: 14) {
            NavigationLink {
                CourseListView(isTeacher: true)
            } label: {
                DashboardButton(
                    title: "Courses",
                    subtitle: "Create and manage courses",
                    systemImage: "book.closed",
                    accent: .indigo,
                    isPrimary: true
                )
            }

            NavigationLink {
                TaskDashboardView(isTeacher: true)
            } label: {
                DashboardButton(
                    title: "Assignments",
                    subtitle: "Add and review tasks",
                    systemImage: "square.and.pencil",
                    accent: .blue,
                    isPrimary: true
                )
            }

            Button {
                showTeacherTimerAlert = true
            } label: {
                DashboardButton(
                    title: "Focus Timer",
                    subtitle: "Available for students",
                    systemImage: "timer",
                    accent: .gray,
                    isPrimary: false,
                    isDisabled: true
                )
            }
            .buttonStyle(.plain)

            NavigationLink {
                ProfileView(vm: vm)
            } label: {
                DashboardButton(
                    title: "Profile",
                    subtitle: "Account & sign out",
                    systemImage: "person.crop.circle",
                    accent: .purple,
                    isPrimary: false
                )
            }
        }
    }

    private var apiPlaceholderCard: some View {
        HolidaySummaryCard(vm: holidayVM)
            .padding(.top, 8)
    }
}


struct DashboardButton: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let accent: Color
    let isPrimary: Bool
    var isDisabled: Bool = false

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(accent.opacity(isPrimary ? 0.20 : 0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: systemImage)
                    .font(.title3)
                    .foregroundStyle(accent)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(isDisabled ? .secondary : .primary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.systemBackground).opacity(0.96))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    isDisabled ? Color.secondary.opacity(0.16) : Color.white.opacity(0.18),
                    lineWidth: 0.6
                )
        )
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        .opacity(isDisabled ? 0.7 : 1)
    }
}
