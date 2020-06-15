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
    let toggleModeButtonFont: UIFont

    static let `default` = CustomFontSetting(
      cancelButtonFont: .boldSystemFont(ofSize: 15),
      todayButtonFont: .boldSystemFont(ofSize: 15),
      doneButtonFont: .boldSystemFont(ofSize: 13),
      selectedDateLabelFont: .systemFont(ofSize: 15),
      timeLabelFont: .boldSystemFont(ofSize: 18),
      colonLabelFont: .boldSystemFont(ofSize: 18),
      dateCellNumberLabelFont: .systemFont(ofSize: 25),
      dateCellDayMonthLabelFont: .systemFont(ofSize: 10),
      toggleModeButtonFont: .systemFont(ofSize: 15, weight: .light)
    )

    public init(cancelButtonFont: UIFont = .boldSystemFont(ofSize: 15),
                todayButtonFont: UIFont = .boldSystemFont(ofSize: 15),
                doneButtonFont: UIFont = .boldSystemFont(ofSize: 13),
                selectedDateLabelFont: UIFont = .systemFont(ofSize: 15),
                timeLabelFont: UIFont = .boldSystemFont(ofSize: 18),
                colonLabelFont: UIFont = .boldSystemFont(ofSize: 18),
                dateCellNumberLabelFont: UIFont = .systemFont(ofSize: 25),
                dateCellDayMonthLabelFont: UIFont = .systemFont(ofSize: 10),
                toggleModeButtonFont: UIFont = .systemFont(ofSize: 15, weight: .light)) {
      self.cancelButtonFont = cancelButtonFont
      self.todayButtonFont = todayButtonFont
      self.doneButtonFont = doneButtonFont
      self.selectedDateLabelFont = selectedDateLabelFont
      self.timeLabelFont = timeLabelFont
      self.colonLabelFont = colonLabelFont
      self.dateCellNumberLabelFont = dateCellNumberLabelFont
      self.dateCellDayMonthLabelFont = dateCellDayMonthLabelFont
      self.toggleModeButtonFont = toggleModeButtonFont
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

  /// whether to include second in time selection, default to false
  public var includesSecond = false {
    didSet {
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
  public var includesMonth = false {
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

  public var timeZone: TimeZone = .current
  public var calendar: Calendar = .current

  public var completionHandler: ((Date)->Void)?
  public var dismissHandler: (() -> Void)?
  public weak var delegate: DateTimePickerDelegate?

  // internal & private vars
  @IBOutlet var hourTableView: UITableView!
  @IBOutlet var minuteTableView: UITableView!
  @IBOutlet var secondTableView: UITableView!
  @IBOutlet var amPmTableView: UITableView!
  @IBOutlet var dayCollectionView: UICollectionView!

  @IBOutlet private var contentView: UIView!
  @IBOutlet private var titleView: UIView!
  @IBOutlet private var dateTitleLabel: UILabel!
  @IBOutlet private var todayButton: UIButton!
  @IBOutlet private var doneButton: UIButton!
  @IBOutlet private var cancelButton: UIButton!
  @IBOutlet private var colonLabel1: UILabel!
  @IBOutlet private var colonLabel2: UILabel!

  @IBOutlet private var setTimeButton: UIButton!
  @IBOutlet private var setDateButton: UIButton!

  @IBOutlet private var timeView: UIView!
  @IBOutlet private var borderTopView: UIView!
  @IBOutlet private var borderBottomView: UIView!
  @IBOutlet private var separatorTopView: UIView!
  @IBOutlet private var separatorBottomView: UIView!

  // constraints
  @IBOutlet private var contentViewHeight: NSLayoutConstraint!
  @IBOutlet private var separatorBottomViewWidth: NSLayoutConstraint!
  @IBOutlet private var separatorTopViewWidth: NSLayoutConstraint!

  private var modalCloseHandler: (() -> Void)?

  internal var minimumDate: Date!
  internal var maximumDate: Date!

  internal var dates: [Date]! = []
  internal var components: DateComponents! {
    didSet {
      components.timeZone = timeZone
    }
  }

  private static var resourceBundle: Bundle? {
    let podBundle = Bundle(for: DateTimePicker.self)
    guard let bundleURL = podBundle.url(forResource: "DateTimePicker", withExtension: "bundle") else {
      return Bundle.main
    }
    return Bundle(url: bundleURL)
  }

  @objc open class func create(minimumDate: Date? = nil, maximumDate: Date? = nil) -> DateTimePicker {

    guard let dateTimePicker = resourceBundle?.loadNibNamed("DateTimePicker", owner: nil, options: nil)?.first as? DateTimePicker else {
      fatalError("Error loading nib")
    }
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
    contentHeight = isDatePickerOnly ? 274 : isTimePickerOnly ? 274 : 330

    contentView.layer.shadowColor = UIColor(white: 0, alpha: 0.3).cgColor
    contentView.layer.shadowOffset = CGSize(width: 0, height: -2.0)
    contentView.layer.shadowRadius = 1.5
    contentView.layer.shadowOpacity = 0.5
    contentView.backgroundColor = contentViewBackgroundColor
    contentView.isHidden = true
    contentViewHeight.constant = contentHeight

    // title view
    titleView.backgroundColor = titleBackgroundColor

    dateTitleLabel.textColor = darkColor
    dateTitleLabel.textAlignment = .center
    dateTitleLabel.font = customFontSetting.selectedDateLabelFont
    resetDateTitle()

    let isRTL = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft

    cancelButton.setTitle(cancelButtonTitle, for: .normal)
    cancelButton.setTitleColor(darkColor.withAlphaComponent(0.5), for: .normal)
    cancelButton.contentHorizontalAlignment = isRTL ? .right : .left
    cancelButton.titleLabel?.font = customFontSetting.cancelButtonFont
    cancelButton.addTarget(self, action: #selector(DateTimePicker.dismissView(sender:)), for: .touchUpInside)

    todayButton.setTitle(todayButtonTitle, for: .normal)
    todayButton.setTitleColor(highlightColor, for: .normal)
    todayButton.contentHorizontalAlignment = isRTL ? .left : .right
    todayButton.titleLabel?.font = customFontSetting.todayButtonFont
    todayButton.addTarget(self, action: #selector(DateTimePicker.setToday), for: .touchUpInside)
    todayButton.isHidden = self.minimumDate.compare(Date()) == .orderedDescending || self.maximumDate.compare(Date()) == .orderedAscending

    setTimeButton.setTitleColor(darkColor, for: .normal)
    setTimeButton.contentHorizontalAlignment = .left
    setTimeButton.titleLabel?.font = customFontSetting.toggleModeButtonFont
    setTimeButton.addTarget(self, action: #selector(DateTimePicker.toggleTime), for: .touchUpInside)
    setTimeButton.isHidden = !isDatePickerOnly

    setDateButton.setTitleColor(darkColor, for: .normal)
    setDateButton.contentHorizontalAlignment = .left
    setDateButton.titleLabel?.font = customFontSetting.toggleModeButtonFont
    setDateButton.addTarget(self, action: #selector(DateTimePicker.toggleDate), for: .touchUpInside)
    setDateButton.isHidden = !isTimePickerOnly

    // day collection view
    dayCollectionView.backgroundColor = daysBackgroundColor
    dayCollectionView.showsHorizontalScrollIndicator = false
    if let layout = dayCollectionView.collectionViewLayout as? StepCollectionViewFlowLayout {
      layout.scrollDirection = .horizontal
      layout.minimumInteritemSpacing = 10
      layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
      layout.itemSize = CGSize(width: 75, height: 80)
    }
    dayCollectionView.register(UINib(nibName: "FullDateCollectionViewCell", bundle: DateTimePicker.resourceBundle), forCellWithReuseIdentifier: "dateCell")
    dayCollectionView.dataSource = self
    dayCollectionView.delegate = self
    dayCollectionView.isHidden = isTimePickerOnly
    dayCollectionView.layoutIfNeeded()
    let inset = (dayCollectionView.frame.width - 75) / 2
    dayCollectionView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)

    // top & bottom borders on day collection view
    borderTopView.backgroundColor = darkColor.withAlphaComponent(0.2)
    borderBottomView.backgroundColor = darkColor.withAlphaComponent(0.2)
    borderBottomView.isHidden = isTimePickerOnly || isDatePickerOnly

    // done button
    doneButton.setTitle(doneButtonTitle, for: .normal)
    doneButton.setTitleColor(.white, for: .normal)
    doneButton.backgroundColor = doneBackgroundColor ?? darkColor.withAlphaComponent(0.5)
    doneButton.titleLabel?.font = customFontSetting.doneButtonFont
    doneButton.layer.cornerRadius = 3
    doneButton.layer.masksToBounds = true
    doneButton.addTarget(self, action: #selector(DateTimePicker.donePicking(sender:)), for: .touchUpInside)

    // hour table view
    hourTableView.rowHeight = 36
    hourTableView.showsVerticalScrollIndicator = false
    hourTableView.separatorStyle = .none
    hourTableView.delegate = self
    hourTableView.dataSource = self
    hourTableView.isHidden = isDatePickerOnly
    hourTableView.backgroundColor = .clear

    // minute table view
    minuteTableView.rowHeight = 36
    minuteTableView.showsVerticalScrollIndicator = false
    minuteTableView.separatorStyle = .none
    minuteTableView.delegate = self
    minuteTableView.dataSource = self
    minuteTableView.isHidden = isDatePickerOnly
    minuteTableView.backgroundColor = .clear

    if timeInterval != .default {
      minuteTableView.contentInset = UIEdgeInsets.init(top: minuteTableView.frame.height / 2, left: 0, bottom: minuteTableView.frame.height / 2, right: 0)
    } else {
      minuteTableView.contentInset = UIEdgeInsets.zero
    }

    // second table view
    secondTableView.rowHeight = 36
    secondTableView.showsVerticalScrollIndicator = false
    secondTableView.separatorStyle = .none
    secondTableView.delegate = self
    secondTableView.dataSource = self
    secondTableView.isHidden = isDatePickerOnly || !includesSecond
    secondTableView.backgroundColor = .clear

    // am/pm table view
    amPmTableView.rowHeight = 36
    amPmTableView.showsVerticalScrollIndicator = false
    amPmTableView.separatorStyle = .none
    amPmTableView.delegate = self
    amPmTableView.dataSource = self
    amPmTableView.isHidden = !is12HourFormat || isDatePickerOnly
    amPmTableView.backgroundColor = .clear
    amPmTableView.contentInset = UIEdgeInsets(top: 41, left: 0, bottom: 41, right: 0)

    // colon
    colonLabel1.font = customFontSetting.colonLabelFont
    colonLabel1.textColor = highlightColor
    colonLabel1.backgroundColor = .clear
    colonLabel1.textAlignment = .center
    colonLabel1.isHidden = isDatePickerOnly

    colonLabel2.font = customFontSetting.colonLabelFont
    colonLabel2.textColor = highlightColor
    colonLabel2.backgroundColor = .clear
    colonLabel2.textAlignment = .center
    colonLabel2.isHidden = isDatePickerOnly || !includesSecond

    // time separators
    var separatorWidth: CGFloat = 0
    switch (is12HourFormat, includesSecond) {
    case (true, true):
      separatorWidth = 260
    case (true, false),
         (false, true):
      separatorWidth = 200
    case (false, false):
      separatorWidth = 130
    }

    separatorTopView.backgroundColor = darkColor.withAlphaComponent(0.2)
    separatorTopView.isHidden = isDatePickerOnly || isTimePickerOnly
    separatorBottomView.backgroundColor = darkColor.withAlphaComponent(0.2)
    separatorBottomView.isHidden = isDatePickerOnly || isTimePickerOnly

    separatorBottomViewWidth.constant = separatorWidth
    separatorTopViewWidth.constant = separatorWidth

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

    // Small delay to allow graphics to catch up
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      self.resetTime()
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

  func resetTime() {
    components = calendar.dateComponents([.day, .month, .year, .hour, .minute, .second], from: selectedDate)
    updateCollectionView(to: selectedDate)
    if let hour = components.hour {
      print(hour)
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

    if let second = components.second {
      let expectedRow = second == 0 ? 120 : second + 60
      secondTableView.selectRow(at: IndexPath(row: expectedRow, section: 0), animated: true, scrollPosition: .middle)
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

  @objc func setToday() {
    selectedDate = Date()
    resetTime()
  }
}

private extension DateTimePicker {

  @objc func toggleDate() {
    isDatePickerOnly = !isDatePickerOnly
  }

  @objc func toggleTime() {
    isTimePickerOnly = !isTimePickerOnly
  }
}
