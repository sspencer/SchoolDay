//
//  DateCell.swift
//  SchoolDay
//
//  Created by Steve Spencer on 10/17/16.
//  Copyright © 2016 Steve Spencer. All rights reserved.
//

import UIKit

class DateCell: UICollectionViewCell {
    static let identifier = "dateCell"

    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var weekdayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.layer.cornerRadius = 16
        self.layer.borderWidth = 2

        //self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderColor = UIColor(red:0.511, green:0.066, blue:0, alpha:1).cgColor
        //UIColor(white: 0.3, alpha: 1.0).cgColor
    }

}
