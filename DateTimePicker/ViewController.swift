//
//  ViewController.swift
//  DateTimePicker
//
//  Created by Huong Do on 9/16/16.
//  Copyright © 2016 ichigo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var item: UINavigationItem!
    var now = Date()

    @IBAction func showDateTimePicker(sender: AnyObject) {
        let min = now.addingTimeInterval(-60 * 60 * 24 * 365)
        let max = now.addingTimeInterval(60 * 60 * 24 * 365)
        let picker = DateTimePicker.show(selected: self.now, minimumDate: min, maximumDate: max, timeInterval: 10)
        picker.highlightColor = UIColor(red: 255.0/255.0, green: 138.0/255.0, blue: 138.0/255.0, alpha: 1)
        picker.doneButtonTitle = "!! DONE DONE !!"
        picker.todayButtonTitle = "Today👌Today"
        picker.completionHandler = { date in
            self.now = date
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm dd/MM/YYYY"
            self.item.title = formatter.string(from: date)
        }
    }

}

