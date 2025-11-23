//
//  HolidaySummaryCard.swift
//  UniTrack
//
//  Created by Negar Pirasteh on 2025-11-23.
//

import SwiftUI

struct HolidaySummaryCard: View {
    @ObservedObject var vm: HolidaySummaryViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "calendar")
                    .font(.title3)
                    .foregroundStyle(.blue)
                Text("Upcoming Holidays")
                    .font(.headline)
            }

            content
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground).opacity(0.95))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.secondary.opacity(0.12), lineWidth: 0.5)
        )
        .onAppear {
            vm.load()
        }
    }

    @ViewBuilder
    private var content: some View {
        if vm.isLoading {
            HStack(spacing: 8) {
                ProgressView()
                Text("Loading holidays…")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        } else if vm.holidays.isEmpty {
            Text("No upcoming public holidays found.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        } else {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(vm.holidays) { holiday in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(holiday.localName)
                            .font(.subheadline.weight(.semibold))
                        Text(holiday.formattedDate)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        if holiday.localName != holiday.name {
                            Text(holiday.name)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}
