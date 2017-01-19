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
    let weekdayFormatter = DateFormatter()

    let classes: [String:String] = [
        "1": "Health",
        "2": "Spanish",
        "3": "Music Theory",
        "4": "Biology",
        "5": "Algebra",
        "6": "Grammar",
        "7": "Jesus",
        "L": "Lunch",
        "M": "Mass",
        "C": "Career Day",
        "X": "X-Block",
        "T": "Testing Day"]


    fileprivate var calendar : Cal!
    fileprivate var day : Day?

    fileprivate var currentPage: Int = 0 {
        didSet {
            self.day = calendar.day(index: self.currentPage)
            self.tableView.reloadData()
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
        weekdayFormatter.dateFormat = "EEEE"

        // create items
        self.calendar = Cal(jsonResource: "rotation")

        // Show calendar for today's date
        let today = ymdFormatter.string(from: Date())
        if let page = self.calendar.index(date:today) {
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
        return calendar.count()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DateCollectionViewCell.identifier, for: indexPath) as! DateCollectionViewCell
        if let schedule = calendar.day(index: indexPath.row) {
            if let now = ymdFormatter.date(from: schedule.date) {
                cell.display(date: now)
            }
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

        let nextPage = Int(floor((offset - pageSide / 2) / pageSide) + 1)

        // Collection View errantly scrolls to first item when scrolling in table view.
        // Verify that the nextPage can be scrolled to.
        var match = false
        for cell in self.collectionView.visibleCells {
            let p = self.collectionView.indexPath(for: cell)
            if p?.last == nextPage {
                match = true
            }
        }

        if match {
            currentPage = nextPage
        }
    }
    
    // MARK: - Table View Delegate & DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let schedule = self.day else {
            return 0
        }

        if schedule.times.count > 0 {
            return schedule.times.count + 2
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        let row = indexPath.row

        guard let schedule = self.day else {
            return cell
        }

        switch(row) {
        case 0:
            if schedule.times.count == 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "specialCell", for: indexPath)
                if schedule.weekend {
                    cell.textLabel?.text = "Weekend"
                } else {
                    cell.textLabel?.text = "*** Holiday ***"
                }
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath)
                cell.textLabel?.textColor = UIColor.black
                cell.textLabel?.text = schedule.title
            }
        default:
            if row > schedule.times.count {
                cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath)
                let title : String
                if schedule.dismissal == "1:40pm" {
                    title = "Early Dismissal: 1:40pm"
                } else {
                    title = "Dismissal: \(schedule.dismissal)"
                }

                cell.textLabel?.textColor = UIColor.red
                cell.textLabel?.text = title

            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: ClassTableViewCell.identifier, for: indexPath)
                let index = row - 1
                let period: String
                if let clz = classes[schedule.periods[index]] {
                    period = clz
                } else {
                    period = schedule.periods[index]
                }

                (cell as! ClassTableViewCell).display(time: schedule.times[index], detail: period)
            }
        }

        return cell
    }

}

