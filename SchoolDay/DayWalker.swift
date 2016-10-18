//
//  DayWalker.swift
//  SchoolDay
//
//  Created by Steve Spencer on 10/17/16.
//  Copyright © 2016 Steve Spencer. All rights reserved.
//

import Foundation

// Iterate thru all dates inclusively between start and stop:
//
//     guard let dw = DayWalker(startString: "20161030", stopString: "20161102") else { return }
//     for d in dw {
//         print("\(d)")
//     }
//

struct DayWalker: Sequence {
    let start: Date
    let stop: Date

    init(start: Date, stop: Date) {
        self.start = start
        self.stop = stop
    }

    init?(startString: String, stopString: String) {
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd"

        guard let startDate = df.date(from: startString), let stopDate = df.date(from: stopString) else {
            return nil
        }

        self.start = startDate
        self.stop = stopDate
    }

    func makeIterator() -> DayWalkerIterator {
        return DayWalkerIterator(self)
    }
}

struct DayWalkerIterator: IteratorProtocol {
    let df = DateFormatter()
    let stopString: String
    var current: Date
    var stopping = false

    init(_ dayWalker: DayWalker) {
        self.df.dateFormat = "yyyyMMdd" // 20161031
        self.current = dayWalker.start
        self.stopString = df.string(from: dayWalker.stop)

        // cause short circuit if START is after STOP
        if dayWalker.start > dayWalker.stop {
            stopping = true
        }
    }

    mutating func next() -> Date? {
        guard stopping == false else {
            return nil
        }

        let now = current
        current = Calendar.current.date(byAdding: .day, value: 1, to: current)!

        // inclusive range - stop next iteration, after iterating thru the stop date
        stopping = df.string(from:now) == stopString
        
        return now
    }
}
