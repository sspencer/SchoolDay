//
//  Cal.swift
//  SchoolDay
//
//  Created by Steve Spencer on 10/17/16.
//  Copyright © 2016 Steve Spencer. All rights reserved.
//

import Foundation

typealias JSONDictionary = [String:Any]

struct Day {
    let date: String
    let title: String
    let periods: [String]
    let times: [String]
    let dismissal: String
    let weekend: Bool
}

extension Day {
    init?(json:JSONDictionary) {
        guard
            let date = json["date"] as? String,
            let title = json["title"] as? String,
            let periods = json["periods"] as? [String],
            let times = json["times"] as? [ String ],
            let dismissal = json["dismissal"] as? String
            else { return nil }

        self.date = date
        self.title = title
        self.periods = periods
        self.times = times
        self.dismissal = dismissal

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let calendar = Calendar(identifier: .gregorian)
        if let dt = dateFormatter.date(from: date) {
            self.weekend = calendar.isDateInWeekend(dt)
        } else {
            self.weekend = false
        }
    }
}


struct Cal {

    let days: [Day]

    init(jsonResource: String) {

        let calendarURL = Bundle.main.url(forResource: jsonResource, withExtension: "json")
        do {
            let data = try Data.init(contentsOf: calendarURL!)
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)

            var schedule = [Day]()

            if let scheduleItems = json as? [JSONDictionary] {
                for item in scheduleItems {
                    if let day = Day(json:item) {
                        schedule.append(day)
                    }
                }
            }

            self.days = schedule

        } catch {
            print("error serializing JSON: \(error)")
            self.days = [Day]()
        }
    }

    func count() -> Int {
        return days.count
    }

    func day(index: Int) -> Day? {
        guard index >= 0 && index < days.count else {
            return nil
        }

        return days[index]
    }

    func index(date: String) -> Int? {
        var i = 0
        for s in days {
            if date == s.date {
                return i
            }
            i+=1
        }
        
        return nil
    }
}
