import Foundation

struct ScheduleEvent: Identifiable, Hashable {
    let id: UUID
    let title: String
    let timeText: String
    let occasion: String

    init(
        id: UUID = UUID(),
        title: String,
        timeText: String,
        occasion: String
    ) {
        self.id = id
        self.title = title
        self.timeText = timeText
        self.occasion = occasion
    }
}//
//  ScheduleEvent.swift
//  AREN
//
//  Created by Ayusman sahu on 10/04/26.
//

