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
    
    public struct CustomFontSetting {
        let cancelButtonFont: UIFont
        let todayButtonFont: UIFont
        let doneButtonFont: UIFont
        let selectedDateLabelFont: UIFont
        let timeLabelFont: UIFont
        let colonLabelFont: UIFont
        let dateCellNumberLabelFont: UIFont
        let dateCellDayMonthLabelFont: UIFont
        
        static let `default` = CustomFontSetting(
            cancelButtonFont: .boldSystemFont(ofSize: 15),
            todayButtonFont: .boldSystemFont(ofSize: 15),
            doneButtonFont: .boldSystemFont(ofSize: 13),
            selectedDateLabelFont: .systemFont(ofSize: 15),
            timeLabelFont: .boldSystemFont(ofSize: 18),
            colonLabelFont: .boldSystemFont(ofSize: 18),
            dateCellNumberLabelFont: .systemFont(ofSize: 25),
            dateCellDayMonthLabelFont: .systemFont(ofSize: 10))
        
        public init(cancelButtonFont: UIFont = .boldSystemFont(ofSize: 15),
            todayButtonFont: UIFont = .boldSystemFont(ofSize: 15),
            doneButtonFont: UIFont = .boldSystemFont(ofSize: 13),
            selectedDateLabelFont: UIFont = .systemFont(ofSize: 15),
            timeLabelFont: UIFont = .boldSystemFont(ofSize: 18),
            colonLabelFont: UIFont = .boldSystemFont(ofSize: 18),
            dateCellNumberLabelFont: UIFont = .systemFont(ofSize: 25),
            dateCellDayMonthLabelFont: UIFont = .systemFont(ofSize: 10)) {
            self.cancelButtonFont = cancelButtonFont
            self.todayButtonFont = todayButtonFont
            self.doneButtonFont = doneButtonFont
            self.selectedDateLabelFont = selectedDateLabelFont
            self.timeLabelFont = timeLabelFont
            self.colonLabelFont = colonLabelFont
            self.dateCellNumberLabelFont = dateCellNumberLabelFont
            self.dateCellDayMonthLabelFont = dateCellDayMonthLabelFont
        }
    }
    
    @objc public enum MinuteInterval: Int {
        case `default` = 1
        case five = 5
        case ten = 10
        case fifteen = 15
        case twenty = 20
        case thirty = 30
    }
    
    /// custom font settings
    public var customFontSetting: CustomFontSetting = .default {
        didSet {
            configureView()
        }
    }

    /// custom normal color, default to white
    public var normalColor = UIColor.white
    
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
    /// custom Background Color Content Viewr, default to white
    public var contentViewBackgroundColor: UIColor = .white {
        didSet {
            contentView.backgroundColor = contentViewBackgroundColor
        }
    }
    /// custom background color for title
    public var titleBackgroundColor = UIColor.white {
        didSet {
            configureView()
        }
    }
    
    /// custom background color for date cells
    public var daysBackgroundColor = UIColor(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, alpha: 1) {
        didSet {
            configureView()
        }
    }
	
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
		    shadowView.alpha = 0
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.resetTime()
        }
    }
	
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let location = touch?.location(in: self) else { return }
        if !contentView.frame.contains(location) {
            dismissView(sender: nil)
        }
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
        contentView.backgroundColor = contentViewBackgroundColor
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
        titleView.backgroundColor = titleBackgroundColor
        contentView.addSubview(titleView)
        
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        titleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        titleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        titleView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        titleView.layoutMargins = UIEdgeInsets.init(top: 0, left: 20, bottom: 0, right: 20)
        
        dateTitleLabel = UILabel(frame: CGRect.zero)
        dateTitleLabel.textColor = darkColor
        dateTitleLabel.textAlignment = .center
        dateTitleLabel.font = customFontSetting.selectedDateLabelFont
        resetDateTitle()
        titleView.addSubview(dateTitleLabel)
        
        dateTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        dateTitleLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        dateTitleLabel.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        
        let isRTL = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft

        cancelButton = UIButton(type: .system)
        cancelButton.setTitle(cancelButtonTitle, for: .normal)
        cancelButton.setTitleColor(darkColor.withAlphaComponent(0.5), for: .normal)
        cancelButton.contentHorizontalAlignment = isRTL ? .right : .left
        cancelButton.addTarget(self, action: #selector(DateTimePicker.dismissView(sender:)), for: .touchUpInside)
        cancelButton.titleLabel?.font = customFontSetting.cancelButtonFont
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
        todayButton.contentHorizontalAlignment = isRTL ? .left : .right
        todayButton.titleLabel?.font = customFontSetting.todayButtonFont
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
        doneButton.titleLabel?.font = customFontSetting.doneButtonFont
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
        hourTableView.backgroundColor = .clear
        contentView.addSubview(hourTableView)
		
        hourTableView.translatesAutoresizingMaskIntoConstraints = false
        hourTableView.topAnchor.constraint(equalTo: borderBottomView.bottomAnchor, constant: 1).isActive = true
        hourTableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -8).isActive = true
        let extraSpace: CGFloat = is12HourFormat ? -30 : 0
        hourTableView.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: extraSpace).isActive = true
        hourTableView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        // minute table view
        minuteTableView = UITableView(frame: CGRect.zero, style: .plain)
        minuteTableView.rowHeight = 36
        minuteTableView.showsVerticalScrollIndicator = false
        minuteTableView.separatorStyle = .none
        minuteTableView.delegate = self
        minuteTableView.dataSource = self
        minuteTableView.isHidden = isDatePickerOnly
        minuteTableView.backgroundColor = .clear
        contentView.addSubview(minuteTableView)
        
        minuteTableView.translatesAutoresizingMaskIntoConstraints = false
        minuteTableView.topAnchor.constraint(equalTo: borderBottomView.bottomAnchor, constant: 1).isActive = true
        minuteTableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -8).isActive = true
        minuteTableView.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: extraSpace).isActive = true
        minuteTableView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
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
        amPmTableView.backgroundColor = .clear
        contentView.addSubview(amPmTableView)
        
        amPmTableView.translatesAutoresizingMaskIntoConstraints = false
        amPmTableView.topAnchor.constraint(equalTo: borderBottomView.bottomAnchor, constant: 1).isActive = true
        amPmTableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -8).isActive = true
        amPmTableView.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -extraSpace).isActive = true
        amPmTableView.widthAnchor.constraint(equalToConstant: 64).isActive = true
        amPmTableView.contentInset = UIEdgeInsets(top: 36, left: 0, bottom: 36, right: 0)
        
        // colon
        colonLabel1 = UILabel(frame: CGRect.zero)
        colonLabel1.text = ":"
        colonLabel1.font = customFontSetting.colonLabelFont
        colonLabel1.textColor = highlightColor
        colonLabel1.backgroundColor = .clear
        colonLabel1.textAlignment = .center
        colonLabel1.isHidden = isDatePickerOnly
        contentView.addSubview(colonLabel1)
        
        colonLabel1.translatesAutoresizingMaskIntoConstraints = false
        colonLabel1.centerYAnchor.constraint(equalTo: minuteTableView.centerYAnchor, constant: 0).isActive = true
        colonLabel1.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: extraSpace).isActive = true
        
        colonLabel2 = UILabel(frame: CGRect.zero)
        colonLabel2.text = ":"
        colonLabel1.font = customFontSetting.colonLabelFont
        colonLabel2.textColor = highlightColor
        colonLabel2.backgroundColor = .clear
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
        
        resetTime()
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
}

private extension DateTimePicker {
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
        
        if let index = self.dates.firstIndex(of: selectedDate) {
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
    
    func resetDateTitle() {
        guard dateTitleLabel != nil else {
            return
        }
    
        dateTitleLabel.text = selectedDateString
    }
    
    @objc
    func setToday() {
        selectedDate = Date()
        resetTime()
    }
}
