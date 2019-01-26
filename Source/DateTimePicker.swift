//
//  DateTimePicker.swift
//  DateTimePicker
//
//  Created by Huong Do on 9/16/16.
//  Copyright © 2016 ichigo. All rights reserved.
//

import UIKit

public protocol DateTimePickerDelegate: class {
    func dateTimePicker(_ picker: DateTimePicker, didSelectDate: Date)
}

@objc public class DateTimePicker: UIView {
    
    var contentHeight: CGFloat = 330
    @objc public enum MinuteInterval: Int {
        case `default` = 1
        case five = 5
        case ten = 10
        case fifteen = 15
        case twenty = 20
        case thirty = 30
    }
    
    /// custom highlight color, default to cyan
    public var highlightColor = UIColor(red: 0/255.0, green: 199.0/255.0, blue: 194.0/255.0, alpha: 1) {
        didSet {
            todayButton.setTitleColor(highlightColor, for: .normal)
            colonLabel1.textColor = highlightColor
            colonLabel2.textColor = highlightColor
            dayCollectionView.reloadData()
            hourTableView.reloadData()
            minuteTableView.reloadData()
            amPmTableView.reloadData()
        }
    }
    
    /// custom dark color, default to grey
    public var darkColor = UIColor(red: 0, green: 22.0/255.0, blue: 39.0/255.0, alpha: 1) {
        didSet {
            dateTitleLabel.textColor = darkColor
            cancelButton.setTitleColor(darkColor.withAlphaComponent(0.5), for: .normal)
            doneButton.backgroundColor = darkColor.withAlphaComponent(0.5)
            borderTopView.backgroundColor = darkColor.withAlphaComponent(0.2)
            borderBottomView.backgroundColor = darkColor.withAlphaComponent(0.2)
            separatorTopView.backgroundColor = darkColor.withAlphaComponent(0.2)
            separatorBottomView.backgroundColor = darkColor.withAlphaComponent(0.2)
            dayCollectionView.reloadData()
            hourTableView.reloadData()
            minuteTableView.reloadData()
            amPmTableView.reloadData()
        }
    }
    
    /// custom DONE button color, default to darkColor
    public var doneBackgroundColor: UIColor? {
        didSet {
            doneButton.backgroundColor = doneBackgroundColor
        }
    }
    
    /// custom background color for date cells
    public var daysBackgroundColor = UIColor(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, alpha: 1)
	
    /// date locale (language displayed), default to device's locale
    public var locale = Locale.current {
        didSet {
            configureView()
        }
    }
    
    /// selected date when picker is displayed, default to current date
    public var selectedDate = Date() {
        didSet {
            if minimumDate.compare(selectedDate) == .orderedDescending {
                selectedDate = minimumDate;
            }
            
            if selectedDate.compare(maximumDate) == .orderedDescending {
                selectedDate = maximumDate
            }
            self.delegate?.dateTimePicker(self, didSelectDate: selectedDate)
            resetDateTitle()
            
            if selectedDate == minimumDate || selectedDate == maximumDate {
                resetTime()
            }
        }
    }
    
    public var selectedDateString: String {
        get {
            let formatter = DateFormatter()
            formatter.dateFormat = self.dateFormat
            return formatter.string(from: self.selectedDate)
        }
    }
    
    /// custom date format to be displayed, default to HH:mm dd/MM/YYYY
    public var dateFormat = "HH:mm dd/MM/YYYY" {
        didSet {
            resetDateTitle()
        }
    }
    
    /// custom title for dismiss button, default to Cancel
    public var cancelButtonTitle = "Cancel" {
        didSet {
            cancelButton.setTitle(cancelButtonTitle, for: .normal)
        }
    }
    
    /// custom title for reset time button, default to Today
    public var todayButtonTitle = "Today" {
        didSet {
            todayButton.setTitle(todayButtonTitle, for: .normal)
        }
    }
    
    /// custom title for done button, default to DONE
    public var doneButtonTitle = "DONE" {
        didSet {
            doneButton.setTitle(doneButtonTitle, for: .normal)
        }
    }
    
