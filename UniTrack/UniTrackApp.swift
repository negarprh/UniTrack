//
//  UniTrackApp.swift
//  UniTrack
//
//  Created by Negar Pirasteh on 2025-11-03.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct UniTrackApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  var body: some Scene { WindowGroup { RootView() } }
}

private struct RootView: View {
  @StateObject private var vm = AuthViewModel()
  var body: some View {
    if vm.isSignedIn {
      if vm.role == "teacher" { TeacherHomeView(vm: vm) }
      else { StudentHomeView(vm: vm) }   
    } else {
      AuthView(vm: vm)
    }
  }
}



