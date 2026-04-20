#!/usr/bin/env ruby

require 'fileutils'
require 'xcodeproj'

ROOT = File.expand_path('..', __dir__)
PROJECT_PATH = File.join(ROOT, 'OCAppBox.xcodeproj')
APP_TARGET_NAME = 'OCAppBox'
TEST_TARGET_NAME = 'OCAppBoxTests'
APP_ROOT = File.join(ROOT, 'App')
TEST_ROOT = File.join(ROOT, 'Tests')

def add_directory_entries(group:, directory_path:, target:)
  Dir.children(directory_path).sort.each do |entry|
    next if entry.start_with?('.')

    absolute_path = File.join(directory_path, entry)

    if File.directory?(absolute_path)
      subgroup = group.new_group(entry, entry)
      add_directory_entries(group: subgroup, directory_path: absolute_path, target: target)
      next
    end

    file_ref = group.new_file(entry)
    case File.extname(entry)
    when '.m'
      target.add_file_references([file_ref])
    when '.storyboard'
      target.resources_build_phase.add_file_reference(file_ref, true)
    end
  end
end

def add_test_entries(group:, directory_path:, target:)
  Dir.children(directory_path).sort.each do |entry|
    next if entry.start_with?('.')

    absolute_path = File.join(directory_path, entry)
    next if File.directory?(absolute_path)

    file_ref = group.new_file(entry)
    next unless File.extname(entry) == '.m'

    target.add_file_references([file_ref])
  end
end

FileUtils.rm_rf(PROJECT_PATH)

project = Xcodeproj::Project.new(PROJECT_PATH)
app_target = project.new_target(:application, APP_TARGET_NAME, :ios, '13.0')
test_target = project.new_target(:unit_test_bundle, TEST_TARGET_NAME, :ios, '13.0')
test_target.add_dependency(app_target)

app_target.build_configurations.each do |config|
  config.build_settings['INFOPLIST_FILE'] = 'App/Info.plist'
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.example.ocappbox'
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'
  config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
  config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = ['$(inherited)', '@executable_path/Frameworks']
  config.build_settings['ASSETCATALOG_COMPILER_APPICON_NAME'] = ''
  config.build_settings['GENERATE_INFOPLIST_FILE'] = 'NO'
  config.build_settings['HEADER_SEARCH_PATHS'] = ['$(inherited)', '$(SRCROOT)/App', '$(SRCROOT)/App/**']
end

test_target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.example.ocappbox.tests'
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'
  config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
  config.build_settings['GENERATE_INFOPLIST_FILE'] = 'YES'
  config.build_settings['PRODUCT_NAME'] = '$(TARGET_NAME)'
  config.build_settings['FRAMEWORK_SEARCH_PATHS'] = ['$(inherited)', '$(PLATFORM_DIR)/Developer/Library/Frameworks']
  config.build_settings['OTHER_LDFLAGS'] = ['$(inherited)', '-framework', 'XCTest']
  config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = ['$(inherited)', '@executable_path/Frameworks', '@loader_path/Frameworks']
  config.build_settings['TEST_HOST'] = '$(BUILT_PRODUCTS_DIR)/OCAppBox.app/OCAppBox'
  config.build_settings['BUNDLE_LOADER'] = '$(TEST_HOST)'
  config.build_settings['HEADER_SEARCH_PATHS'] = ['$(inherited)', '$(SRCROOT)/App', '$(SRCROOT)/App/**']
end

app_group = project.main_group.new_group('App', 'App')
test_group = project.main_group.new_group('Tests', 'Tests')

add_directory_entries(group: app_group, directory_path: APP_ROOT, target: app_target)
add_test_entries(group: test_group, directory_path: TEST_ROOT, target: test_target)

frameworks_group = project.frameworks_group
ui_kit_ref = frameworks_group.new_file('System/Library/Frameworks/UIKit.framework')
app_target.frameworks_build_phase.add_file_reference(ui_kit_ref, true)
test_target.frameworks_build_phase.add_file_reference(ui_kit_ref, true)

security_ref = frameworks_group.new_file('System/Library/Frameworks/Security.framework')
app_target.frameworks_build_phase.add_file_reference(security_ref, true)

project.save

scheme = Xcodeproj::XCScheme.new
scheme.configure_with_targets(app_target, test_target, launch_target: true)
scheme.save_as(PROJECT_PATH, APP_TARGET_NAME, true)

puts "Generated #{PROJECT_PATH}"