    /// whether to display time in 12 hour format, default to false
    public var is12HourFormat = false {
        didSet {
            configureView()
        }
    }
    
    
    /// whether to only show date in picker view, default to false
    public var isDatePickerOnly = false {
        didSet {
            if isDatePickerOnly {
                isTimePickerOnly = false
            }
            configureView()
        }
    }
    
    /// whether to show only time in picker view, default to false
    public var isTimePickerOnly = false {
        didSet {
            if isTimePickerOnly {
                isDatePickerOnly = false
            }
            configureView()
        }
    }

    /// whether to include month in date cells, default to false
    public var includeMonth = false {
        didSet {
            configureView()
        }
    }
    
    /// Time interval, in minutes, default to 1.
    /// If not default, infinite scrolling is off.
    public var timeInterval = MinuteInterval.default {
        didSet {
            resetDateTitle()
        }
    }
    
    public var timeZone = TimeZone.current
    public var completionHandler: ((Date)->Void)?
    public var dismissHandler: (() -> Void)?
    public weak var delegate: DateTimePickerDelegate?

    // private vars
    internal var hourTableView: UITableView!
    internal var minuteTableView: UITableView!
    internal var amPmTableView: UITableView!
    internal var dayCollectionView: UICollectionView!
    
    private var shadowView: UIView!
    private var contentView: UIView!
    private var dateTitleLabel: UILabel!
    private var todayButton: UIButton!
    private var doneButton: UIButton!
    private var cancelButton: UIButton!
    private var colonLabel1: UILabel!
    private var colonLabel2: UILabel!
    
    private var borderTopView: UIView!
    private var borderBottomView: UIView!
    private var separatorTopView: UIView!
    private var separatorBottomView: UIView!
    
    private var modalCloseHandler: (() -> Void)?
    
    internal var minimumDate: Date!
    internal var maximumDate: Date!
    
    internal var calendar: Calendar = .current
    internal var dates: [Date]! = []
    internal var components: DateComponents! {
        didSet {
            components.timeZone = timeZone
        }
    }
    
    @objc open class func create(minimumDate: Date? = nil, maximumDate: Date? = nil) -> DateTimePicker {
        
