Pod::Spec.new do |s|

  s.name         = "LMCSideMenu"
  s.version      = "0.0.9"
  s.summary      = "Simple and lightweight side menu written in Swift"
  s.description  = "LMCSideMenu allows to create fully customizable side menu (left and right) with support of gestures"
  s.homepage     = "https://github.com/andreybuksha/LMCSideMenu"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Andrey" => "andrey.buksha@letmecode.org" }
  s.platform     = :ios, "10.0"
  s.swift_version = "4.2"
  s.source       = { :git => "https://github.com/andreybuksha/LMCSideMenu.git", :tag => "#{s.version}" }
  s.source_files  = "LMCSideMenu", "LMCSideMenu/LMCSideMenu/**/*.{h,m,swift}"
  s.module_name   = "LMCSideMenu"

end
