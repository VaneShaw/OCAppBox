#!/usr/bin/env ruby

require 'fileutils'
require 'xcodeproj'

ROOT = File.expand_path('..', __dir__)
EXAMPLE_ROOT = File.join(ROOT, 'Example')
PROJECT_PATH = File.join(EXAMPLE_ROOT, 'OCAppBoxExample.xcodeproj')
APP_TARGET_NAME = 'OCAppBoxExample'
TEST_TARGET_NAME = 'OCAppBoxExampleTests'

FileUtils.rm_rf(PROJECT_PATH)

project = Xcodeproj::Project.new(PROJECT_PATH)
app_target = project.new_target(:application, APP_TARGET_NAME, :ios, '13.0')
test_target = project.new_target(:unit_test_bundle, TEST_TARGET_NAME, :ios, '13.0')
test_target.add_dependency(app_target)

app_target.build_configurations.each do |config|
  config.build_settings['INFOPLIST_FILE'] = 'OCAppBoxExample/Info.plist'
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.example.OCAppBoxExample'
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'
  config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
  config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = ['$(inherited)', '@executable_path/Frameworks']
  config.build_settings['ASSETCATALOG_COMPILER_APPICON_NAME'] = ''
  config.build_settings['GENERATE_INFOPLIST_FILE'] = 'NO'
end

test_target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.example.OCAppBoxExampleTests'
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'
  config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
  config.build_settings['GENERATE_INFOPLIST_FILE'] = 'YES'
  config.build_settings['PRODUCT_NAME'] = '$(TARGET_NAME)'
  config.build_settings['FRAMEWORK_SEARCH_PATHS'] = ['$(inherited)', '$(PLATFORM_DIR)/Developer/Library/Frameworks']
  config.build_settings['OTHER_LDFLAGS'] = ['$(inherited)', '-framework', 'XCTest']
  config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = ['$(inherited)', '@executable_path/Frameworks', '@loader_path/Frameworks']
  config.build_settings['TEST_HOST'] = '$(BUILT_PRODUCTS_DIR)/OCAppBoxExample.app/OCAppBoxExample'
  config.build_settings['BUNDLE_LOADER'] = '$(TEST_HOST)'
end

app_group = project.main_group.new_group(APP_TARGET_NAME, APP_TARGET_NAME)
host_group = app_group.new_group('Host', 'Host')
demo_group = app_group.new_group('Demo', 'Demo')
test_group = project.main_group.new_group(TEST_TARGET_NAME, TEST_TARGET_NAME)

{
  app_group => %w[
    AppDelegate.h
    AppDelegate.m
    Info.plist
    main.m
  ],
  host_group => %w[
    OCBDemoAppLauncher.h
    OCBDemoAppLauncher.m
    OCBDemoRouteCatalog.h
    OCBDemoRouteCatalog.m
  ],
  demo_group => %w[
    OCBDemoBootstrapTask.h
    OCBDemoBootstrapTask.m
    OCBDemoHomeViewController.h
    OCBDemoHomeViewController.m
    OCBDemoModule.h
    OCBDemoModule.m
  ],
  test_group => %w[
    OCBAppContextTests.m
    OCBDemoAppLauncherTests.m
    OCBModuleManagerTests.m
    OCBRouterTests.m
    OCBServiceRegistryTests.m
    OCBCacheCenterTests.m
  ]
}.each do |group, files|
  files.each do |file_name|
    file_ref = group.new_file(file_name)
    next unless File.extname(file_name) == '.m'

    target = group == test_group ? test_target : app_target
    target.add_file_references([file_ref])
  end
end

frameworks_group = project.frameworks_group
ui_kit_ref = frameworks_group.new_file('System/Library/Frameworks/UIKit.framework')
app_target.frameworks_build_phase.add_file_reference(ui_kit_ref, true)
test_target.frameworks_build_phase.add_file_reference(ui_kit_ref, true)

project.save

scheme = Xcodeproj::XCScheme.new
scheme.configure_with_targets(app_target, test_target, launch_target: true)
scheme.save_as(PROJECT_PATH, APP_TARGET_NAME, true)

puts "Generated #{PROJECT_PATH}"
