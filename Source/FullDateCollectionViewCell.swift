//
//  FullDateCollectionViewCell.swift
//  DateTimePicker
//
//  Created by Jess Chandler on 10/14/17.
//  Copyright © 2017 ichigo. All rights reserved.
//

import UIKit

class FullDateCollectionViewCell: UICollectionViewCell {
    var monthLabel: UILabel!
    var dayLabel: UILabel! // rgb(128,138,147)
    var numberLabel: UILabel!
    var darkColor = UIColor(red: 0, green: 22.0/255.0, blue: 39.0/255.0, alpha: 1)
    var highlightColor = UIColor(red: 0/255.0, green: 199.0/255.0, blue: 194.0/255.0, alpha: 1)


    override init(frame: CGRect) {

        dayLabel = UILabel(frame: CGRect(x: 5, y: 7, width: frame.width - 10, height: 20))
        dayLabel.font = UIFont.systemFont(ofSize: 10)
        dayLabel.textAlignment = .center

        numberLabel = UILabel(frame: CGRect(x: 5, y: 20, width: frame.width - 10, height: 40))
        numberLabel.font = UIFont.systemFont(ofSize: 25)
        numberLabel.textAlignment = .center

        monthLabel = UILabel(frame: CGRect(x: 5, y: 53, width: frame.width - 10, height: 20))
        monthLabel.font = UIFont.boldSystemFont(ofSize: 10)
        monthLabel.textAlignment = .center
        
        super.init(frame: frame)

        contentView.addSubview(monthLabel)
        contentView.addSubview(dayLabel)
        contentView.addSubview(numberLabel)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 3
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 1
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isSelected: Bool {
        didSet {
            monthLabel.textColor = isSelected == true ? .white : darkColor.withAlphaComponent(0.5)
            dayLabel.textColor = isSelected == true ? .white : darkColor.withAlphaComponent(0.5)
            numberLabel.textColor = isSelected == true ? .white : darkColor
            contentView.backgroundColor = isSelected == true ? highlightColor : .white
            contentView.layer.borderWidth = isSelected == true ? 0 : 1
        }
    }

    func populateItem(date: Date, highlightColor: UIColor, darkColor: UIColor) {
        self.highlightColor = highlightColor
        self.darkColor = darkColor

        let mdateFormatter = DateFormatter()
        mdateFormatter.dateFormat = "MMMM"
        monthLabel.text = mdateFormatter.string(from: date)
        monthLabel.textColor = isSelected == true ? .white : darkColor.withAlphaComponent(0.5)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dayLabel.text = dateFormatter.string(from: date).uppercased()
        dayLabel.textColor = isSelected == true ? .white : darkColor.withAlphaComponent(0.5)

        let numberFormatter = DateFormatter()
        numberFormatter.dateFormat = "d"
        numberLabel.text = numberFormatter.string(from: date)
        numberLabel.textColor = isSelected == true ? .white : darkColor

        contentView.layer.borderColor = darkColor.withAlphaComponent(0.2).cgColor
        contentView.backgroundColor = isSelected == true ? highlightColor : .white
    }

}
