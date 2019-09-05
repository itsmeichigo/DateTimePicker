//
//  DateExtension.swift
//  Demo
//
//  Created by Fatih Karakurt on 02.09.19.
//  Copyright © 2019 ichigo. All rights reserved.
//

import Foundation

extension Array where Element==Date {
    func years() -> [Int] {
        var years = [Int]()
        for date in self {
            let year = date.year()
            if !years.contains(year) {
                years.append(year)
            }
        }
        years = years.sorted()
        return years
    }

    func days(forYear year: Int?, andForMont month: Int?) -> [Int] {
        var days = [Int]()
        for date in self {
            let day = date.day()
            let yearInDate = date.year()
            let monthInDate = date.month()
            let monthIsIn = month == monthInDate || month == nil
            let yearIsIn = year == yearInDate || year == nil
            if yearIsIn, monthIsIn, !days.contains(day) {
                days.append(day)
            }
        }
        days = days.sorted()
        return days
    }

    func months(forYear year: Int?) -> [Int] {
        var months = [Int]()
        for date in self {
            let month = date.month()
            let yearInDate = date.year()
            let yearIsIn = year == yearInDate || year == nil
            if yearIsIn, !months.contains(month) {
                months.append(month)
            }
        }
        months = months.sorted()
        return months
    }
}

extension Date {
    func year () -> Int {
        return Calendar.current.component(.year, from: self)
    }
    func day () -> Int {
        return Calendar.current.component(.day, from: self)
    }
    func month () -> Int {
        return Calendar.current.component(.month, from: self)
    }

    func hour () -> Int {
        return Calendar.current.component(.hour, from: self)
    }

    func minutes () -> Int {
        return Calendar.current.component(.minute, from: self)
    }

    func seconds () -> Int {
        return Calendar.current.component(.second, from: self)
    }
    
    static func date(year:Int?, month: Int?, day: Int?, hour: Int?, minute: Int?, second: Int?) -> Date? {
        let calendar = Calendar.current
        let newDate = Date()
        var component = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: newDate)
        component.year = year
        component.month = month
        component.day = day
        component.hour = hour
        component.minute = minute
        component.day = day
        return calendar.date(from: component)

    }

    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }

    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }

    func getNextMonth() -> Date? {
        return Calendar.current.date(byAdding: .month, value: 1, to: self)
    }

    func getPreviousMonth() -> Date? {
        return Calendar.current.date(byAdding: .month, value: -1, to: self)
    }
}