        let dateTimePicker = DateTimePicker()
        dateTimePicker.minimumDate = minimumDate ?? Date(timeIntervalSinceNow: -3600 * 24 * 10)
        dateTimePicker.maximumDate = maximumDate ?? Date(timeIntervalSinceNow: 3600 * 24 * 10)
        assert(dateTimePicker.minimumDate.compare(dateTimePicker.maximumDate) == .orderedAscending, "Minimum date should be earlier than maximum date")
        dateTimePicker.configureView()
        return dateTimePicker
    }
    
    
    @objc open func show() {
        
		if let window = UIApplication.shared.keyWindow {
            let shadowView = UIView()
            shadowView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            shadowView.alpha = 1
            let shadowViewTap = UITapGestureRecognizer(target: self, action: #selector(DateTimePicker.dismissView(sender:)))
            shadowView.addGestureRecognizer(shadowViewTap)
            window.addSubview(shadowView)
            
            shadowView.translatesAutoresizingMaskIntoConstraints = false
            shadowView.topAnchor.constraint(equalTo: window.topAnchor).isActive = true
            shadowView.bottomAnchor.constraint(equalTo: window.bottomAnchor).isActive = true
            shadowView.leadingAnchor.constraint(equalTo: window.leadingAnchor).isActive = true
            shadowView.trailingAnchor.constraint(equalTo: window.trailingAnchor).isActive = true
			
            window.addSubview(self)
			translatesAutoresizingMaskIntoConstraints = false
			topAnchor.constraint(equalTo: window.topAnchor).isActive = true
            let contentViewBottomConstraint = bottomAnchor.constraint(equalTo: window.bottomAnchor, constant: contentHeight)
            contentViewBottomConstraint.isActive = true
			leadingAnchor.constraint(equalTo: window.leadingAnchor).isActive = true
			trailingAnchor.constraint(equalTo: window.trailingAnchor).isActive = true
            layoutIfNeeded()
            
            // animate to show contentView
            contentViewBottomConstraint.constant = 0
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.4, options: .curveEaseIn, animations: {
                self.layoutIfNeeded()
            }, completion: { completed in
                self.resetTime()
            })
            
            modalCloseHandler = {
                contentViewBottomConstraint.constant = self.contentHeight
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.8, options: .curveLinear, animations: {
                    // animate to hide pickerView
                    self.layoutIfNeeded()
                }, completion: { (completed) in
                    self.removeFromSuperview()
                    shadowView.removeFromSuperview()
                    
                })
            };
		}
    }
    
    public override func didMoveToSuperview() {
        if (superview == nil) {
            return
        }
        
        self.resetTime()
    }
    
    private func configureView() {
        
        // content view
        if (contentView != nil) {
            contentView.removeFromSuperview()
        }
        
        contentHeight = isDatePickerOnly ? 228 : isTimePickerOnly ? 230 : 330
        if let window = UIApplication.shared.keyWindow {
            self.frame.size.width = window.bounds.size.width
        }
        self.frame.size.height = contentHeight
        
        contentView = UIView(frame: CGRect.zero)
        contentView.layer.shadowColor = UIColor(white: 0, alpha: 0.3).cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: -2.0)
        contentView.layer.shadowRadius = 1.5
        contentView.layer.shadowOpacity = 0.5
        contentView.backgroundColor = .white
        contentView.isHidden = true
        addSubview(contentView)
		
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        contentView.heightAnchor.constraint(equalToConstant: contentHeight).isActive = true
        contentView.layoutMargins = UIEdgeInsets.init(top: 0, left: 20, bottom: 0, right: 20)
        
        // title view
        let titleView = UIView(frame: CGRect.zero)
        titleView.backgroundColor = .white
        contentView.addSubview(titleView)
        
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        titleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        titleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        titleView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        titleView.layoutMargins = UIEdgeInsets.init(top: 0, left: 20, bottom: 0, right: 20)
        
        dateTitleLabel = UILabel(frame: CGRect.zero)
        dateTitleLabel.font = UIFont.systemFont(ofSize: 15)
        dateTitleLabel.textColor = darkColor
        dateTitleLabel.textAlignment = .center
        resetDateTitle()
        titleView.addSubview(dateTitleLabel)
        
        dateTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        dateTitleLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        dateTitleLabel.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        
        cancelButton = UIButton(type: .system)
        cancelButton.setTitle(cancelButtonTitle, for: .normal)
        cancelButton.setTitleColor(darkColor.withAlphaComponent(0.5), for: .normal)
        cancelButton.contentHorizontalAlignment = .left
        cancelButton.addTarget(self, action: #selector(DateTimePicker.dismissView(sender:)), for: .touchUpInside)
        cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        titleView.addSubview(cancelButton)
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.topAnchor.constraint(equalTo: titleView.topAnchor).isActive = true
        cancelButton.leadingAnchor.constraint(equalTo: titleView.layoutMarginsGuide.leadingAnchor, constant: 0).isActive = true
        cancelButton.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        cancelButton.trailingAnchor.constraint(equalTo: dateTitleLabel.leadingAnchor).isActive = true
        
        todayButton = UIButton(type: .system)
        todayButton.setTitle(todayButtonTitle, for: .normal)
        todayButton.setTitleColor(highlightColor, for: .normal)
        todayButton.addTarget(self, action: #selector(DateTimePicker.setToday), for: .touchUpInside)
        todayButton.contentHorizontalAlignment = .right
        todayButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        todayButton.isHidden = self.minimumDate.compare(Date()) == .orderedDescending || self.maximumDate.compare(Date()) == .orderedAscending
        titleView.addSubview(todayButton)
        
        todayButton.translatesAutoresizingMaskIntoConstraints = false
        todayButton.trailingAnchor.constraint(equalTo: titleView.layoutMarginsGuide.trailingAnchor, constant: 0).isActive = true
        todayButton.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        todayButton.leadingAnchor.constraint(equalTo: dateTitleLabel.trailingAnchor).isActive = true
		
        // day collection view
        let layout = StepCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: 75, height: 80)
        
        dayCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        dayCollectionView.backgroundColor = daysBackgroundColor
        dayCollectionView.showsHorizontalScrollIndicator = false
        
        if includeMonth {
            dayCollectionView.register(FullDateCollectionViewCell.self, forCellWithReuseIdentifier: "dateCell")
        } else if includeMonth == false {
            dayCollectionView.register(DateCollectionViewCell.self, forCellWithReuseIdentifier: "dateCell")
            
        }
        
        dayCollectionView.dataSource = self
        dayCollectionView.delegate = self
        dayCollectionView.isHidden = isTimePickerOnly
        contentView.addSubview(dayCollectionView)
        
        dayCollectionView.translatesAutoresizingMaskIntoConstraints = false
        dayCollectionView.topAnchor.constraint(equalTo: titleView.bottomAnchor).isActive = true
        dayCollectionView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor).isActive = true
        dayCollectionView.trailingAnchor.constraint(equalTo: titleView.trailingAnchor).isActive = true
        dayCollectionView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        dayCollectionView.layoutIfNeeded()
        let inset = (dayCollectionView.frame.width - 75) / 2
        dayCollectionView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        
        // top & bottom borders on day collection view
        borderTopView = UIView(frame: CGRect.zero)
        borderTopView.backgroundColor = darkColor.withAlphaComponent(0.2)
        borderTopView.isHidden = isTimePickerOnly
        contentView.addSubview(borderTopView)
        
        borderTopView.translatesAutoresizingMaskIntoConstraints = false
        borderTopView.topAnchor.constraint(equalTo: titleView.bottomAnchor).isActive = true
        borderTopView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor).isActive = true
        borderTopView.trailingAnchor.constraint(equalTo: titleView.trailingAnchor).isActive = true
        borderTopView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        borderBottomView = UIView(frame: CGRect.zero)
        borderBottomView.backgroundColor = darkColor.withAlphaComponent(0.2)
        contentView.addSubview(borderBottomView)
        
        borderBottomView.translatesAutoresizingMaskIntoConstraints = false
        borderBottomView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor).isActive = true
        borderBottomView.trailingAnchor.constraint(equalTo: titleView.trailingAnchor).isActive = true
        borderBottomView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        if isTimePickerOnly {
            borderBottomView.topAnchor.constraint(equalTo: titleView.bottomAnchor).isActive = true
        } else {
            borderBottomView.topAnchor.constraint(equalTo: dayCollectionView.bottomAnchor).isActive = true
        }
        
        // done button
        doneButton = UIButton(type: .system)
        doneButton.setTitle(doneButtonTitle, for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.backgroundColor = doneBackgroundColor ?? darkColor.withAlphaComponent(0.5)
        doneButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        doneButton.layer.cornerRadius = 3
        doneButton.layer.masksToBounds = true
        doneButton.addTarget(self, action: #selector(DateTimePicker.donePicking(sender:)), for: .touchUpInside)
        contentView.addSubview(doneButton)
        
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10 - 44 - 10).isActive = true
        doneButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        doneButton.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor, constant: 0).isActive = true
        doneButton.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor, constant: 0).isActive = true
        
        // if time picker format is 12 hour, we'll need an extra tableview for am/pm
        // the width for this tableview will be 60, so we need extra -30 for x position of hour & minute tableview
        // hour table view
        hourTableView = UITableView(frame: CGRect.zero, style: .plain)
        hourTableView.rowHeight = 36
        hourTableView.showsVerticalScrollIndicator = false
        hourTableView.separatorStyle = .none
        hourTableView.delegate = self
        hourTableView.dataSource = self
        hourTableView.isHidden = isDatePickerOnly
        contentView.addSubview(hourTableView)
		
        hourTableView.translatesAutoresizingMaskIntoConstraints = false
        hourTableView.topAnchor.constraint(equalTo: borderBottomView.bottomAnchor, constant: 1).isActive = true
        hourTableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -8).isActive = true
        let extraSpace: CGFloat = is12HourFormat ? -30 : 0
        hourTableView.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: extraSpace).isActive = true
        hourTableView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        hourTableView.layoutIfNeeded()
        
        // minute table view
        minuteTableView = UITableView(frame: CGRect.zero, style: .plain)
        minuteTableView.rowHeight = 36
        minuteTableView.showsVerticalScrollIndicator = false
        minuteTableView.separatorStyle = .none
        minuteTableView.delegate = self
        minuteTableView.dataSource = self
        minuteTableView.isHidden = isDatePickerOnly
        contentView.addSubview(minuteTableView)
        
        minuteTableView.translatesAutoresizingMaskIntoConstraints = false
        minuteTableView.topAnchor.constraint(equalTo: borderBottomView.bottomAnchor, constant: 1).isActive = true
        minuteTableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -8).isActive = true
        minuteTableView.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: extraSpace).isActive = true
        minuteTableView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        minuteTableView.layoutIfNeeded()
        if timeInterval != .default {
            minuteTableView.contentInset = UIEdgeInsets.init(top: minuteTableView.frame.height / 2, left: 0, bottom: minuteTableView.frame.height / 2, right: 0)
        } else {
            minuteTableView.contentInset = UIEdgeInsets.zero
        }
        
        // am/pm table view
        amPmTableView = UITableView(frame: CGRect.zero, style: .plain)
        amPmTableView.rowHeight = 36
        amPmTableView.showsVerticalScrollIndicator = false
        amPmTableView.separatorStyle = .none
        amPmTableView.delegate = self
        amPmTableView.dataSource = self
        amPmTableView.isHidden = !is12HourFormat || isDatePickerOnly
        contentView.addSubview(amPmTableView)
        
        amPmTableView.translatesAutoresizingMaskIntoConstraints = false
        amPmTableView.topAnchor.constraint(equalTo: borderBottomView.bottomAnchor, constant: 1).isActive = true
        amPmTableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -8).isActive = true
        amPmTableView.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -extraSpace).isActive = true
        amPmTableView.widthAnchor.constraint(equalToConstant: 64).isActive = true
        
        amPmTableView.layoutIfNeeded()
        amPmTableView.contentInset = UIEdgeInsets.init(top: amPmTableView.frame.height / 2, left: 0, bottom: amPmTableView.frame.height / 2, right: 0)
        
        // colon
        colonLabel1 = UILabel(frame: CGRect.zero)
        colonLabel1.text = ":"
        colonLabel1.font = UIFont.boldSystemFont(ofSize: 18)
        colonLabel1.textColor = highlightColor
        colonLabel1.textAlignment = .center
        colonLabel1.isHidden = isDatePickerOnly
        contentView.addSubview(colonLabel1)
        
        colonLabel1.translatesAutoresizingMaskIntoConstraints = false
        colonLabel1.centerYAnchor.constraint(equalTo: minuteTableView.centerYAnchor, constant: 0).isActive = true
        colonLabel1.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: extraSpace).isActive = true
        
        colonLabel2 = UILabel(frame: CGRect.zero)
        colonLabel2.text = ":"
        colonLabel2.font = UIFont.boldSystemFont(ofSize: 18)
        colonLabel2.textColor = highlightColor
        colonLabel2.textAlignment = .center
        colonLabel2.isHidden = !is12HourFormat || isDatePickerOnly
        contentView.addSubview(colonLabel2)
		
        colonLabel2.translatesAutoresizingMaskIntoConstraints = false
        colonLabel2.centerYAnchor.constraint(equalTo: colonLabel1.centerYAnchor).isActive = true
        colonLabel2.centerXAnchor.constraint(equalTo: colonLabel1.centerXAnchor, constant: 57).isActive = true
        
        // time separators
        separatorTopView = UIView(frame: CGRect.zero)
        separatorTopView.backgroundColor = darkColor.withAlphaComponent(0.2)
        separatorTopView.isHidden = isDatePickerOnly
        contentView.addSubview(separatorTopView)
		
        separatorTopView.translatesAutoresizingMaskIntoConstraints = false
        separatorTopView.centerYAnchor.constraint(equalTo: borderBottomView.topAnchor, constant: 36).isActive = true
        separatorTopView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separatorTopView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        separatorTopView.widthAnchor.constraint(equalToConstant: 90 - extraSpace * 2).isActive = true
		
        separatorBottomView = UIView(frame: CGRect.zero)
        separatorBottomView.backgroundColor = darkColor.withAlphaComponent(0.2)
        separatorBottomView.isHidden = isDatePickerOnly
        contentView.addSubview(separatorBottomView)
		
        separatorBottomView.translatesAutoresizingMaskIntoConstraints = false
        separatorBottomView.centerYAnchor.constraint(equalTo: separatorTopView.topAnchor, constant: 36).isActive = true
        separatorBottomView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separatorBottomView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        separatorBottomView.widthAnchor.constraint(equalToConstant: 90 - extraSpace * 2).isActive = true
		
        // fill date
        fillDates(fromDate: minimumDate, toDate: maximumDate)
        updateCollectionView(to: selectedDate)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/YYYY"
        for i in 0..<dates.count {
            let date = dates[i]
            if formatter.string(from: date) == formatter.string(from: selectedDate) {
                dayCollectionView.selectItem(at: IndexPath(row: i, section: 0), animated: true, scrollPosition: .centeredHorizontally)
                break
            }
        }
        components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: selectedDate)
        contentView.isHidden = false
        
		layoutIfNeeded()
        resetTime()
    }
    
    
    @objc
    func setToday() {
        selectedDate = Date()
        resetTime()
    }
    
    func resetTime() {
        components = calendar.dateComponents([.day, .month, .year, .hour, .minute], from: selectedDate)
        updateCollectionView(to: selectedDate)
        if let hour = components.hour {
            var expectedRow = hour + 24
            if is12HourFormat {
                if hour < 12 {
                    expectedRow = hour + 11
                } else {
                    expectedRow = hour - 1
                }
                
                // workaround to fix issue selecting row when hour 12 am/pm
                if expectedRow == 11 {
                    expectedRow = 23
                }
            }
            hourTableView.selectRow(at: IndexPath(row: expectedRow, section: 0), animated: true, scrollPosition: .middle)
            if hour >= 12 {
                amPmTableView.selectRow(at: IndexPath(row: 1, section: 0), animated: true, scrollPosition: .middle)
            } else {
                amPmTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .middle)
            }
        }
        
        if let minute = components.minute {
            var expectedRow = minute / timeInterval.rawValue
            if timeInterval == .default {
                expectedRow = expectedRow == 0 ? 120 : expectedRow + 60 // workaround for issue when minute = 0
            }
            
            minuteTableView.selectRow(at: IndexPath(row: expectedRow, section: 0), animated: true, scrollPosition: .middle)
        }
    }
    
    private func resetDateTitle() {
        guard dateTitleLabel != nil else {
            return
        }
    
        dateTitleLabel.text = selectedDateString
    }
    
    func fillDates(fromDate: Date, toDate: Date) {
        
        var dates: [Date] = []
        var days = DateComponents()
        
        var dayCount = 0
        repeat {
            days.day = dayCount
            dayCount += 1
            guard let date = calendar.date(byAdding: days, to: fromDate) else {
                break;
            }
            if date.compare(toDate) == .orderedDescending {
                break
            }
            dates.append(date)
        } while (true)
        
        self.dates = dates
        dayCollectionView.reloadData()
        
        if let index = self.dates.index(of: selectedDate) {
            dayCollectionView.selectItem(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        }
    }
    
    func updateCollectionView(to currentDate: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/YYYY"
        for i in 0..<dates.count {
            let date = dates[i]
            if formatter.string(from: date) == formatter.string(from: currentDate) {
                let indexPath = IndexPath(row: i, section: 0)
                dayCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { 
                    self.dayCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
                })
                
                break
            }
        }
    }
    
    @objc
    public func dismissView(sender: UIButton?=nil) {
        modalCloseHandler?()
        dismissHandler?()
    }
    
    @objc
    public func donePicking(sender: UIButton?=nil) {
        completionHandler?(selectedDate)
        modalCloseHandler?()
        dismissHandler?()
    }
}

