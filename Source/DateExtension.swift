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

    static func years(fromDate: Date, toDate: Date) -> [Int] {
        var years: [Int] = []
        var days = DateComponents()

        var yearCount = 0
        repeat {
            days.year = yearCount
            yearCount += 1
            guard let date = Calendar.current.date(byAdding: days, to: fromDate) else {
                break;
            }
            if date.compare(toDate) == .orderedDescending {
                break
            }
            years.append(date.year())
        } while (true)

        return years
    }

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

    static func countOfDaysInMonth(year: Int?, month: Int?) -> Int  {
        return Date.date(year: nil, month: month, day: nil, hour: nil, minute: nil, second: nil)?.endOfMonth().day() ?? 0
    }

    func getNextMonth() -> Date? {
        return Calendar.current.date(byAdding: .month, value: 1, to: self)
    }

    func getNexDay() -> Date? {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)
    }

    func getPreviousMonth() -> Date? {
        return Calendar.current.date(byAdding: .month, value: -1, to: self)
    }

    func getPreviousDay() -> Date? {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)
    }

    func totalDistance(from date: Date, resultIn component: Calendar.Component) -> Int? {
        return Calendar.current.dateComponents([component], from: self, to: date).value(for: component)
    }

    func compare(with date: Date, only component: Calendar.Component) -> Int {
        let days1 = Calendar.current.component(component, from: self)
        let days2 = Calendar.current.component(component, from: date)
        return days1 - days2
    }

    func hasSame(_ component: Calendar.Component, as date: Date) -> Bool {
        return self.compare(with: date, only: component) == 0
    }

    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

    func fullDate() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.YYYY HH:mm"
        return dateFormatter.string(from: self)
    }

    func weekDay() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self)
    }

    func monthName() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: self)
    }

    func weekDayShort() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE"
        return dateFormatter.string(from: self)
    }

    func hourWithMinute() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self)
    }

    func todaysMonthInt() -> Int? {
        return Calendar.current.component(.month, from: self)
    }

    func todaysMonthWord() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        return dateFormatter.string(from: self)
    }

    func todaysMonth() -> String? {
        guard let todaysMonthAsInt = todaysMonthInt() else {
            return nil
        }
        return "\(todaysMonthAsInt)"
    }

    func todaysMonthdayInt() -> Int? {
        return Calendar.current.component(.day, from: self)
    }

    func todaysMonthday() -> String? {
        guard let todaysMonthdayInt = todaysMonthdayInt() else {
            return nil
        }
        return "\(todaysMonthdayInt)"
    }

    func weekdayAsInt() -> Int? {
        var numberOfWeekday = Calendar.current.component(.weekday, from: self)
        numberOfWeekday = numberOfWeekday + 1
        if numberOfWeekday >= 8 {
            numberOfWeekday = 1
        }
        return numberOfWeekday
    }

    func weekdayIntAsString() -> String? {
        guard let todaysWeekDayAsInt = weekdayAsInt() else {
            return nil
        }
        return "\(todaysWeekDayAsInt)"
    }

    func sameDateWithHour(hourMinuteSecond: String) -> Date? {
        let samedate = self
        let calendar = Calendar.current
        var arrayOfHourMinuteSecond = hourMinuteSecond.components(separatedBy: ":")
        let hourInt = Int(arrayOfHourMinuteSecond[0])!
        let minuteInt = Int(arrayOfHourMinuteSecond[1])!
        let secondInt = Int(arrayOfHourMinuteSecond[2])!

        let newDate = calendar.date(bySettingHour: hourInt,
                                    minute: minuteInt,
                                    second: secondInt,
                                    of: samedate)

        return newDate
    }
}
