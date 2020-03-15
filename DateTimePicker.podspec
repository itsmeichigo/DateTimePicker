Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #

  s.name         = "DateTimePicker"
  s.version      = "2.4.1"
  s.summary      = "A nicer iOS UI component for picking date and time."

  s.description  = "DateTimePicker makes it easy to select date and time with an attractive looking component."

  s.homepage     = "https://github.com/itsmeichigo/DateTimePicker"
  s.screenshots  = "https://raw.githubusercontent.com/itsmeichigo/DateTimePicker/master/screenshot.jpg"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #

  s.license      = { :type => "MIT", :file => "LICENSE" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #

  s.author             = { "Huong Do" => "huongdt29@gmail.com" }
  s.social_media_url   = "https://twitter.com/itsmeichigo"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  s.platform     = :ios, "10.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #

  s.source       = { :git => "https://github.com/itsmeichigo/DateTimePicker.git", :tag => s.version }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #

  s.source_files  = "Source/**/*.{swift}"
  s.resource_bundles = {
    'DateTimePicker' => ['Source/**/*.{xib}']
  }
  s.framework  = "UIKit"

  s.requires_arc = true
  s.pod_target_xcconfig = { "SWIFT_VERSION" => "5.0" }
  s.swift_version = "5.0"

end
