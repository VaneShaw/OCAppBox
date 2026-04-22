#!/usr/bin/env ruby

require 'optparse'

ROOT = File.expand_path('..', __dir__)
DEFAULT_ROUTE_HEADER_PATH = File.join(ROOT, 'App', 'Host', 'OCBDemoRouteCatalog.h')
DEFAULT_ROUTE_IMPL_PATH = File.join(ROOT, 'App', 'Host', 'OCBDemoRouteCatalog.m')

def underscore(camel_case_name)
  camel_case_name
    .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
    .gsub(/([a-z\d])([A-Z])/, '\1_\2')
    .tr('-', '_')
    .downcase
end

def route_constant_suffix(module_name, page_name)
  return page_name if page_name.start_with?(module_name)
  return module_name if page_name == module_name

  "#{module_name}#{page_name}"
end

def usage_banner
  <<~TEXT
    Usage:
      ruby Scripts/generate_route.rb ModuleName PageName [options]

    Examples:
      ruby Scripts/generate_route.rb Home Feed
      ruby Scripts/generate_route.rb Profile Settings --route-path ocb://profile/settings
      ruby Scripts/generate_route.rb Account Security --view-controller OCBAccountSecurityViewController
  TEXT
end

def insert_before_anchor(content, anchor, line_to_insert)
  return content if content.include?(line_to_insert)

  index = content.index(anchor)
  raise "Anchor '#{anchor}' not found" if index.nil?

  "#{content[0...index]}#{line_to_insert}#{content[index..]}"
end

def write_file(path, content)
  File.open(path, 'w') { |file| file.write(content) }
end

options = {
  prefix: 'OCB',
  route_prefix: 'OCBDemoRoute',
  header_path: DEFAULT_ROUTE_HEADER_PATH,
  impl_path: DEFAULT_ROUTE_IMPL_PATH
}

parser = OptionParser.new do |opts|
  opts.banner = usage_banner

  opts.on('--route-path PATH', 'Route path literal, default: ocb://<module>/<page>') do |value|
    options[:route_path] = value
  end

  opts.on('--route-prefix PREFIX', 'Route constant prefix, default: OCBDemoRoute') do |value|
    options[:route_prefix] = value
  end

  opts.on('--prefix PREFIX', 'Objective-C class prefix, default: OCB') do |value|
    options[:prefix] = value
  end

  opts.on('--view-controller CLASS', 'Custom view controller class name in registration snippet') do |value|
    options[:view_controller] = value
  end

  opts.on('--header PATH', 'Route catalog header path, default: App/Host/OCBDemoRouteCatalog.h') do |value|
    options[:header_path] = File.expand_path(value)
  end

  opts.on('--impl PATH', 'Route catalog impl path, default: App/Host/OCBDemoRouteCatalog.m') do |value|
    options[:impl_path] = File.expand_path(value)
  end
end

parser.parse!

module_name = ARGV.shift
page_name = ARGV.shift

if module_name.nil? || module_name.strip.empty? || page_name.nil? || page_name.strip.empty?
  warn parser.banner
  exit 1
end

unless [module_name, page_name, options[:prefix], options[:route_prefix]].all? { |value| value.match?(/\A[A-Za-z][A-Za-z0-9]*\z/) }
  warn 'ModuleName, PageName, prefix and route-prefix must start with a letter and contain only letters or digits.'
  exit 1
end

unless File.exist?(options[:header_path]) && File.exist?(options[:impl_path])
  warn "Route catalog files not found:\n  header: #{options[:header_path]}\n  impl: #{options[:impl_path]}"
  exit 1
end

suffix = route_constant_suffix(module_name, page_name)
route_constant = "#{options[:route_prefix]}#{suffix}"
route_path = options[:route_path] || "ocb://#{underscore(module_name)}/#{underscore(page_name)}"
controller_class = options[:view_controller] || "#{options[:prefix]}#{suffix}ViewController"

header_line = "FOUNDATION_EXPORT NSString * const #{route_constant};\n"
impl_line = "NSString * const #{route_constant} = @\"#{route_path}\";\n"

header_content = File.read(options[:header_path])
impl_content = File.read(options[:impl_path])

header_content = insert_before_anchor(header_content, "NS_ASSUME_NONNULL_END\n", header_line)
impl_content = impl_content.include?(impl_line) ? impl_content : "#{impl_content.chomp}\n#{impl_line}"

write_file(options[:header_path], header_content)
write_file(options[:impl_path], impl_content)

puts "Registered route constant #{route_constant}"
puts "  Path: #{route_path}"
puts "  Header: #{options[:header_path]}"
puts "  Impl: #{options[:impl_path]}"
puts
puts 'Add route registration in your module bootstrap task:'
puts "[appContext.router registerRoute:#{route_constant}"
puts '                      factory:^UIViewController * _Nullable(NSDictionary * _Nullable params) {'
puts "    return [[#{controller_class} alloc] init];"
puts '}];'
