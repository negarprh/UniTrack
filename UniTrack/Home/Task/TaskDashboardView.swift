//
//  TaskDashboardView.swift
//  UniTrack
//
//  Created by Negar Pirasteh on 2025-11-13.

import SwiftUI

struct TaskDashboardView: View {
    let isTeacher: Bool

    @StateObject private var viewModel = TaskViewModel()
    @State private var selectedDate = Date()
    @State private var showingForm = false
    @State private var editingTask: Task? = nil

    private var sortedTasks: [Task] {
        viewModel.tasks.sorted { $0.dueDate < $1.dueDate }
    }

    private var tasksForSelectedDay: [Task] {
        let cal = Calendar.current
        return sortedTasks.filter { cal.isDate($0.dueDate, inSameDayAs: selectedDate) }
    }

    private var roleLabel: String {
        isTeacher ? "Teacher view" : "Student view"
    }

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
                    VStack(spacing: 20) {
                        headerCard
                        calendarCard
                        tasksForDaySection
                        allUpcomingSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Assignments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if isTeacher {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            editingTask = nil
                            showingForm = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingForm) {
                TaskFormView(
                    existingTask: editingTask,
                    isTeacher: isTeacher
                )
            }
        }
    }

    private var headerCard: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Assignments overview")
                    .font(.headline)

                Text(isTeacher
                     ? "Create, edit and track course assignments."
                     : "See what’s due and check off what you finish.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(roleLabel)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule().fill(Color.white.opacity(0.14))
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                    )
                    .padding(.top, 4)
            }

            Spacer()

            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 60, height: 60)
                Image(systemName: "checklist")
                    .font(.title2)
                    .foregroundStyle(.blue)
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

    private var calendarCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Calendar")
                        .font(.headline)
                    Text("Tap a day to see what’s due.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(selectedDate, format: .dateTime.month().year())
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            MiniAssignmentCalendar(
                tasks: sortedTasks,
                selectedDate: $selectedDate
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(.systemBackground).opacity(0.96))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.white.opacity(0.18), lineWidth: 0.6)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
    }

    private var tasksForDaySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Due on \(selectedDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.headline)
                Spacer()
                if !tasksForSelectedDay.isEmpty {
                    Text("\(tasksForSelectedDay.count) item(s)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if tasksForSelectedDay.isEmpty {
                Text("No assignments due this day.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 10) {
                    ForEach(tasksForSelectedDay) { task in
                        assignmentRow(task)
                    }
                }
            }
        }
    }

    private var allUpcomingSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("All upcoming")
                .font(.headline)

            if sortedTasks.isEmpty {
                Text("You don’t have any assignments yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 10) {
                    ForEach(sortedTasks) { task in
                        assignmentRow(task)
                    }
                }
            }
        }
        .padding(.top, 8)
    }


    private func assignmentRow(_ task: Task) -> some View {
        let today = Calendar.current.startOfDay(for: Date())
        let dueDay = Calendar.current.startOfDay(for: task.dueDate)
        let isOverdue = (dueDay < today) && !task.isDone

        return HStack(alignment: .top, spacing: 12) {
            Button {
                viewModel.toggleDone(task)
            } label: {
                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(task.isDone ? .green : (isOverdue ? .red : .secondary))
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(task.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(isOverdue ? .red : .primary)

                    if isOverdue {
                        Text("OVERDUE")
                            .font(.caption2.weight(.bold))
                            .foregroundColor(.red)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color.red.opacity(0.08))
                            )
                    }
                }

                Text(task.courseTitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("Due \(task.dueDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption2)
                    .foregroundStyle(isOverdue ? .red : .secondary)
            }

            Spacer()

            if isTeacher {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground).opacity(0.96))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isOverdue ? Color.red.opacity(0.35) : Color.white.opacity(0.18),
                    lineWidth: 0.7
                )
        )
        .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 2)
        .opacity(task.isDone ? 0.65 : 1)
        .onTapGesture {
            guard isTeacher else { return }
            editingTask = task
            showingForm = true
        }
    }
}


struct MiniAssignmentCalendar: View {
    let tasks: [Task]
    @Binding var selectedDate: Date

    private let calendar = Calendar.current

    private var monthDates: [Date] {
        let components = calendar.dateComponents([.year, .month], from: selectedDate)
        guard let firstOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: firstOfMonth)
        else { return [] }

        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth)
        }
    }

    private func hasTask(on date: Date) -> Bool {
        tasks.contains { calendar.isDate($0.dueDate, inSameDayAs: date) }
    }

    var body: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

        LazyVGrid(columns: columns, spacing: 6) {
            ForEach(calendar.shortWeekdaySymbols, id: \.self) { symbol in
                Text(symbol.uppercased())
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }

            ForEach(monthDates, id: \.self) { date in
                let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                let isToday = calendar.isDateInToday(date)
                let hasDue = hasTask(on: date)

                VStack(spacing: 3) {
                    Text("\(calendar.component(.day, from: date))")
                        .font(.caption)
                        .fontWeight(isSelected ? .bold : .regular)
                        .foregroundStyle(
                            isSelected ? Color.white :
                                (hasDue ? Color.primary : .secondary)
                        )
                        .frame(width: 26, height: 26)
                        .background(
                            Circle()
                                .fill(
                                    isSelected
                                    ? Color.indigo
                                    : (isToday ? Color.indigo.opacity(0.12) : .clear)
                                )
                        )

                    Circle()
                        .fill(hasDue ? Color.indigo : Color.clear)
                        .frame(width: 4, height: 4)
                        .opacity(hasDue ? 1 : 0)
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedDate = date
                }
            }
        }
    }
}
