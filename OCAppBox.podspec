Pod::Spec.new do |s|
  s.name             = 'OCAppBox'
  s.version          = '0.1.0'
  s.summary          = 'A modular Objective-C bootstrap framework for building iOS apps quickly.'
  s.description      = <<-DESC
    OCAppBox is an Objective-C iOS framework skeleton that provides app bootstrap,
    service registration, routing, and a module-based architecture baseline for fast app delivery.
  DESC
  s.homepage         = 'https://example.com/OCAppBox'
  s.license          = { :type => 'MIT', :text => 'MIT License' }
  s.author           = { 'Codex' => 'dev@example.com' }
  s.platform         = :ios, '13.0'
  s.source           = { :git => 'https://example.com/OCAppBox.git', :tag => s.version.to_s }
  s.default_subspecs = 'Umbrella'
  s.header_mappings_dir = 'Sources/OCAppBox'
  s.requires_arc     = true
  s.static_framework = true
  s.frameworks       = 'Foundation', 'UIKit'
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'CLANG_ENABLE_OBJC_ARC' => 'YES'
  }

  s.subspec 'Foundation' do |ss|
    ss.source_files = 'Sources/OCAppBox/Foundation/**/*.{h,m}'
    ss.public_header_files = 'Sources/OCAppBox/Foundation/**/*.h'
  end

  s.subspec 'Core' do |ss|
    ss.source_files = 'Sources/OCAppBox/Core/**/*.{h,m}'
    ss.public_header_files = 'Sources/OCAppBox/Core/**/*.h'
    ss.dependency 'OCAppBox/Foundation'
  end

  s.subspec 'Infra' do |ss|
    ss.source_files = 'Sources/OCAppBox/Infra/**/*.{h,m}'
    ss.public_header_files = 'Sources/OCAppBox/Infra/**/*.h'
    ss.dependency 'OCAppBox/Foundation'
  end

  s.subspec 'UI' do |ss|
    ss.source_files = 'Sources/OCAppBox/UI/**/*.{h,m}'
    ss.public_header_files = 'Sources/OCAppBox/UI/**/*.h'
    ss.dependency 'OCAppBox/Foundation'
  end

  s.subspec 'Service' do |ss|
    ss.source_files = 'Sources/OCAppBox/Service/**/*.{h,m}'
    ss.public_header_files = 'Sources/OCAppBox/Service/**/*.h'
    ss.dependency 'OCAppBox/Foundation'
    ss.dependency 'OCAppBox/Core'
    ss.dependency 'OCAppBox/Infra'
  end

  s.subspec 'Module' do |ss|
    ss.source_files = 'Sources/OCAppBox/Module/**/*.{h,m}'
    ss.public_header_files = 'Sources/OCAppBox/Module/**/*.h'
    ss.dependency 'OCAppBox/Foundation'
    ss.dependency 'OCAppBox/Core'
    ss.dependency 'OCAppBox/UI'
    ss.dependency 'OCAppBox/Service'
  end

  s.subspec 'Support' do |ss|
    ss.source_files = 'Sources/OCAppBox/Support/**/*.{h,m}'
    ss.public_header_files = 'Sources/OCAppBox/Support/**/*.h'
    ss.dependency 'OCAppBox/Foundation'
    ss.dependency 'OCAppBox/Core'
    ss.dependency 'OCAppBox/UI'
    ss.dependency 'OCAppBox/Service'
  end

  s.subspec 'Umbrella' do |ss|
    ss.source_files = 'Sources/OCAppBox/OCAppBox.h'
    ss.public_header_files = 'Sources/OCAppBox/OCAppBox.h'
    ss.dependency 'OCAppBox/Foundation'
    ss.dependency 'OCAppBox/Core'
    ss.dependency 'OCAppBox/Infra'
    ss.dependency 'OCAppBox/UI'
    ss.dependency 'OCAppBox/Service'
    ss.dependency 'OCAppBox/Module'
    ss.dependency 'OCAppBox/Support'
  end
end
