# DateTimePicker

A nicer iOS UI component for picking date and time.

![Screenshot](https://raw.githubusercontent.com/itsmeichigo/DateTimePicker/master/screenshot.png)

## Features

- Date and Time Picker / Date Picker only / Time Picker only - your choice!
- Limit selected date within a defined range of time
- Show or hide month on date cell
- Inifnite scrolling for time
- Customize colors and date format
- (v1.3) Constraint-based UI
- (v2.0) Now you can create picker view as a separate view!
- (v2.1.0) Carthage is now supported (a bit late - sorry)

## To-dos (HELP NEEDED! 🎯)

- Option to select month / year (UI idea needed)

## Requirements

- Swift 4.2 & Xcode 10
- For Swift 4.1 please use branch `swift4.1`
- For Swift 3.0 please use version 1.1.4
- iOS 9 and later

## Installation

#### Using Cocoapod

Just add the following to your `podfile`
> pod 'DateTimePicker'

#### Using Carthage

From 2.1.0 onward, you can integrate DateTimePicker into your Xcode project using Carthage by specifying it in your `Cartfile`:

```ogdl
github "itsmeichigo/DateTimePicker" ~> 2.1.0
```

Run `carthage update` to build the framework and drag the built `DateTimePicker.framework` into your Xcode project.

#### Manual install

Drag and drop folder `Source` to your project.


## Usage

### v2.0

Since v2.0 onward, picker view can be created separately and used to add to any view you want.
Note: the picker view is built with fixed width and height, so you're not encouraged to manually update it or you will get corrupted UI for the view. If necessary, please only change the y position of the view.

```Swift
let min = Date().addingTimeInterval(-60 * 60 * 24 * 4)
let max = Date().addingTimeInterval(60 * 60 * 24 * 4)
let picker = DateTimePicker.create(minimumDate: min, maximumDate: max)
picker.frame = CGRect(x: 0, y: 100, width: picker.frame.size.width, height: picker.frame.size.height)
self.view.addSubview(picker)
```

If you still want the old behavior (show the picker like a modal), you can call `show` method:

```Swift
let picker = DateTimePicker()
picker.show()
```

### v1.3 and below

For older versions, the only option is to use the built in `show` method, which returns an instance of `DateTimePicker` and also show the picker like a modal on top window. The picker can be dismissed when Cancel button is tapped.

```Swift
let picker = DateTimePicker.show()
```


### Customization

There are many options to customize picker for your own desire:
- `minimumDate` and `maximumDate`: date and time limit for the picker. You can only set these when creating the picker, default value is last 10 days for minimum date and next 10 days for maximum date. If you set these dates yourself, make sure that minimum date is an earlier time than maximum date.
- `selectedDate`: date to be selected when picker is first created, default is current date. Selected date has to be later than `minimumDate` and earlier than `maximumDate`.
- `locale`: locale for the language displayed. default is device's locale.
- `dateFormat`: format for the date shown in picker view. default is HH:mm dd/MM/YYYY.
- `cancelButtonTitle`: title for dismiss button, default is Cancel.
- `todayButtonTitle`: title for reset time button, default to Today.
- `doneButtonTitle`: title for done button, default to DONE.
- `is12HourFormat`: whether to display time in 12 hour format, default to false.
- `isDatePickerOnly`: whether to only show date in picker view, default to false.
- `isTimePickerOnly`: whether to show only time in picker view, default to false.
- `includeMonth`: whether to include month in date cells, default to false.
- `timeInterval`: time interval, in minutes, default to 1. If not default, infinite scrolling is off.
- `timeZone`: timezone used in picker, default is device timezone.
- `dismissHandler`: callback block when cancel button of picker view is tapped.
- `delegate`: object to be notified when a new date or time is selected.
- `highlightColor`: custom highlight color, default to cyan.
- `darkColor`: custom dark color, default to grey.
- `doneBackgroundColor`: custom DONE button color, default to darkColor.
- `daysBackgroundColor`: custom background color for date cells.


## Contributing

Contributions for bug fixing or improvements are welcome. Feel free to submit a pull request.

## Licence

DateTimePicker is available under the MIT license. See the LICENSE file for more info.
