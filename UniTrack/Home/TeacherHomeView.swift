//
//  TeacherHomeView.swift
//  UniTrack
//
//  Created by Negar Pirasteh on 2025-11-11.
//
import SwiftUI
import FirebaseAuth

struct TeacherHomeView: View { @ObservedObject var vm: AuthViewModel
  var body: some View { VStack{ Text("Teacher").font(.title); Button("Sign Out"){ vm.signOut() } } } }


