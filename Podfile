platform :ios, '13.0'

install! 'cocoapods',
         :deterministic_uuids => false

target 'OCAppBox' do
  project 'OCAppBox.xcodeproj'
  use_frameworks! :linkage => :static

  pod 'AFNetworking', '~> 4.0'
  pod 'Masonry', '~> 1.1'
  pod 'SDWebImage', '~> 5.0'
  pod 'MJRefresh', '~> 3.7'

  target 'OCAppBoxTests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end

  [
    'Pods/AFNetworking/AFNetworking/AFHTTPSessionManager.m',
    'Pods/AFNetworking/AFNetworking/AFNetworkReachabilityManager.m'
  ].each do |file_path|
    next unless File.exist?(file_path)

    content = File.read(file_path)
    next unless content.include?('#import <netinet6/in6.h>')

    File.chmod(0o644, file_path)
    File.write(file_path, content.gsub("#import <netinet6/in6.h>\n", ''))
  end
end
