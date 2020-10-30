//
//  DateTimePicker+CollectionView.swift
//  DateTimePicker
//
//  Created by Huong Do on 1/5/20.
//  Copyright © 2020 ichigo. All rights reserved.
//

import UIKit

extension DateTimePicker: UICollectionViewDataSource, UICollectionViewDelegate {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dates.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dateCell", for: indexPath) as! FullDateCollectionViewCell
        let date = dates[indexPath.item]
        let style = FullDateCollectionViewCell.Style(highlightColor: highlightColor,
                                                     normalColor: normalColor,
                                                     darkColor: darkColor,
                                                     dayLabelFont: customFontSetting.dateCellDayMonthLabelFont,
                                                     numberLabelFont: customFontSetting.dateCellNumberLabelFont,
                                                     monthLabelFont: customFontSetting.dateCellDayMonthLabelFont)
        cell.populateItem(date: date, style: style, locale: locale, includesMonth: includesMonth)

        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //workaround to center to every cell including ones near margins
        if let cell = collectionView.cellForItem(at: indexPath) {
            let offset = CGPoint(x: cell.center.x - collectionView.frame.width / 2, y: 0)
            collectionView.setContentOffset(offset, animated: true)
        }
        
        // update selected dates
        let date = dates[indexPath.item]
        let dayComponent = calendar.dateComponents([.day, .month, .year], from: date)
        components.day = dayComponent.day
        components.month = dayComponent.month
        components.year = dayComponent.year
        if let selected = calendar.date(from: components) {
            if selected.compare(minimumDate) == .orderedAscending {
                selectedDate = minimumDate
                resetTime()
            } else {
                selectedDate = selected
            }
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        alignScrollView(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        alignScrollView(scrollView)
    }
    
    func alignScrollView(_ scrollView: UIScrollView) {
        if let collectionView = scrollView as? UICollectionView {
            alignCollectionView(collectionView)
        } else if let tableView = scrollView as? UITableView {
            alignTableView(tableView)
        }
    }
    
    private func alignCollectionView(_ collectionView: UICollectionView) {
        let centerPoint = CGPoint(x: collectionView.center.x + collectionView.contentOffset.x, y: 50);
        if let indexPath = collectionView.indexPathForItem(at: centerPoint) {
            // automatically select this item and center it to the screen
            // set animated = false to avoid unwanted effects
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
            if let cell = collectionView.cellForItem(at: indexPath) {
                let offset = CGPoint(x: cell.center.x - collectionView.frame.width / 2, y: 0)
                collectionView.setContentOffset(offset, animated: false)
            }
            
            // update selected date
            let date = dates[indexPath.item]
            let dayComponent = calendar.dateComponents([.day, .month, .year], from: date)
            components.day = dayComponent.day
            components.month = dayComponent.month
            components.year = dayComponent.year
            if let selected = calendar.date(from: components) {
                if selected.compare(minimumDate) == .orderedAscending {
                    selectedDate = minimumDate
                    resetTime()
                } else {
                    selectedDate = selected
                }
            }
        }
    }
    
    private func alignTableView(_ tableView: UITableView) {
        var selectedRow = 0
        var scrollPosition: UITableView.ScrollPosition = .middle
        
        if let firstVisibleCell = tableView.visibleCells.first,
            tableView != amPmTableView {
            var firstVisibleRow = 0
            if tableView.contentOffset.y >= firstVisibleCell.frame.origin.y + tableView.rowHeight/2 - tableView.contentInset.top {
                firstVisibleRow = (tableView.indexPath(for: firstVisibleCell)?.row ?? 0) + 1
            } else {
                firstVisibleRow = (tableView.indexPath(for: firstVisibleCell)?.row ?? 0)
            }
            if tableView == minuteTableView,
                timeInterval != .default {
                selectedRow = min(max(firstVisibleRow, 0), self.tableView(tableView, numberOfRowsInSection: 0)-1)
            } else {
                selectedRow = firstVisibleRow + 1
            }
            
            // adjust selected row number for inifinite scrolling
            selectedRow = adjustedRowForInfiniteScrolling(tableView: tableView, selectedRow: selectedRow)
            
        } else if tableView == amPmTableView {
            if -tableView.contentOffset.y > tableView.rowHeight/2 {
                selectedRow = 0
            } else {
                selectedRow = 1
            }
            scrollPosition = .none
        }
        
        tableView.selectRow(at: IndexPath(row: selectedRow, section: 0), animated: false, scrollPosition: scrollPosition)
        
        if tableView == hourTableView {
            if is12HourFormat {
                components.hour = selectedRow < 12 ? selectedRow + 1 : (selectedRow - 12)%12 + 1
                if let hour = components.hour,
                    amPmTableView.indexPathForSelectedRow?.row == 0 && hour >= 12 {
                    components.hour! -= 12
                } else if let hour = components.hour,
                    amPmTableView.indexPathForSelectedRow?.row == 1 && hour < 12 {
                    components.hour! += 12
                }
            } else {
                components.hour = selectedRow < 24 ? selectedRow : (selectedRow - 24)%24
            }
            
        } else if tableView == minuteTableView {
            if timeInterval == .default {
                components.minute = selectedRow < 60 ? selectedRow : (selectedRow - 60)%60
            } else {
                components.minute = selectedRow * timeInterval.rawValue
            }
        } else if tableView == secondTableView {
            components.second = selectedRow < 60 ? selectedRow : (selectedRow - 60)%60
        } else if tableView == amPmTableView {
            if let hour = components.hour,
                selectedRow == 0 && hour >= 12 {
                components.hour = hour - 12
            } else if let hour = components.hour,
                selectedRow == 1 && hour < 12 {
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
}
