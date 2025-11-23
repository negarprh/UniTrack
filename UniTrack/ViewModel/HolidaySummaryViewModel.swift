//
//  HolidaySummaryViewModel.swift
//  UniTrack
//
//  Created by Negar Pirasteh on 2025-11-23.
//

import Foundation

final class HolidaySummaryViewModel: ObservableObject {
    @Published var holidays: [Holiday] = []
    @Published var isLoading = false
    @Published var hasLoaded = false

    private let service = HolidayService()

    func load() {
        guard !hasLoaded else { return }
        hasLoaded = true
        isLoading = true
        service.fetchNextHolidays { [weak self] holidays in
            self?.holidays = holidays
            self?.isLoading = false
        }
    }
}
