# DateTimePicker

A nicer iOS UI component for picking date and time.

![Screenshot](https://raw.githubusercontent.com/itsmeichigo/DateTimePicker/master/screenshot.png)

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
Dates displayed can be customized by passing in a minimum and maximum date when creating the picker. 
```
let min = minDate // can be Date() or another Date value
let max = maxDate // can be Date() or another Date value
let picker = DateTimePicker.show(selected: Date(), minimumDate: min, maximumDate: max)
```
If you need to show the month, set `picker.includeMonth = true`. The month will show up on the date card.

## Contributing

Contributions for bug fixing or improvements are welcome. Feel free to submit a pull request.

## Licence

DateTimePicker is available under the MIT license. See the LICENSE file for more info.
