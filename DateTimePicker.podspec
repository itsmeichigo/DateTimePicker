Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #

  s.name         = "DateTimePicker"
  s.version      = "1.0.4"
  s.summary      = "A nicer iOS UI component for picking date and time."

  s.description  = "DateTimePicker makes it easy to select date and time with an attractive looking component."

  s.homepage     = "https://github.com/itsmeichigo/DateTimePicker"
  s.screenshots  = "https://raw.githubusercontent.com/itsmeichigo/DateTimePicker/master/screenshot.png"


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

  s.platform     = :ios, "9.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #

  s.source       = { :git => "https://github.com/itsmeichigo/DateTimePicker.git", :tag => s.version }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #

  s.source_files  = "Source"
  s.framework  = "UIKit"

  s.requires_arc = true
  s.pod_target_xcconfig = { "SWIFT_VERSION" => "3.0" }

end
