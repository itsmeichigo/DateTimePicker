//
//  DateTimePicker+UITableView.swift
//  DateTimePicker
//
//  Created by Huong Do on 1/5/20.
//  Copyright © 2020 ichigo. All rights reserved.
//

import UIKit

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
        
        if tableView == minuteTableView,
            timeInterval != .default {
            return 60 / timeInterval.rawValue
        }
        // need triple of origin storage to scroll infinitely
        return 60 * 3
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "timeCell") ?? UITableViewCell(style: .default, reuseIdentifier: "timeCell")
        
        cell.selectedBackgroundView = UIView()
        cell.backgroundColor = .clear
        cell.textLabel?.textAlignment = tableView == hourTableView ? .right : .left
        cell.textLabel?.font = customFontSetting.timeLabelFont
        cell.textLabel?.textColor = darkColor.withAlphaComponent(0.4)
        cell.textLabel?.highlightedTextColor = highlightColor
        // add module operation to set value same
        if tableView == amPmTableView {
            cell.textLabel?.text = (indexPath.row == 0) ? "AM" : "PM"
        } else if tableView == minuteTableView {
            if timeInterval == .default {
                cell.textLabel?.text = String(format: "%02i", indexPath.row % 60)
            } else {
                cell.textLabel?.text = String(format: "%02i", indexPath.row * timeInterval.rawValue)
            }
        } else if tableView == secondTableView {
            cell.textLabel?.text = String(format: "%02i", indexPath.row % 60)
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
            
        } else if tableView == secondTableView {
            components.second = indexPath.row < 60 ? indexPath.row : (indexPath.row - 60)%60
            
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
        
        if tableView == hourTableView,
            is12HourFormat,
            selectedRow > 12 * 3 - 1 {
            return selectedRow - 12
        } else if tableView == hourTableView,
            !is12HourFormat,
            selectedRow > 24 * 3 - 1 {
            return selectedRow - 24
        } else if (tableView == minuteTableView ||
            tableView == secondTableView),
            selectedRow > 60 * 3 - 1 {
            return selectedRow - 60
        }
        
        return selectedRow
    }
}
