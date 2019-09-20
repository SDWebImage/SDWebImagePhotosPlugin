#
# Be sure to run `pod lib lint SDWebImagePhotosPlugin.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SDWebImagePhotosPlugin'
  s.version          = '0.4.0'
  s.summary          = 'A SDWebImage plugin to support Photos framework image loading.'

  s.description      = <<-DESC
This is a SDWebImage loader plugin to support Apple's Photos framework image asset.
                       DESC

  s.homepage         = 'https://github.com/SDWebImage/SDWebImagePhotosPlugin'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'DreamPiggy' => 'lizhuoli1126@126.com' }
  s.source           = { :git => 'https://github.com/SDWebImage/SDWebImagePhotosPlugin.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.osx.deployment_target = '10.13'
  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '10.0'

  s.source_files = 'SDWebImagePhotosPlugin/Classes/**/*', 'SDWebImagePhotosPlugin/Module/SDWebImagePhotosPlugin.h'
  s.module_map = 'SDWebImagePhotosPlugin/Module/SDWebImagePhotosPlugin.modulemap'
  
  s.frameworks = 'Photos'
  s.dependency 'SDWebImage/Core', '~> 5.0'
end
