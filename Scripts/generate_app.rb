#!/usr/bin/env ruby

require 'fileutils'
require 'optparse'
require 'pathname'
require 'xcodeproj'

ROOT = File.expand_path('..', __dir__)
TEMPLATE_ROOT = File.join(ROOT, 'Templates', 'AppTemplate')
DEFAULT_OUTPUT_ROOT = File.join(ROOT, 'Example')
DEFAULT_DEPLOYMENT_TARGET = '13.0'

def underscore(camel_case_name)
  camel_case_name
    .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
    .gsub(/([a-z\d])([A-Z])/, '\1_\2')
    .tr('-', '_')
    .downcase
end

def humanize(name)
  underscore(name).split('_').map(&:capitalize).join(' ')
end

def default_prefix(name)
  segments = name.gsub(/([a-z\d])([A-Z])/, '\1 \2').split(/[\s_-]+/).reject(&:empty?)
  acronym = segments.map { |segment| segment[0] }.join.upcase
  return acronym if acronym.length >= 2

  name[0, 3].upcase
end

def render_string(content, replacements)
  output = content.dup
  replacements.each do |key, value|
    output.gsub!(key, value)
  end
  output
end

def default_pod_path(root, output_dir)
  root_path = Pathname.new(root).expand_path
  output_path = Pathname.new(output_dir).expand_path

  if output_path.to_s.start_with?("#{root_path}/")
    return root_path.relative_path_from(output_path).to_s
  end

  root_path.to_s
end

def usage_banner
  <<~TEXT
    Usage:
      ruby Scripts/generate_app.rb AppName [options]

    Examples:
      ruby Scripts/generate_app.rb StarterApp
      ruby Scripts/generate_app.rb ClientHost --bundle-id com.example.clienthost --prefix CLT
      ruby Scripts/generate_app.rb RetailApp --output Example/Generated --root-route ocb://retail/home
  TEXT
end

def generate_project!(project_path:, app_name:, app_prefix:, deployment_target:, bundle_id:)
  project = Xcodeproj::Project.new(project_path)
  app_target = project.new_target(:application, app_name, :ios, deployment_target)

  app_target.build_configurations.each do |config|
    config.build_settings['INFOPLIST_FILE'] = "#{app_name}/Info.plist"
    config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = bundle_id
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = deployment_target
    config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'
    config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
    config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = ['$(inherited)', '@executable_path/Frameworks']
    config.build_settings['ASSETCATALOG_COMPILER_APPICON_NAME'] = ''
    config.build_settings['GENERATE_INFOPLIST_FILE'] = 'NO'
    config.build_settings['PRODUCT_NAME'] = '$(TARGET_NAME)'
    config.build_settings['SWIFT_VERSION'] = '5.0'
  end

  app_group = project.main_group.new_group(app_name, app_name)
  host_group = app_group.new_group('Host', 'Host')
  demo_group = app_group.new_group('Demo', 'Demo')

  {
    app_group => %w[
      AppDelegate.h
      AppDelegate.m
      Info.plist
      main.m
    ],
    host_group => [
      "#{app_prefix}AppLauncher.h",
      "#{app_prefix}AppLauncher.m",
      "#{app_prefix}RouteCatalog.h",
      "#{app_prefix}RouteCatalog.m"
    ],
    demo_group => [
      "#{app_prefix}BootstrapTask.h",
      "#{app_prefix}BootstrapTask.m",
      "#{app_prefix}HomeViewController.h",
      "#{app_prefix}HomeViewController.m",
      "#{app_prefix}Module.h",
      "#{app_prefix}Module.m"
    ]
  }.each do |group, files|
    files.each do |file_name|
      file_ref = group.new_file(file_name)
      next unless File.extname(file_name) == '.m'

      app_target.add_file_references([file_ref])
    end
  end

  frameworks_group = project.frameworks_group
  ui_kit_ref = frameworks_group.new_file('System/Library/Frameworks/UIKit.framework')
  app_target.frameworks_build_phase.add_file_reference(ui_kit_ref, true)

  project.save

  scheme = Xcodeproj::XCScheme.new
  scheme.configure_with_targets(app_target, nil, launch_target: true)
  scheme.save_as(project_path, app_name, true)
end

