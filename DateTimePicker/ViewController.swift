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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func showDateTimePicker(sender: AnyObject) {
        let picker = DateTimePicker.show(minimumDate: Date(), maximumDate: Date(timeIntervalSinceNow: 3600 * 24 * 365 * 10))
        picker.highlightColor = UIColor(red: 255.0/255.0, green: 138.0/255.0, blue: 138.0/255.0, alpha: 1)
        picker.completionHandler = { date in
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm dd/MM/YYYY"
            self.item.title = formatter.string(from: date)
        }
    }

}

