//
//  StudentHomeView.swift
//  UniTrack
//
//  Created by Negar Pirasteh on 2025-11-11.
//
import SwiftUI
import FirebaseAuth

struct StudentHomeView: View { @ObservedObject var vm: AuthViewModel
  var body: some View { VStack{ Text("Student").font(.title); Button("Sign Out"){ vm.signOut() } } } }
