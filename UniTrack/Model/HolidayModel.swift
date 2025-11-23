//
//  Holiday.swift
//  UniTrack
//
//  Created by Negar Pirasteh on 2025-11-23.
//

import Foundation

struct Holiday: Identifiable {
    let id = UUID()
    let name: String
    let localName: String
    let date: Date

    var formattedDate: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f.string(from: date)
    }
}
