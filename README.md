# DateTimePicker

A nicer iOS UI component for picking date and time.

![Screenshot](https://raw.githubusercontent.com/itsmeichigo/DateTimePicker/master/screenshot.png)

## Features

- Date and Time Picker / Date Picker only / Time Picker only - your choice!
- Limit selected date within a defined range of time
- Show or hide month on date cell
- Inifnite scrolling for time
- Customize colors and date format

## To-dos (HELP NEEDED! 🎯)

- Picker view as a separate view, to be added in `viewDidLoad`
- Constraint-based UI
- Option to select month / year (UI idea needed)

## Requirements

- Swift 3.0 & Xcode 8
- iOS 9 and later

## Installation

#### Using Cocoapod

Just add the following to your `podfile`
> pod 'DateTimePicker'

#### Manual install

Drag and drop folder `Source` to your project.


## Usage

You can easily show and customize the component's colors

```Swift
let picker = DateTimePicker.show()
picker.highlightColor = UIColor(red: 255.0/255.0, green: 138.0/255.0, blue: 138.0/255.0, alpha: 1)
picker.isDatePickerOnly = true // to hide time and show only date picker
picker.completionHandler = { date in
    // do something after tapping done
}
```

## Contributing

Contributions for bug fixing or improvements are welcome. Feel free to submit a pull request.

## Licence

DateTimePicker is available under the MIT license. See the LICENSE file for more info.
