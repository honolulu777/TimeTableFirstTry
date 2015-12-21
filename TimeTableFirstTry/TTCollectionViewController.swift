//
//  CollectionViewController.swift
//  TimeTableFirstTry
//
//  Created by Aurel Feer on 25/10/2015.
//  Copyright © 2015 Aurel Feer. All rights reserved.
//

import UIKit

class TTCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //MARK: IDENTIFIERS
    let timetitleCellIdentifier = "TimetitleCellIdentifier"
    let dayCellIdentifier = "DayCellIdentifier"
    let timeCellIdentifier = "TimeCellIdentifier"
    let lessonCellIdentifier = "LessonCellIdentifier"
    let replacedlessonCellIdentifier = "ReplacedLessonCellIdentifier"
    
    let loginSegueIdentifier = "showLogin"
    
    //MARK: TIME
    let calendar = NSCalendar.currentCalendar()
    //let refreshDelay = dispatch_time(DISPATCH_TIME_NOW, Int64(10 * Double(NSEC_PER_SEC)))
    
    //MARK: CLASSES
    let timegetter = TimetableTime()
    let declarelesson = DeclareLesson()
    let layout = TTCollectionViewLayout()
    let landscapelayout = TTLandscapeCollectionViewLayout()
    let day = Day()
    let sup = DeviceSupport()
    
    var userDefaults = NSUserDefaults.standardUserDefaults()

    //MARK: INTEGERS
    let numberOfSections = 13
    let numberOfColumns = 16
    
    //MARK: CGPoints
    var scrollStartContentOffset: CGPoint = CGPoint(x: 0, y: 0)
    
    //MARK: COLORS
    let dividingLineColor = UIColor(hue: 0.8639, saturation: 0, brightness: 0.83, alpha: 1.0) //GRAY
    let cellBackgroundColor = UIColor.whiteColor()
    let replacedLessonTextColor = UIColor.blueColor()
    let cancelledLessonTextColor = UIColor.redColor()
    let defaultTextColor = UIColor.blackColor()
    let specialLessonBackgroundColor = UIColor(hue: 0.1167, saturation: 0.83, brightness: 0.94, alpha: 1.0) //YELLOW
    let specialDividingLineColor = UIColor(hue: 0.0833, saturation: 0.83, brightness: 0.93, alpha: 1.0) // #ef8c28, ORANGE-YELLOW
    
    let yellowGreenBackground = UIColor(hue: 0.1694, saturation: 0.74, brightness: 0.84, alpha: 1.0)    //GREEN-YELLOW
    let darkgreenTint = UIColor(hue: 0.4778, saturation: 0.73, brightness: 0.46, alpha: 1.0)            //DARKGREEN
    
    //MARK: OUTLETS
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var navigationBarHeightConstraint: NSLayoutConstraint!
    
    //MARK: BOOL
    var canRefresh: Bool = true
    
    //Mark: ARRAYS
    var currentLesson: [Int] = []
    
    override func viewDidLoad() {
        assignCurrentLesson()
        super.viewDidLoad()
        self.collectionView.backgroundColor = dividingLineColor
    }

    override func viewWillAppear(animated: Bool) {
        self.collectionView.reloadData()
        if UIApplication.sharedApplication().statusBarOrientation == .Portrait {
            addStatusBar()
            setLayoutToPortrait(false)
        } else {
            removeStatusBar()
            setLayoutToLandscape(false)
        }
        scrollToCurrentSection(self.collectionView, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    //MARK: BACK BUTTON
    @IBAction func backButton(sender: AnyObject) {
        assignCurrentLesson()
        scrollToCurrentSection(self.collectionView, animated: true)
    }
    
    //MARK: REFRESH BUTTON
    @IBAction func refreshButton(sender: AnyObject) {
        if canRefresh {
            canRefresh = false
            let apiHandler = APIHandler()
            apiHandler.getDataWithToken()
            print("REFRESH!!")
            print("RetrivedNewToken: " + String(userDefaults.boolForKey("RetrievedNewToken")))
            if userDefaults.boolForKey("RetrievedNewToken") {
                collectionView.reloadData()
            } else {
                goToLogin()
            }
            canRefresh = true
        }
    }
    
    func goToLogin() {
        self.performSegueWithIdentifier(loginSegueIdentifier, sender: nil)
    }

    // MARK: BAR HANDLING
    func removeStatusBar() {
        navigationBarHeightConstraint.constant = 44
    }
    
    
    func addStatusBar() {
        navigationBarHeightConstraint.constant = 64
    }
    
    func setLayoutToPortrait(animated: Bool) {
        self.collectionView.setCollectionViewLayout(layout, animated: animated)
    }
    
    func setLayoutToLandscape(animated: Bool) {
        self.collectionView.setCollectionViewLayout(landscapelayout, animated: animated)
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        if toInterfaceOrientation == .Portrait {
            addStatusBar()
            setLayoutToPortrait(true)
            
        } else {
            
            removeStatusBar()
            setLayoutToLandscape(true)
        }
        
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        if fromInterfaceOrientation != .Portrait {
            scrollToOptimalSection(self.collectionView, animated: true)
        }
        
        // Reload Day section so Dates are shorter.
        self.collectionView.reloadSections(NSIndexSet(index: 0))
    }
    
    
    // MARK: PAGING
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        scrollStartContentOffset = collectionView.contentOffset
        scrollStartContentOffset.x += layout.getTimeColumnWidth()
    }
    
    
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        if UIApplication.sharedApplication().statusBarOrientation == .Portrait || UIApplication.sharedApplication().statusBarOrientation == .PortraitUpsideDown  {
            scrollToOptimalSection(scrollView, animated: true)
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            if UIApplication.sharedApplication().statusBarOrientation == .Portrait || UIApplication.sharedApplication().statusBarOrientation == .PortraitUpsideDown {
                scrollToOptimalSection(scrollView, animated: true)
            }
        }
    }
    
    func scrollToOptimalSection(scrollView: UIScrollView, animated: Bool) {
        if scrollView == self.collectionView {
            let targetScrollingPos = UICollectionViewScrollPosition.Right
            var currentCellOffset: CGPoint = self.collectionView.contentOffset
            currentCellOffset.x += layout.getTimeColumnWidth()
            let columnWidth = self.collectionView.bounds.width - layout.getTimeColumnWidth()
            
            let rightTargetFactor: CGFloat = 0.8
            let leftTargetFactor: CGFloat = 1 - rightTargetFactor
            
            if (currentCellOffset.x - scrollStartContentOffset.x) < 0 {
                currentCellOffset.x += (columnWidth * leftTargetFactor)
            } else {
                currentCellOffset.x += (columnWidth * rightTargetFactor)
            }
            
            let currentIndexPath = collectionView.indexPathForItemAtPoint(currentCellOffset)
            if currentIndexPath != nil {
                let targetCellIndexPath = NSIndexPath(forItem: (currentIndexPath?.row)!, inSection: (currentIndexPath?.section)! + 1)
                collectionView.scrollToItemAtIndexPath(targetCellIndexPath, atScrollPosition: targetScrollingPos, animated: animated)
            }
            
        }
    }
    
    func scrollToCurrentSection(scrollView: UIScrollView, animated: Bool) {
        if scrollView == self.collectionView {
            let targetScrollingPos = UICollectionViewScrollPosition.Right
            let targetItem = currentLesson[0] - 1
            
            let targetIndexPath = NSIndexPath(forItem: targetItem, inSection: 1)
            
            collectionView.scrollToItemAtIndexPath(targetIndexPath, atScrollPosition: targetScrollingPos, animated: animated)
        }
    }
    
    func assignCurrentLesson() {
        if currentLesson == [] {
            currentLesson = timegetter.getCurrentLessonCoordinates()
        }
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return numberOfSections
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfColumns
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        assignCurrentLesson()
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let dayCell: DayCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(dayCellIdentifier, forIndexPath: indexPath) as! DayCollectionViewCell

                dayCell.dayLabel.text = NSLocalizedString("time", comment: "TransForTime")
                
                dayCell.dividingView.backgroundColor = dividingLineColor
                
                dayCell.backgroundColor = yellowGreenBackground
                dayCell.dayLabel.textColor = darkgreenTint
                
                return dayCell
                
            } else {
                let dayCell: DayCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(dayCellIdentifier, forIndexPath: indexPath) as! DayCollectionViewCell
                
                let dayArray: [String]
                if UIApplication.sharedApplication().statusBarOrientation == .Portrait {
                    dayArray = day.generateDayArray(.long, forUI: true)
                } else {
                    if sup.getAbsoluteDisplayHeight() > 480 {
                        dayArray = day.generateDayArray(.short,forUI: true)
                    } else {
                        dayArray = day.generateDayArray(.veryshort, forUI: true)
                    }
                }
                dayCell.dayLabel.text = dayArray[indexPath.row - 1]
                
                dayCell.dividingView.backgroundColor = dividingLineColor
                
                /*if timegetter.dayIsCurrentDay(indexPath.item) {
                    dayCell.dayLabel.font = UIFont.boldSystemFontOfSize(13)
                }*/
                if indexPath.item == (currentLesson[0] - 1) {
                    dayCell.dayLabel.font = UIFont.boldSystemFontOfSize(13)
                }
                
                dayCell.backgroundColor = yellowGreenBackground
                dayCell.dayLabel.textColor = darkgreenTint
                
                return dayCell
                
            }
        } else {
            if indexPath.row == 0 {
                let timeCell: TimeCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(timeCellIdentifier, forIndexPath: indexPath) as! TimeCollectionViewCell

                timeCell.starttimeLabel.text = timegetter.getLessonTimeAsString(indexPath.section - 1, when: .Start, withSeconds:  false)
                timeCell.endtimeLabel.text = timegetter.getLessonTimeAsString(indexPath.section - 1, when: .End, withSeconds: false)
                
                timeCell.dividingView.backgroundColor = dividingLineColor
                
                return timeCell
            } else {
                
                let celltoreturn: UICollectionViewCell
                
                
                let alesson = declarelesson.getNewLessonForUI(indexPath.section, item: indexPath.item)
                
                switch alesson.status {
                    case .Default:
                        let lessonCell: LessonCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(lessonCellIdentifier, forIndexPath: indexPath) as! LessonCollectionViewCell
                        // Declaring subjectLabel appearance
                        lessonCell.subjectLabel.text = alesson.subject
                        // Declaring teacherLabel appearance
                        lessonCell.teacherLabel.text = alesson.teacher
                        // Declaring roomLabel appearance
                        lessonCell.roomLabel.text = alesson.room
                        
                        lessonCell.dividingView.backgroundColor = dividingLineColor
                        
                        if indexPath.item == 3 {
                            lessonCell.backgroundView?.backgroundColor = yellowGreenBackground
                        }
                        
                        celltoreturn = lessonCell as LessonCollectionViewCell
                    
                    case .Cancelled:
                        let lessonCell: LessonCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(lessonCellIdentifier, forIndexPath: indexPath) as! LessonCollectionViewCell
                        // Declaring subjectLabel appearance
                        lessonCell.subjectLabel.textColor = cancelledLessonTextColor
                        lessonCell.subjectLabel.text = alesson.subject
                        // Declaring teacherLabel appearance
                        lessonCell.teacherLabel.textColor = cancelledLessonTextColor
                        lessonCell.teacherLabel.text = alesson.teacher
                        // Declaring roomLabel appearance
                        lessonCell.roomLabel.textColor = cancelledLessonTextColor
                        lessonCell.roomLabel.text = alesson.room
                        //Crossing out Lesson
                        lessonCell.crossOutView.backgroundColor = cancelledLessonTextColor
                        
                        lessonCell.dividingView.backgroundColor = dividingLineColor
                
                        celltoreturn = lessonCell
                    
                    case .Replaced:
                        let replacedlessonCell: ReplacedLessonCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(replacedlessonCellIdentifier, forIndexPath: indexPath) as! ReplacedLessonCollectionViewCell
                        // Declaring subjectLabel appearance
                        replacedlessonCell.subjectLabel.textColor = replacedLessonTextColor
                        replacedlessonCell.subjectLabel.text = alesson.subject
                        // Declaring teacherLabel appearance
                        replacedlessonCell.teacherLabel.textColor = replacedLessonTextColor
                        replacedlessonCell.teacherLabel.text = alesson.teacher
                        // Declaring roomLabel appearance
                        replacedlessonCell.roomLabel.textColor = replacedLessonTextColor
                        replacedlessonCell.roomLabel.text = alesson.room
                        // Declaring subsubjectLabel appearance
                        replacedlessonCell.subsubjectLabel.textColor = replacedLessonTextColor
                        replacedlessonCell.subsubjectLabel.text = alesson.subsubject
                        // Declaring subteacherLabel appearance
                        replacedlessonCell.subteacherLabel.textColor = replacedLessonTextColor
                        replacedlessonCell.subteacherLabel.text = alesson.subteacher
                        // Declaring subroomLabel appearance
                        replacedlessonCell.subroomLabel.textColor = replacedLessonTextColor
                        replacedlessonCell.subroomLabel.text = alesson.subroom
                        
                        replacedlessonCell.dividingView.backgroundColor = dividingLineColor
                    
                        celltoreturn = replacedlessonCell
                    
                    case .Empty:
                        let lessonCell: LessonCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(lessonCellIdentifier, forIndexPath: indexPath) as! LessonCollectionViewCell
                        // Declaring empty Lesson
                        lessonCell.subjectLabel.text = ""
                        lessonCell.teacherLabel.text = ""
                        lessonCell.roomLabel.text = ""
                        
                        lessonCell.dividingView.backgroundColor = dividingLineColor
                        
                        celltoreturn = lessonCell
                    
                    case .Special:
                        let lessonCell: LessonCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(lessonCellIdentifier, forIndexPath: indexPath) as! LessonCollectionViewCell
                        
                        lessonCell.teacherLabel.text = ""
                        lessonCell.roomLabel.text = ""
                        lessonCell.subjectLabel.textColor = cellBackgroundColor
                        lessonCell.backgroundColor = specialLessonBackgroundColor

                        lessonCell.subjectLabel.text = alesson.subject
                        
                        lessonCell.dividingView.backgroundColor = specialDividingLineColor
                        
                        celltoreturn = lessonCell
                    case .MovedTo:
                        let lessonCell: LessonCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(lessonCellIdentifier, forIndexPath: indexPath) as! LessonCollectionViewCell
                    
                        lessonCell.teacherLabel.text = alesson.teacher
                        lessonCell.subjectLabel.text = alesson.subject
                        lessonCell.roomLabel.text = alesson.room
                    
                        lessonCell.teacherLabel.textColor = replacedLessonTextColor
                        lessonCell.subjectLabel.textColor = replacedLessonTextColor
                        lessonCell.roomLabel.textColor = replacedLessonTextColor
                    
                        celltoreturn = lessonCell
                }
                
                /*if timegetter.lessonIsCurrentLesson(indexPath.item, inSection: indexPath.section) {
                    celltoreturn.backgroundColor = UIColor.redColor()
                }*/
                
                if indexPath.item == currentLesson[0] - 1 && indexPath.section == currentLesson[1] + 1 {
                    celltoreturn.backgroundColor = UIColor.redColor()
                }

                
                return celltoreturn
            }
        }
    }
}

