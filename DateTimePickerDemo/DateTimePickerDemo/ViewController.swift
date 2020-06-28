//
//  ViewController.swift
//  DateTimePicker
//
//  Created by Huong Do on 9/16/16.
//  Copyright © 2016 ichigo. All rights reserved.
//

import UIKit
import DateTimePicker

class ViewController: UIViewController, DateTimePickerDelegate {

  @IBAction func showDateTimePicker(sender: AnyObject) {
    let min = Date().addingTimeInterval(-60 * 60 * 24 * 4)
    let max = Date().addingTimeInterval(60 * 60 * 24 * 4)
    let picker = DateTimePicker.create(minimumDate: min, maximumDate: max)

    // customize your picker
//    picker.timeInterval = DateTimePicker.MinuteInterval.thirty
//    picker.locale = Locale(identifier: "en_GB")

    picker.dateFormat = "MMM d"
    picker.dateTimeFormat = "MMM d, h:mm a"
    picker.todayButtonTitle = "Today"
    picker.is12HourFormat = true
    picker.isDatePickerOnly = true
//    picker.isTimePickerOnly = true
    picker.includesMonth = true
//    picker.includesSecond = true
    picker.highlightColor = UIColor(red: 255.0/255.0, green: 138.0/255.0, blue: 138.0/255.0, alpha: 1)
    picker.doneButtonTitle = "!! DONE DONE !!"
    picker.doneBackgroundColor = UIColor(red: 255.0/255.0, green: 138.0/255.0, blue: 138.0/255.0, alpha: 1)
//    picker.customFontSetting = DateTimePicker.CustomFontSetting(selectedDateLabelFont: .boldSystemFont(ofSize: 20))
//    if #available(iOS 13.0, *) {
//      picker.normalColor = UIColor.secondarySystemGroupedBackground
//      picker.darkColor = UIColor.label
//      picker.contentViewBackgroundColor = UIColor.systemBackground
//      picker.daysBackgroundColor = UIColor.groupTableViewBackground
//      picker.titleBackgroundColor = UIColor.secondarySystemGroupedBackground
//    } else {
//      picker.normalColor = UIColor.white
//      picker.darkColor = UIColor.black
//      picker.contentViewBackgroundColor = UIColor.white
//    }
    picker.completionHandler = { date, timeSelected in
      let formatter = DateFormatter()
      if timeSelected {
        formatter.dateFormat = "hh:mm:ss aa dd/MM/YYYY"
      }
      else {
        formatter.dateFormat = "dd/MM/YYYY"

      }
      self.title = formatter.string(from: date)
    }
    picker.delegate = self

    // add picker to your view
    // don't try to make customize width and height of the picker,
    // you'll end up with corrupted looking UI
//    picker.frame = CGRect(x: 0, y: 100, width: picker.frame.size.width, height: picker.frame.size.height)
    // set a dismissHandler if necessary
//    picker.dismissHandler = {
//      picker.removeFromSuperview()
//    }
//    self.view.addSubview(picker)

    // or show it like a modal
    picker.show()
  }

  func dateTimePicker(_ picker: DateTimePicker, didSelectDate: Date) {
    title = picker.selectedDateString
  }
}
