source 'https://github.com/CocoaPods/Specs.git'
source 'https://bitbucket.org/dvalibs/dvapods'

platform :ios, '8.0'
inhibit_all_warnings!

target 'DVACache' do
	pod 'DVACategories/NSString', '~> 1.4.0'
end
target 'DVACacheTests' do
	pod 'DVACategories/NSString', '~> 1.4.0'
end

post_install do |installer|
  installer.pods_project.build_configuration_list.build_configurations.each do |configuration|
    configuration.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
  end
end