extension DateTimePicker: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == hourTableView {
            // need triple of origin storage to scroll infinitely
            return (is12HourFormat ? 12 : 24) * 3
        } else if tableView == amPmTableView {
            return 2
        }
        
        if timeInterval != .default {
            return 60 / timeInterval.rawValue
        }
        // need triple of origin storage to scroll infinitely
        return 60 * 3
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "timeCell") ?? UITableViewCell(style: .default, reuseIdentifier: "timeCell")
        
        cell.selectedBackgroundView = UIView()
        cell.textLabel?.textAlignment = tableView == hourTableView ? .right : .left
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        cell.textLabel?.textColor = darkColor.withAlphaComponent(0.4)
        cell.textLabel?.highlightedTextColor = highlightColor
        // add module operation to set value same
        if tableView == amPmTableView {
            cell.textLabel?.text = (indexPath.row == 0) ? "AM" : "PM"
        } else if tableView == minuteTableView{
            if timeInterval == .default {
                cell.textLabel?.text = String(format: "%02i", indexPath.row % 60)
            } else {
                cell.textLabel?.text = String(format: "%02i", indexPath.row * timeInterval.rawValue)
            }
            
        } else {
            if is12HourFormat {
                cell.textLabel?.text = String(format: "%02i", (indexPath.row % 12) + 1)
            } else {
                cell.textLabel?.text = String(format: "%02i", indexPath.row % 24)
            }
        }
        
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selectedRow = indexPath.row
        var shouldAnimate = true
        
        // adjust selected row number for inifinite scrolling
        if selectedRow != adjustedRowForInfiniteScrolling(tableView: tableView, selectedRow: selectedRow) {
            selectedRow = adjustedRowForInfiniteScrolling(tableView: tableView, selectedRow: selectedRow)
            shouldAnimate = false
        }
        
        tableView.selectRow(at: IndexPath(row: selectedRow, section: 0), animated: shouldAnimate, scrollPosition: .middle)
        if tableView == hourTableView {
            if is12HourFormat {
                components.hour = indexPath.row < 12 ? indexPath.row + 1 : (indexPath.row - 12)%12 + 1
                if let hour = components.hour,
                    amPmTableView.indexPathForSelectedRow?.row == 0 && hour >= 12 {
                    components.hour! -= 12
                } else if let hour = components.hour,
                    amPmTableView.indexPathForSelectedRow?.row == 1 && hour < 12 {
                    components.hour! += 12
                }
            } else {
                components.hour = indexPath.row < 24 ? indexPath.row : (indexPath.row - 24)%24
            }
            
        } else if tableView == minuteTableView {
            if timeInterval == .default {
                components.minute = indexPath.row < 60 ? indexPath.row : (indexPath.row - 60)%60
            } else {
                components.minute = indexPath.row * timeInterval.rawValue
            }
            
        } else if tableView == amPmTableView {
            if let hour = components.hour,
                indexPath.row == 0 && hour >= 12 {
                components.hour = hour - 12
            } else if let hour = components.hour,
                indexPath.row == 1 && hour < 12 {
                components.hour = hour + 12
            }
        }
        
        if let selected = calendar.date(from: components) {
            if selected.compare(minimumDate) == .orderedAscending {
                selectedDate = minimumDate
                resetTime()
            } else {
                selectedDate = selected
            }
        }
    }
    
}

