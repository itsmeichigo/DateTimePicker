//
//  DateCollectionViewCell.swift
//  DateTimePicker
//
//  Created by Huong Do on 9/26/16.
//  Copyright © 2016 ichigo. All rights reserved.
//

import UIKit

class DateCollectionViewCell: UICollectionViewCell {
    var dayLabel: UILabel! // rgb(128,138,147)
    var numberLabel: UILabel!
    
    override init(frame: CGRect) {
        
        dayLabel = UILabel(frame: CGRect(x: 5, y: 15, width: frame.width - 10, height: 20))
        dayLabel.font = UIFont.boldSystemFont(ofSize: 10)
        dayLabel.textColor = UIColor(red: 128.0/255.0, green: 138.0/255.0, blue: 147.0/255.0, alpha: 1)
        dayLabel.textAlignment = .center
    
        numberLabel = UILabel(frame: CGRect(x: 5, y: 30, width: frame.width - 10, height: 40))
        numberLabel.font = UIFont.systemFont(ofSize: 25)
        numberLabel.textColor = UIColor(red: 0, green: 22.0/255.0, blue: 39.0/255.0, alpha: 1)
        numberLabel.textAlignment = .center
        
        super.init(frame: frame)
        
        contentView.addSubview(dayLabel)
        contentView.addSubview(numberLabel)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 3
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor(red: 216.0/255.0, green: 223.0/255.0, blue: 229.0/255.0, alpha: 1).cgColor //rgb(216,223,229)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            dayLabel.textColor = isSelected == true ? .white : UIColor(red: 128.0/255.0, green: 138.0/255.0, blue: 147.0/255.0, alpha: 1)
            numberLabel.textColor = isSelected == true ? .white : .black
            contentView.backgroundColor = isSelected == true ? UIColor(red: 0/255.0, green: 199.0/255.0, blue: 194.0/255.0, alpha: 1) : .white
            contentView.layer.borderWidth = isSelected == true ? 0 : 1
        }
    }
}
