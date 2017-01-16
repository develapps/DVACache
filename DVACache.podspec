#
# Be sure to run `pod lib lint DVACache.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "DVACache"
  s.version          = "1.2.1"
  s.summary          = "An in-memory and on-disk with autoeviction Cache"
  s.description      = <<-DESC
                       An in-memory and on-disk with autoeviction Cache.

                       * You can show in memory
                       * Or not!

                       New on 1.1.0:
                        Added object removal with removeObjectForKey:
                        New on 1.2.0:
                        - Added list cached objects.
                        - Added list memory consumption.ll

                       DESC
  s.homepage         = "https://bitbucket.com/DVALibs"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Pablo Romeu" => "pablo.romeu@develapps.com" }
  s.source           = { :git => "https://github.com/develapps/DVACache.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/pabloromeu'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'DVACache/**/*'
  s.dependency 'DVACategories/NSString', '~> 1.4'


#  s.resource_bundles = {
#    'DVACache' => ['Pod/Assets/*.png']
#  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'

end