extension DateTimePicker: UICollectionViewDataSource, UICollectionViewDelegate {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dates.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if includeMonth {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dateCell", for: indexPath) as! FullDateCollectionViewCell
            let date = dates[indexPath.item]
            cell.populateItem(date: date, highlightColor: highlightColor, darkColor: darkColor, locale: locale)

            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dateCell", for: indexPath) as! DateCollectionViewCell
            let date = dates[indexPath.item]
            cell.populateItem(date: date, highlightColor: highlightColor, darkColor: darkColor, locale: locale)

            return cell
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //workaround to center to every cell including ones near margins
        if let cell = collectionView.cellForItem(at: indexPath) {
            let offset = CGPoint(x: cell.center.x - collectionView.frame.width / 2, y: 0)
            collectionView.setContentOffset(offset, animated: true)
        }
        
        // update selected dates
        let date = dates[indexPath.item]
        let dayComponent = calendar.dateComponents([.day, .month, .year], from: date)
        components.day = dayComponent.day
        components.month = dayComponent.month
        components.year = dayComponent.year
        if let selected = calendar.date(from: components) {
            if selected.compare(minimumDate) == .orderedAscending {
                selectedDate = minimumDate
                resetTime()
            } else {
                selectedDate = selected
            }
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        alignScrollView(scrollView)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            alignScrollView(scrollView)
        }
    }
    
