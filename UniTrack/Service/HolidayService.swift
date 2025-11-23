//
//  HolidayService.swift
//  UniTrack
//
//  Created by Negar Pirasteh on 2025-11-23.
//

import Foundation

final class HolidayService {
    private struct APIHoliday: Decodable {
        let date: String
        let localName: String
        let name: String
    }

    func fetchNextHolidays(countryCode: String = "CA", limit: Int = 3, completion: @escaping ([Holiday]) -> Void) {
        guard let url = URL(string: "https://date.nager.at/api/v3/NextPublicHolidays/\(countryCode)") else {
            completion([])
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data else {
                DispatchQueue.main.async { completion([]) }
                return
            }

            let decoder = JSONDecoder()
            guard let apiHolidays = try? decoder.decode([APIHoliday].self, from: data) else {
                DispatchQueue.main.async { completion([]) }
                return
            }

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.locale = Locale(identifier: "en_CA")

            let mapped: [Holiday] = apiHolidays.compactMap { api in
                guard let d = formatter.date(from: api.date) else { return nil }
                return Holiday(name: api.name, localName: api.localName, date: d)
            }

            let result = Array(mapped.prefix(limit))

            DispatchQueue.main.async {
                completion(result)
            }
        }.resume()
    }
}
