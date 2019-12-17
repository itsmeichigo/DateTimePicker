//
//  DateCollectionViewCell.swift
//  DateTimePicker
//
//  Created by Huong Do on 9/26/16.
//  Copyright © 2016 ichigo. All rights reserved.
//

import UIKit

class DateCollectionViewCell: UICollectionViewCell {
    struct Style {
        let highlightColor: UIColor
        let normalColor: UIColor
        let darkColor: UIColor
        let dayLabelFont: UIFont
        let numberLabelFont: UIFont
    }
    
    var dayLabel: UILabel! // rgb(128,138,147)
    var numberLabel: UILabel!
    var darkColor = UIColor(red: 0, green: 22.0/255.0, blue: 39.0/255.0, alpha: 1)
    var highlightColor = UIColor(red: 0/255.0, green: 199.0/255.0, blue: 194.0/255.0, alpha: 1)
    var normalColor = UIColor.white
    
    override init(frame: CGRect) {
        dayLabel = UILabel(frame: CGRect(x: 5, y: 15, width: frame.width - 10, height: 20))
        dayLabel.textAlignment = .center
    
        numberLabel = UILabel(frame: CGRect(x: 5, y: 30, width: frame.width - 10, height: 40))
        numberLabel.textAlignment = .center
        
        super.init(frame: frame)
        
        contentView.addSubview(dayLabel)
        contentView.addSubview(numberLabel)
        contentView.backgroundColor = normalColor
        contentView.layer.cornerRadius = 3
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            dayLabel.textColor = isSelected == true ? .white : darkColor.withAlphaComponent(0.5)
            numberLabel.textColor = isSelected == true ? .white : darkColor
            contentView.backgroundColor = isSelected == true ? highlightColor : normalColor
            contentView.layer.borderWidth = isSelected == true ? 0 : 1
        }
    }
    
    func populateItem(date: Date, style: Style, locale: Locale) {
        self.highlightColor = style.highlightColor
        self.normalColor = style.normalColor
        self.darkColor = style.darkColor
        
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
