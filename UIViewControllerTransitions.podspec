#
# Be sure to run `pod lib lint UIViewControllerTransitions.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "UIViewControllerTransitions"
  s.version          = "3.2.11"
  s.summary          = "UIViewController Transitioning Library."
  s.description      = "This library helps you to apply and create Custom UIViewController Transitions."
  s.homepage         = "https://github.com/pisces/UIViewControllerTransitions"
  s.license          = 'BSD 2-Clause'
  s.author           = { "Steve Kim" => "hh963103@gmail.com" }
  s.source           = { :git => "https://github.com/pisces/UIViewControllerTransitions.git", :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files = 'UIViewControllerTransitions/Classes/**/*'
end
