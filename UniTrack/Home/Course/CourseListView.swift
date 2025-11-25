//
//  CourseListView.swift
//  UniTrack
//
//  Created by Naomi on 2025-11-11.
//

import SwiftUI

struct CourseListView: View {
    let isTeacher: Bool

    @StateObject private var viewModel = CourseViewModel()
    @State private var addCourse = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.blue.opacity(0.18), .purple.opacity(0.25)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                if viewModel.courses.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            header
                            ForEach(viewModel.courses) { course in
                                NavigationLink {
                                    CourseDetailView(
                                        course: course,
                                        isTeacher: isTeacher,
                                        onSave: { updated in
                                            viewModel.updateCourse(updated)
                                        },
                                        onDelete: { toDelete in
                                            if let id = toDelete.id {
                                                viewModel.deleteCourse(id: id)
                                            }
                                        }
                                    )
                                } label: {
                                    CourseCard(course: course)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("Courses")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if isTeacher {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            addCourse = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $addCourse) {
                CourseFormView { title, sessionDrafts in
                 
                    viewModel.addCourse(
                        title: title,
                        sessionsDrafts: sessionDrafts
                    )
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(isTeacher ? "Manage your classes" : "Your courses")
                .font(.headline)
                .foregroundStyle(.primary)

            Text(isTeacher
                 ? "Tap a course to manage its weekly sessions."
                 : "Tap a course to view its weekly sessions.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "book.closed")
                .font(.system(size: 46))
                .foregroundStyle(.secondary)

            Text("No courses yet")
                .font(.title3.weight(.semibold))

            Text(isTeacher
                 ? "Start by adding a course. You can then add weekly sessions for it."
                 : "Your courses will appear here once your teachers add them.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            if isTeacher {
                Button {
                    addCourse = true
                } label: {
                    Label("Add a course", systemImage: "plus")
                        .font(.headline)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [.blue.opacity(0.18), .purple.opacity(0.25)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
}

struct CourseCard: View {
    let course: Course

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.indigo.opacity(0.18))
                    .frame(width: 46, height: 46)
                Image(systemName: "book.closed.fill")
                    .font(.title3)
                    .foregroundStyle(.indigo)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(course.title)
                    .font(.headline)

                Text("Teacher: \(course.teacherId)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("Tap to manage course info and sessions")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.systemBackground).opacity(0.96))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.16), lineWidth: 0.6)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
    }
}
