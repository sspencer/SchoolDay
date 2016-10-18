//
//  ViewController.swift
//  SchoolDay
//
//  Created by Steve Spencer on 10/17/16.
//  Copyright © 2016 Steve Spencer. All rights reserved.
//
import UIKit

class ViewController: UIViewController,
    UICollectionViewDelegate, UICollectionViewDataSource,
    UITableViewDataSource, UITableViewDelegate
{



    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!

    let ymdFormatter = DateFormatter()
    let monthFormatter = DateFormatter()
    let weekdayFormatter = DateFormatter()
    let dateFormatter = DateFormatter()

    let classes: [String:String] = [
        "1": "Exploring Computer Science",
        "2": "The Revelation of JC",
        "3": "Music Theory",
        "4": "Biology",
        "5": "Algebra 1",
        "6": "Grammar Comp",
        "7": "Spanish 1"]


    fileprivate var days = [String]()
    //    fileprivate var items = [String:[String]]()
    fileprivate var cal : Cal?

    fileprivate var currentPage: Int = 0 {
        didSet {
            let date = self.days[self.currentPage]
            NSLog("=============\nSET CURRENT PAGE: %d\n=============", self.currentPage)
            if let cal = self.cal {
                if let day = cal.sum2(day: date) {
                    //scheduleTextView.text = day.description(classes: self.classes)
                    //scheduleTextView.textAlignment = .left

                    return
                }
            }

            var text = "Holiday"
            if let now = ymdFormatter.date(from: date) {
                let weekday = weekdayFormatter.string(from: now).lowercased()
                if weekday == "saturday" || weekday == "sunday" {
                    text = "Weekend"
                }
            }

            //scheduleTextView.text = text
            //scheduleTextView.textAlignment = .center
        }
    }

    fileprivate var pageSize: CGSize {
        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
        var pageSize = layout.itemSize
        if layout.scrollDirection == .horizontal {
            pageSize.width += layout.minimumLineSpacing
        } else {
            pageSize.height += layout.minimumLineSpacing
        }
        return pageSize
    }

    fileprivate var orientation: UIDeviceOrientation {
        return UIDevice.current.orientation
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        // setup layout
        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
        layout.spacingMode = UPCarouselFlowLayoutSpacingMode.overlap(visibleOffset: 30)

        ymdFormatter.dateFormat = "yyyyMMdd"
        monthFormatter.dateFormat = "MMMM"
        weekdayFormatter.dateFormat = "EEEE"
        dateFormatter.dateFormat = "d"

        // create items
        if let cal = Cal(fromResource: "rotation", ofType: "ics") {
            self.cal = cal
            self.days = cal.days()
        }

        // Show calendar for today's date
        let today = ymdFormatter.string(from: Date())
        if let page = self.days.index(of:today) {
            self.currentPage = page
        } else {
            self.currentPage = 0
        }

    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Card Collection Delegate & DataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return days.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DateCell.identifier, for: indexPath) as! DateCell
        let date = days[(indexPath as IndexPath).row]

        if let now = ymdFormatter.date(from: date) {
            cell.monthLabel.text = monthFormatter.string(from: now).uppercased()
            cell.weekdayLabel.text = weekdayFormatter.string(from: now)
            cell.dateLabel.text = dateFormatter.string(from: now)
        }

        return cell
    }

    /*
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
     NSLog("ITEM SELECTED: %d", indexPath.row)
     }
     */

    // Just want to be called once here - at load time, to scroll to specified calendar date.
    var onceOnly = false
    internal func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if !onceOnly {
            onceOnly = true
            let indexToScrollTo = IndexPath(row: self.currentPage, section: indexPath.section)
            self.collectionView.scrollToItem(at: indexToScrollTo, at: .centeredHorizontally, animated: false)
        }
    }


    // MARK: - UIScrollViewDelegate

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
        let pageSide = (layout.scrollDirection == .horizontal) ? self.pageSize.width : self.pageSize.height
        let offset = (layout.scrollDirection == .horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
        currentPage = Int(floor((offset - pageSide / 2) / pageSide) + 1)
    }
    
    // MARK: - Table View Delegate & DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return nil
    }

}

