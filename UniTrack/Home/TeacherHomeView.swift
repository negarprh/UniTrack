//
//  TeacherHomeView.swift
//  UniTrack
//
//  Created by Negar Pirasteh on 2025-11-11.
//
import SwiftUI
import FirebaseAuth


struct TeacherHomeView: View {
    @ObservedObject var vm: AuthViewModel
    @StateObject private var courseVM = CourseViewModel()
    @State private var showingAddCourse = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
               
                VStack(spacing: 4) {
                    Text("Welcome, Teacher ")
                        .font(.title2)
                        .fontWeight(.semibold)
                    if let email = Auth.auth().currentUser?.email {
                        Text(email)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 10)

                if courseVM.courses.isEmpty {
                    VStack(spacing: 8) {
                        Text("No courses yet").foregroundColor(.secondary)
                        Button("Add a course") {
                            showingAddCourse = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.top, 40)
                } else {
                    List {
                        ForEach(courseVM.courses) { course in
                            NavigationLink {
                                CourseDetailView(course: course) { updated in
                                    courseVM.updateCourse(updated)
                                }
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(course.title)
                                        .font(.headline)
                                    Text("Teacher: \(course.teacherId)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .onDelete(perform: courseVM.deleteCourse)
                    }
                }

                Spacer()
                Button(role: .destructive) {
                    vm.signOut()
                } label: {
                    Text("Sign Out")
                        .font(.callout)
                        .padding(.vertical, 6)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .padding(.bottom, 10)
            }
            .navigationTitle("Teacher Dashboard")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddCourse = true
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCourse) {
                CourseFormView { title, teacherId in
                    courseVM.addCourse(title: title, teacherId: teacherId)
                }
            }
        }
    }
}


