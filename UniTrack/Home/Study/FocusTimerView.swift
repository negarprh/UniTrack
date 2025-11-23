//
//  FocusTimerView.swift
//  UniTrack
//
//  Created by Negar Pirasteh on 2025-11-13.
//
import SwiftUI

struct FocusTimerView: View {

    @AppStorage("focusTotalSeconds") private var totalFocusedSeconds: Int = 0
    @AppStorage("focusLastUsed") private var lastUsedTimestamp: Double = 0
    @AppStorage("focusPreferredMode") private var preferredModeRaw: String = SessionType.focus.rawValue

    enum SessionType: String, CaseIterable {
        case focus = "Focus"
        case shortBreak = "Short Break"
        case longBreak = "Long Break"

        var title: String {
            switch self {
            case .focus: return "Focus Session"
            case .shortBreak: return "Short Break"
            case .longBreak: return "Long Break"
            }
        }

        var subtitle: String {
            switch self {
            case .focus: return "Deep work, no distractions."
            case .shortBreak: return "Quick reset."
            case .longBreak: return "Recharge."
            }
        }

        var duration: Int {
            switch self {
            case .focus: return 25 * 60
            case .shortBreak: return 5 * 60
            case .longBreak: return 15 * 60
            }
        }

        var accentColor: Color {
            switch self {
            case .focus: return .green
            case .shortBreak: return .orange
            case .longBreak: return .purple
            }
        }

        var emoji: String {
            switch self {
            case .focus: return "🎯"
            case .shortBreak: return "☕️"
            case .longBreak: return "🌿"
            }
        }
    }

    @State private var currentMode: SessionType = .focus
    @State private var totalSeconds: Int = SessionType.focus.duration
    @State private var remaining: Int = SessionType.focus.duration
    @State private var running: Bool = false
    @State private var sessionElapsedSeconds: Int = 0

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            LinearGradient(colors: [.blue.opacity(0.15), .purple.opacity(0.25)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Stay on track")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text("Pomodoro Focus")
                            .font(.largeTitle.bold())

                        Text("Use 25-minute blocks with structured breaks.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 8) {
                        ForEach(SessionType.allCases, id: \.self) { mode in
                            Button {
                                changeMode(mode)
                            } label: {
                                HStack(spacing: 6) {
                                    Text(mode.emoji)
                                    Text(mode == .focus ? "Focus" : mode == .shortBreak ? "Short" : "Long")
                                        .font(.subheadline.weight(.semibold))
                                }
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(mode == currentMode ? mode.accentColor.opacity(0.18) : Color(.systemBackground).opacity(0.7))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(mode == currentMode ? mode.accentColor.opacity(0.7) : Color.secondary.opacity(0.15), lineWidth: 1)
                                )
                            }
                            .disabled(running)
                            .buttonStyle(.plain)
                        }
                    }

                    VStack(spacing: 18) {
                        Text(currentMode.title)
                            .font(.headline)

                        Text(currentMode.subtitle)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        ZStack {
                            Circle()
                                .stroke(.white.opacity(0.25), lineWidth: 16)

                            Circle()
                                .trim(from: 0, to: CGFloat(progress))
                                .stroke(
                                    AngularGradient(gradient: Gradient(colors: [currentMode.accentColor, .blue, currentMode.accentColor]), center: .center),
                                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut(duration: 0.2), value: progress)

                            VStack(spacing: 6) {
                                Text(formattedTime)
                                    .font(.system(size: 42, weight: .bold, design: .monospaced))

                                Text(currentMode == .focus ? "Focus" : "Break")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(width: 220, height: 220)

                        HStack(spacing: 16) {
                            Button {
                                toggleTimer()
                            } label: {
                                Label(running ? "Pause" : "Start", systemImage: running ? "pause.fill" : "play.fill")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(currentMode.accentColor)

                            Button {
                                endSession(true)
                            } label: {
                                Label("End Session", systemImage: "checkmark.circle.fill")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                            }
                            .buttonStyle(.bordered)
                        }

                        Button(role: .destructive) {
                            endSession(false)
                        } label: {
                            Text("Reset Without Saving")
                                .font(.footnote.weight(.semibold))
                        }
                    }
                    .padding(20)
                    .background(RoundedRectangle(cornerRadius: 24).fill(.ultraThinMaterial))
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(.white.opacity(0.25), lineWidth: 0.5))

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Study Stats")
                            .font(.headline)

                        HStack(spacing: 16) {
                            statItem(icon: "clock.arrow.circlepath", title: "Total Focus Time", value: totalFocusFormatted)
                            statItem(icon: "calendar", title: "Last Session", value: lastSessionText)
                        }
                    }
                    .padding(20)
                    .background(RoundedRectangle(cornerRadius: 24).fill(Color(.systemBackground).opacity(0.9)))
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.secondary.opacity(0.1), lineWidth: 0.5))
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            configure(SessionType(rawValue: preferredModeRaw) ?? .focus)
        }
        .onReceive(timer) { _ in
            tick()
        }
    }

    private func statItem(icon: String, title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(.blue)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(value)
                .font(.subheadline.weight(.semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func configure(_ mode: SessionType) {
        currentMode = mode
        preferredModeRaw = mode.rawValue
        totalSeconds = mode.duration
        remaining = mode.duration
        sessionElapsedSeconds = 0
        running = false
    }

    private func changeMode(_ mode: SessionType) {
        guard !running else { return }
        configure(mode)
    }

    private func toggleTimer() {
        if running {
            running = false
        } else {
            if remaining == 0 {
                remaining = totalSeconds
                sessionElapsedSeconds = 0
            }
            running = true
        }
    }

    private func tick() {
        guard running, remaining > 0 else { return }
        remaining -= 1
        if currentMode == .focus {
            sessionElapsedSeconds += 1
        }
        if remaining == 0 {
            endSession(true)
        }
    }

    private func endSession(_ log: Bool) {
        running = false
        if log, currentMode == .focus, sessionElapsedSeconds > 0 {
            totalFocusedSeconds += sessionElapsedSeconds
            lastUsedTimestamp = Date().timeIntervalSince1970
        }
        remaining = totalSeconds
        sessionElapsedSeconds = 0
    }

    private var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return 1 - Double(remaining) / Double(totalSeconds)
    }

    private var formattedTime: String {
        String(format: "%02d:%02d", remaining / 60, remaining % 60)
    }

    private var totalFocusFormatted: String {
        if totalFocusedSeconds == 0 { return "No focus yet" }
        let h = totalFocusedSeconds / 3600
        let m = (totalFocusedSeconds % 3600) / 60
        if h > 0 { return "\(h)h \(m)m" }
        return "\(m)m"
    }

    private var lastSessionText: String {
        guard lastUsedTimestamp > 0 else { return "Never" }
        let date = Date(timeIntervalSince1970: lastUsedTimestamp)
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: date)
    }
}
