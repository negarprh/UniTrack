//
//  CourseListView.swift
//  UniTrack
//
//  Created by Naomi on 2025-11-11.
//

import SwiftUI

struct CourseListView: View {
    @StateObject private var viewModel = CourseViewModel()
    @State private var addCourse = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.courses.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        Text("No courses yet")
                            .font(.headline)
                        Text("Tap the + button to add your first course.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.courses) { course in
                            NavigationLink {
                                CourseDetailView(course: course) { updated in
                                    viewModel.updateCourse(updated)
                                }
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(course.title)
                                        .font(.headline)

                                    Text("Teacher: \(course.teacherId)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .onDelete(perform: viewModel.deleteCourse)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("My Courses")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        addCourse = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $addCourse) {
                CourseFormView { title, teacherId in
                    viewModel.addCourse(title: title, teacherId: teacherId)
                }
            }
        }
    }
}