options = {
  output_root: DEFAULT_OUTPUT_ROOT,
  deployment_target: DEFAULT_DEPLOYMENT_TARGET,
  force: false
}

parser = OptionParser.new do |opts|
  opts.banner = usage_banner

  opts.on('--bundle-id BUNDLE_ID', 'Bundle identifier. Default: com.example.<AppName>') do |value|
    options[:bundle_id] = value
  end

  opts.on('--prefix PREFIX', 'Objective-C class prefix for the host app. Default: derived from AppName') do |value|
    options[:prefix] = value
  end

  opts.on('--root-route ROUTE', 'Root route used by the generated host module. Default: ocb://<app-name>/home') do |value|
    options[:root_route] = value
  end

  opts.on('--output PATH', 'Custom output root. App folder will be created under this path') do |value|
    options[:output_root] = File.expand_path(value)
  end

  opts.on('--deployment-target VERSION', 'iOS deployment target. Default: 13.0') do |value|
    options[:deployment_target] = value
  end

  opts.on('--pod-path PATH', 'Custom path used by Podfile for OCAppBox') do |value|
    options[:pod_path] = value
  end

  opts.on('--force', 'Overwrite an existing generated app folder') do
    options[:force] = true
  end
end

parser.parse!

app_name = ARGV.shift
if app_name.nil? || app_name.strip.empty?
  warn parser.banner
  exit 1
end

unless app_name.match?(/\A[A-Za-z][A-Za-z0-9]*\z/)
  warn 'AppName must start with a letter and contain only letters or digits.'
  exit 1
end

app_prefix = options[:prefix] || default_prefix(app_name)
unless app_prefix.match?(/\A[A-Za-z][A-Za-z0-9]*\z/)
  warn 'Prefix must start with a letter and contain only letters or digits.'
  exit 1
end

app_identifier = underscore(app_name)
display_name = humanize(app_name)
bundle_id = options[:bundle_id] || "com.example.#{app_name}"
root_route = options[:root_route] || "ocb://#{app_identifier.tr('_', '-')}/home"
output_dir = File.join(options[:output_root], app_name)
project_path = File.join(output_dir, "#{app_name}.xcodeproj")
pod_path = options[:pod_path] || default_pod_path(ROOT, output_dir)

if File.exist?(output_dir)
  unless options[:force]
    warn "Target directory already exists: #{output_dir}"
    warn 'Use --force if you want to overwrite it.'
    exit 1
  end

  FileUtils.rm_rf(output_dir)
end

FileUtils.mkdir_p(output_dir)

replacements = {
  '__APP_NAME__' => app_name,
  '__APP_DISPLAY_NAME__' => display_name,
  '__APP_PREFIX__' => app_prefix,
  '__APP_IDENTIFIER__' => app_identifier,
  '__BUNDLE_ID__' => bundle_id,
  '__ROOT_ROUTE_PATH__' => root_route,
  '__DEPLOYMENT_TARGET__' => options[:deployment_target],
  '__OCAPPBOX_POD_PATH__' => pod_path
}

Dir.glob(File.join(TEMPLATE_ROOT, '**', '*'), File::FNM_DOTMATCH).sort.each do |source_path|
  basename = File.basename(source_path)
  next if ['.', '..'].include?(basename)

  relative_path = source_path.sub("#{TEMPLATE_ROOT}/", '')
  next if relative_path == 'TEMPLATE.md'

  rendered_relative_path = render_string(relative_path, replacements).sub(/\.tpl$/, '')
  destination_path = File.join(output_dir, rendered_relative_path)

  if File.directory?(source_path)
    FileUtils.mkdir_p(destination_path)
    next
  end

  FileUtils.mkdir_p(File.dirname(destination_path))
  rendered_content = render_string(File.read(source_path), replacements)
  File.write(destination_path, rendered_content)
end

generate_project!(
  project_path: project_path,
  app_name: app_name,
  app_prefix: app_prefix,
  deployment_target: options[:deployment_target],
  bundle_id: bundle_id
)

puts "Generated app #{app_name}"
puts "  Prefix: #{app_prefix}"
puts "  Bundle ID: #{bundle_id}"
puts "  Root route: #{root_route}"
puts "  Output: #{output_dir}"
