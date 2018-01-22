Pod::Spec.new do |s|
  s.name             = 'Swift-EventBus'
  s.version          = '0.2.0'
  s.summary          = 'A safe-by-default pure Swift notification center.'

  s.description      = <<-DESC
  A safe-by-default pure Swift alternative to Cocoa's `NSNotificationCenter`.
                       DESC

  s.homepage         = 'https://github.com/regexident/EventBus'
  s.license          = { :type => 'BSD-3', :file => 'LICENSE' }
  s.author           = { 'regexident' => 'regexident@gmail.com' }
  s.source           = { :git => 'https://github.com/regexident/EventBus.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.11'
  s.watchos.deployment_target = '3.0'
  s.tvos.deployment_target = '10.0'

  s.source_files  = 'EventBus/**/*.swift'
end