    func alignScrollView(_ scrollView: UIScrollView) {
        if let collectionView = scrollView as? UICollectionView {
            let centerPoint = CGPoint(x: collectionView.center.x + collectionView.contentOffset.x, y: 50);
            if let indexPath = collectionView.indexPathForItem(at: centerPoint) {
                // automatically select this item and center it to the screen
                // set animated = false to avoid unwanted effects
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
                if let cell = collectionView.cellForItem(at: indexPath) {
                    let offset = CGPoint(x: cell.center.x - collectionView.frame.width / 2, y: 0)
                    collectionView.setContentOffset(offset, animated: false)
                }
                
                // update selected date
                let date = dates[indexPath.item]
                let dayComponent = calendar.dateComponents([.day, .month, .year], from: date)
                components.day = dayComponent.day
                components.month = dayComponent.month
                components.year = dayComponent.year
                if let selected = calendar.date(from: components) {
                    if selected.compare(minimumDate) == .orderedAscending {
                        selectedDate = minimumDate
                        resetTime()
                    } else {
                        selectedDate = selected
                    }
                }
            }
        } else if let tableView = scrollView as? UITableView {
            
            var selectedRow = 0
            if let firstVisibleCell = tableView.visibleCells.first,
                tableView != amPmTableView {
                var firstVisibleRow = 0
                if tableView.contentOffset.y >= firstVisibleCell.frame.origin.y + tableView.rowHeight/2 - tableView.contentInset.top {
                    firstVisibleRow = (tableView.indexPath(for: firstVisibleCell)?.row ?? 0) + 1
                } else {
                    firstVisibleRow = (tableView.indexPath(for: firstVisibleCell)?.row ?? 0)
                }
                if tableView == minuteTableView && timeInterval != .default {
                    selectedRow = min(max(firstVisibleRow, 0), self.tableView(tableView, numberOfRowsInSection: 0)-1)
                } else {
                    selectedRow = firstVisibleRow + 1
                }
                
                // adjust selected row number for inifinite scrolling
                selectedRow = adjustedRowForInfiniteScrolling(tableView: tableView, selectedRow: selectedRow)
                
            } else if tableView == amPmTableView {
                if -tableView.contentOffset.y > tableView.rowHeight/2 {
                    selectedRow = 0
                } else {
                    selectedRow = 1
                }
            }
            
            tableView.selectRow(at: IndexPath(row: selectedRow, section: 0), animated: false, scrollPosition: .middle)
            if tableView == hourTableView {
                if is12HourFormat {
                    components.hour = selectedRow < 12 ? selectedRow + 1 : (selectedRow - 12)%12 + 1
                    if let hour = components.hour,
                        amPmTableView.indexPathForSelectedRow?.row == 0 && hour >= 12 {
                        components.hour! -= 12
                    } else if let hour = components.hour,
                        amPmTableView.indexPathForSelectedRow?.row == 1 && hour < 12 {
                        components.hour! += 12
                    }
                } else {
                    components.hour = selectedRow < 24 ? selectedRow : (selectedRow - 24)%24
                }
                
            } else if tableView == minuteTableView {
                if timeInterval == .default {
                    components.minute = selectedRow < 60 ? selectedRow : (selectedRow - 60)%60
                } else {
                    components.minute = selectedRow * timeInterval.rawValue
                }
            } else if tableView == amPmTableView {
                if let hour = components.hour,
                    selectedRow == 0 && hour >= 12 {
                    components.hour = hour - 12
                } else if let hour = components.hour,
                    selectedRow == 1 && hour < 12 {
                    components.hour = hour + 12
                }
            }
            
            if let selected = calendar.date(from: components) {
                if selected.compare(minimumDate) == .orderedAscending {
                    selectedDate = minimumDate
                    resetTime()
                } else {
                    selectedDate = selected
                }
                
            }
        }
    }
    
    func adjustedRowForInfiniteScrolling(tableView: UITableView, selectedRow: Int) -> Int {
        if tableView == minuteTableView &&
            timeInterval != .default {
            return selectedRow
        }
        
        let numberOfRow = self.tableView(tableView, numberOfRowsInSection: 0)
        if selectedRow == 1 {
            return selectedRow + numberOfRow / 3
        } else if selectedRow == numberOfRow - 2 {
            return selectedRow - numberOfRow / 3
        }
        return selectedRow
    }
}
