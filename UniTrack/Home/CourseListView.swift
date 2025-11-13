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
            List {
                ForEach(viewModel.courses) { course in
                    Text(course.title)
                        .font(.headline)
                }
                .onDelete(perform: viewModel.deleteCourse)
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

#Preview {
    CourseListView()
}

