//
//  FullDateCollectionViewCell.swift
//  DateTimePicker
//
//  Created by Jess Chandler on 10/14/17.
//  Copyright © 2017 ichigo. All rights reserved.
//

import UIKit

class FullDateCollectionViewCell: UICollectionViewCell {
    
    struct Style {
        let highlightColor: UIColor
        let normalColor: UIColor
        let darkColor: UIColor
        let dayLabelFont: UIFont
        let numberLabelFont: UIFont
        let monthLabelFont: UIFont
    }
    
    @IBOutlet var monthLabel: UILabel!
    @IBOutlet var dayLabel: UILabel! // rgb(128,138,147)
    @IBOutlet var numberLabel: UILabel!
    
    var darkColor = UIColor(red: 0, green: 22.0/255.0, blue: 39.0/255.0, alpha: 1)
    var highlightColor = UIColor(red: 0/255.0, green: 199.0/255.0, blue: 194.0/255.0, alpha: 1)
    var normalColor = UIColor.white
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = normalColor
        contentView.layer.cornerRadius = 3
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 1
    }

    override var isSelected: Bool {
        didSet {
            monthLabel.textColor = isSelected == true ? .white : darkColor.withAlphaComponent(0.5)
            dayLabel.textColor = isSelected == true ? .white : darkColor.withAlphaComponent(0.5)
            numberLabel.textColor = isSelected == true ? .white : darkColor
            contentView.backgroundColor = isSelected == true ? highlightColor : normalColor
            contentView.layer.borderWidth = isSelected == true ? 0 : 1
        }
    }

    func populateItem(date: Date, style: Style, locale: Locale, includesMonth: Bool) {
        self.highlightColor = style.highlightColor
        self.normalColor = style.normalColor
        self.darkColor = style.darkColor

        let mdateFormatter = DateFormatter()
        mdateFormatter.dateFormat = "MMMM"
        mdateFormatter.locale = locale
        monthLabel.text = mdateFormatter.string(from: date)
        monthLabel.textColor = isSelected == true ? .white : darkColor.withAlphaComponent(0.5)
        monthLabel.font = style.monthLabelFont
        monthLabel.isHidden = !includesMonth

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.locale = locale
        dayLabel.text = dateFormatter.string(from: date).uppercased()
        dayLabel.textColor = isSelected == true ? .white : darkColor.withAlphaComponent(0.5)
        dayLabel.font = style.dayLabelFont

        let numberFormatter = DateFormatter()
        numberFormatter.dateFormat = "d"
        numberFormatter.locale = locale
        numberLabel.text = numberFormatter.string(from: date)
        numberLabel.textColor = isSelected == true ? .white : darkColor
        numberLabel.font = style.numberLabelFont

        contentView.layer.borderColor = darkColor.withAlphaComponent(0.2).cgColor
        contentView.backgroundColor = isSelected == true ? highlightColor : normalColor
    }

}
