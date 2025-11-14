//
//  FocusTimerView.swift
//  UniTrack
//
//  Created by Negar Pirasteh on 2025-11-13.
//

import SwiftUI

struct FocusTimerView: View {
    @State private var totalSeconds = 25 * 60
    @State private var remaining = 25 * 60
    @State private var running = false

    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 24) {
            Text("Focus Timer")
                .font(.largeTitle)
                .bold()

            Text(timeString)
                .font(.system(size: 48, weight: .bold, design: .monospaced))

            HStack(spacing: 16) {
                Button(running ? "Pause" : "Start") {
                    running.toggle()
                }
                .buttonStyle(.borderedProminent)

                Button("Reset") {
                    running = false
                    remaining = totalSeconds
                }
                .buttonStyle(.bordered)
            }

            Spacer()
        }
        .padding()
        .onReceive(timer) { _ in
            if running && remaining > 0 {
                remaining -= 1
            }
        }
        .navigationTitle("Focus Timer")
    }

    private var timeString: String {
        let minutes = remaining / 60
        let seconds = remaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
