//
//  Cal.swift
//  SchoolDay
//
//  Created by Steve Spencer on 10/17/16.
//  Copyright © 2016 Steve Spencer. All rights reserved.
//

import Foundation

fileprivate func lines(fromResource: String, ofType: String) -> [String]? {

    guard let path = Bundle.main.path(forResource: fromResource, ofType: ofType) else {
        return nil
    }

    do {
        let content = try String(contentsOfFile: path, encoding: .utf8)
        return content.components(separatedBy: "\n")
    } catch {
        return nil
    }
}

struct Day {
    let regularPeriods: [String:[String]] = [
        "A": ["1", "3", "5", "7"],
        "B": ["2", "4", "6", "X"],
        "C": ["3", "5", "7", "1"],
        "D": ["4", "6", "2", "X"],
        "E": ["5", "7", "1", "3"],
        "F": ["6", "2", "4", "X"],
        "G": ["7", "1", "3", "5"],
        "H": ["2", "4", "6"] // LATE START
    ]

    let allPeriods: [String] = ["1", "2", "3", "4", "5", "6", "7"]
    let testPeriods: [String] = ["T"]

    let regularSchedule: [String] = ["1", "2", "L", "3", "4"]
    //let regularTimes: [String] = ["0800-0925", "0935-1105", "1105-1135", "1140-1305", "1315-1440"]
    let regularTimes: [String] = ["8:00am", "9:35am", "11:05am", "11:40am", "1:15pm"]
    let regularLunch = 2

    let massSchedule: [String] = ["1", "M", "L", "2", "3"]
    //let massTimes: [String] = ["0800-0925", "0935-1105", "1105-1135", "1140-1305", "1315-1440"]
    let massTimes: [String] = ["8:00am", "9:35am", "11:05am", "11:40am", "1:15pm"]
    let massLunch = 2

    let lateSchedule: [String] = ["1", "L", "2", "3"]
    //let lateTimes: [String] = ["0935-1105", "1105-1135", "1140-1305", "1315-1440"]
    let lateTimes: [String] = ["9:35am", "11:05am", "11:40am", "1:15pm"]
    let lateLunch = 1

    let fullSchedule: [String] = ["1", "2", "3", "4", "L", "5", "6", "7"]
    //let fullTimes: [String] = ["0800-0847", "0852-0944", "0954-1041", "1046-1133", "1133-1203", "1208-1255", "1300-1347", "0152-1440"]
    let fullTimes: [String] = ["8:00m", "8:52am", "9:54am", "10:46am", "11:33am", "12:08pm", "1:00pm", "1:52pm"]
    let fullLunch = 4

    let testSchedule: [String] = ["T"]
    let testTimes: [String] = ["8:00am"]
    let testLunch = -1

    let title: String
    let rotation: [String]
    let schedule: [String]
    let times: [String]
    let lunch: Int

    init?(rotation: String) {
        var periods: [String]

        if let p = regularPeriods[rotation] {
            periods = p
        } else {
            switch(rotation) {
            case let x where x.hasPrefix("Special") || x.hasPrefix("Full") || x.hasPrefix("1 thru 7"):
                periods = allPeriods
            case let x where x.hasPrefix("Tesing"):
                periods = testPeriods
            case let x where x.hasPrefix("Late Start-"):
                let p = x.substring(from:x.range(of: "-")!.upperBound)
                periods = p.components(separatedBy: "-")
            default:
                // all this to strip leading "*"
                var r = rotation
                if r[r.startIndex] == "*" {
                    r = r.substring(from: r.index(r.startIndex, offsetBy: 1))
                }

                periods = r.components(separatedBy: "-")
            }
        }

        guard periods.count == 1 || (periods.count >= 3 && periods.count <= 7) else {
            return nil
        }

        switch(periods.count) {
        case 1:
            title = "Testing Day"
            schedule = testSchedule
            times = testTimes
            lunch = testLunch

        case 3:
            title = "Late Start"
            schedule = lateSchedule
            times = lateTimes
            lunch = lateLunch
        case 7:
            title = "Full Schedule"
            schedule = fullSchedule
            times = fullTimes
            lunch = fullLunch
        default:
            // find class with longest string length (from observed set of ['1', '2', '3', '4', '5', '6', '7', 'Mass', 'CD'])
            // if strlen == 1, regular schedule, otherwise mass schedule
            var regular = false
            if let max = periods.max(by: {$1.characters.count > $0.characters.count}) {
                regular = (max.characters.count == 1)
            }

            if regular {
                if rotation.characters.count == 1 {
                    title = "Regular Schedule (" + rotation + ")"
                } else {
                    title = "Regular Schedule"
                }
                schedule = regularSchedule
                times = regularTimes
                lunch = regularLunch
            } else {
                title = "Mass/Assembly Schedule"
                schedule = massSchedule
                times = massTimes
                lunch = massLunch
            }
        }

        self.rotation = periods
    }

