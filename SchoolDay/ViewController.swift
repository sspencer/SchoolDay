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
        "1": "Exploring Computer Science",
        "2": "The Revelation of JC",
        "3": "Music Theory",
        "4": "Biology",
        "5": "Algebra 1",
        "6": "Grammar Comp",
        "7": "Spanish 1"]


    fileprivate var days = [String]()
    fileprivate var today: [(String, String)]?

    //    fileprivate var items = [String:[String]]()
    fileprivate var cal : Cal?

    fileprivate var currentPage: Int = 0 {
        didSet {
            let date = self.days[self.currentPage]

            if let cal = self.cal, let day = cal.sum2(day: date) {
                    self.today = day.description(classes: self.classes)
            } else {
                self.today = [(String,String)]()
            }
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DateCollectionViewCell.identifier, for: indexPath) as! DateCollectionViewCell
        let date = days[(indexPath as IndexPath).row]

        if let now = ymdFormatter.date(from: date) {
            cell.display(date: now)
            tableView.reloadData()
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
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!

        switch(indexPath.row) {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath)
            cell.textLabel?.text = "Title Here"
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: ClassTableViewCell.identifier, for: indexPath)

            let date = self.days[self.currentPage]
            if let cal = self.cal {
                if let day = cal.sum2(day: date) {
                    NSLog("Detail: %@", day.description(classes: self.classes))

            (cell as! ClassTableViewCell).display(time: "1:35pm", detail: "Class Name")
        }

        return cell
    }

}

