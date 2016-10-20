//
//  Cal.swift
//  SchoolDay
//
//  Created by Steve Spencer on 10/17/16.
//  Copyright © 2016 Steve Spencer. All rights reserved.
//

import Foundation

struct Schedule {
    let date: String
    let title: String
    let periods: [String]
    let times: [String]
    let dismissal: String
}

struct Cal {

    let cal: [Schedule]

    init(jsonResource: String) {

        let calendarURL = Bundle.main.url(forResource: jsonResource, withExtension: "json")
        do {
            let data = try Data.init(contentsOf: calendarURL!)
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)

            var schedules = [Schedule]()

            if let scheduleItems = json as? [[String: Any ]] {

                for item in scheduleItems {

                    var date = ""
                    var title = ""
                    var dismissal = ""
                    var periods = [String]()
                    var times = [String]()

                    if let s = item["date"] as? String {
                        date = s
                    }

                    if let s = item["title"] as? String {
                        title = s
                    }

                    if let s = item["periods"] as? [ String ] {
                        periods = s
                    }

                    if let s = item["times"] as? [ String ] {
                        times = s
                    }

                    if let s = item["dismissal"] as? String {
                        dismissal = s
                    }

                    let schedule = Schedule(date: date, title: title, periods: periods, times: times, dismissal: dismissal)
                    schedules.append(schedule)
                }
            }

            self.cal = schedules

        } catch {
            print("error serializing JSON: \(error)")
            self.cal = [Schedule]()
        }
    }

    func count() -> Int {
        return cal.count
    }

    func schedule(index: Int) -> Schedule? {
        guard index >= 0 && index < cal.count else {
            return nil
        }

        return cal[index]
    }

    func index(date: String) -> Int? {
        var i = 0
        for s in cal {
            if date == s.date {
                return i
            }
            i+=1
        }
        
        return nil
    }
}