    internal func detail(period: Int, classes: [String:String]) -> (String,String)? {
        guard period < schedule.count else {
            return nil
        }

        //let time = times[period]
        let sch = times[period] // 1-7, M, L

        var clz = ""

        if period == lunch {
            clz = "Lunch"
        } else if period > lunch {
            let r = rotation[period-1]
            if classes[r] != nil {
                clz = classes[r]!
            } else {
                clz = r
            }
        } else {
            let r = rotation[period]
            if classes[r] != nil {
                clz = classes[r]!
            } else {
                clz = r
            }
        }

        if clz == "X" {
            clz = "X-BLOCK (1:40pm Dismissal)"
        } else if clz == "CD" {
            clz = "Career Day"
        } else if clz == "T" {
            clz = "Testing"
        }

        return (sch, clz)//String(format: "%@: %@", sch, clz)

    }

    func description(classes: [String:String]) -> [(String,String)] {
        var details = [(String,String)]()
        for i in 0 ..< schedule.count {
            if let d = detail(period: i, classes: classes) {
                details.append(d)
            }
        }

        //return String(format: "%@\n%@", title, details.joined(separator: "\n"))
    }
}


struct Cal {
    let cal: [String:[String]]

    init?(fromResource: String, ofType: String) {
        guard let lines = lines(fromResource: fromResource, ofType: ofType) else {
            return nil
        }

        var summary = "", dtstart = ""
        var map = [String:[String]]()

        for line in lines {
            switch(line) {
            case let x where x.hasPrefix("DTSTART;VALUE=DATE:"):
                dtstart = x.substring(from:x.range(of: ":")!.upperBound)
            case let x where x.hasPrefix("SUMMARY:"):
                summary = x.substring(from:x.range(of: ":")!.upperBound)
            case let x where x == "END:VEVENT":
                if dtstart.characters.count > 0 && summary.characters.count > 0 {

                    //if var s = map[dtstart] {
                    if map.index(forKey:dtstart) != nil {
                        map[dtstart]!.append(summary)// summary + "|" + s

                    } else {
                        map[dtstart] = [summary]
                    }
                }
                summary = ""
                dtstart = ""
            default:
                break
            }
        }

        // Calendar has holes in it (weekends, holidays, etc)
        // Fill those holes, adding empty (string) events
        let keys = map.keys.sorted()
        guard keys.count > 0 else {
            return nil
        }

        guard let dateRange = DayWalker(startString: keys.first!, stopString: keys.last!) else {
            return nil
        }

        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd"
        for d in dateRange {
            let s = df.string(from: d)
            if map[s] == nil {
                map[s] = []
            }
        }

        self.cal = map
    }

    func events() -> [String:[String]] {
        return cal
    }
    
    // days() returns all of the days in the calendar, sorted without any missing entries between
    // the first and last days.
    func days() -> [String] {
        return cal.keys.sorted()
    }

    // summary(day:) returns the an array of strings, one string for each event of the day.  If the day
    // is valid and there are no events, an empty array is returned.
    func summary(day: String) -> [String]? {
        guard let s = cal[day] else {
            return nil
        }

        return s
    }


    func sum2(day: String) -> Day? {
        guard let events = cal[day] else {
            return nil
        }

        var f = [String]()
        if events.count > 1 {
            f = events.filter { $0[$0.startIndex] == "*" }
            if f.count > 1 {
                f = f.filter {$0.contains("thru")}
            }
        } else {
            f = events
        }

        guard let format = f.first else {
            return nil
        }

        if let d = Day(rotation: format) {
            return d
        }

        return nil
    }
}
