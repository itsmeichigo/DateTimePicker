//
//  Bundle+Resource.swift
//  DateTimePicker
//
//  Created by Duy Tran on 10/9/20.
//

import Foundation

private class MyBundleFinder {}

extension Foundation.Bundle {
    
    /**
     The resource bundle associated with the current module..
     - important: When `DateTimePicker` is distributed via Swift Package Manager, it will be synthesized automatically in the name of `Bundle.module`.
     */
    static var resource: Bundle = {
        let moduleName = "DateTimePicker"
        #if COCOAPODS
        let bundleName = moduleName
        #else
        let bundleName = "\(moduleName)_\(moduleName)"
        #endif
        
        let candidates = [
            // Bundle should be present here when the package is linked into an App.
            Bundle.main.resourceURL,

            // Bundle should be present here when the package is linked into a framework.
            Bundle(for: MyBundleFinder.self).resourceURL,

            // For command-line tools.
            Bundle.main.bundleURL,
        ]

        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        
        fatalError("Unable to find bundle named \(bundleName)")
    }()
}
