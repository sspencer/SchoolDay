//
//  DateCollectionViewCell.swift
//  SchoolDay
//
//  Created by Steve Spencer on 10/17/16.
//  Copyright © 2016 Steve Spencer. All rights reserved.
//

import UIKit

class DateCollectionViewCell: UICollectionViewCell {
    static let identifier = "dateCell"

    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var weekdayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    let monthFormatter = DateFormatter()
    let weekdayFormatter = DateFormatter()
    let dateFormatter = DateFormatter()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.layer.cornerRadius = 16
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor(red:0.511, green:0.066, blue:0, alpha:1).cgColor

        monthFormatter.dateFormat = "MMMM"
        weekdayFormatter.dateFormat = "EEEE"
        dateFormatter.dateFormat = "d"
    }

    func display(date: Date) {
        monthLabel.text = monthFormatter.string(from: date).uppercased()
        weekdayLabel.text = weekdayFormatter.string(from: date)
        dateLabel.text = dateFormatter.string(from: date)
    }
}
