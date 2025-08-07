#
# Be sure to run `pod lib lint AnimatedTransitionKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "AnimatedTransitionKit"
  s.version          = "4.6.0"
  s.summary          = "UIViewController Transitioning Library."
  s.description      = "This library helps you to apply and create Custom UIViewController Transitions."
  s.homepage         = "https://github.com/pisces/AnimatedTransitionKit"
  s.license          = 'BSD 2-Clause'
  s.author           = { "Steve Kim" => "hh963103@gmail.com" }
  s.source           = { :git => "https://github.com/pisces/AnimatedTransitionKit.git", :tag => s.version.to_s }
  s.ios.deployment_target = '13.0'
  s.source_files = 'AnimatedTransitionKit/Classes/**/*'
end
