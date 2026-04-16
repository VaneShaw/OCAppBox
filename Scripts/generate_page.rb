#!/usr/bin/env ruby

require 'fileutils'
require 'optparse'

ROOT = File.expand_path('..', __dir__)
TEMPLATE_ROOT = File.join(ROOT, 'Templates', 'PageTemplate')
DEFAULT_MODULE_ROOT = File.join(ROOT, 'Sources', 'OCAppBox', 'Module')
SUPPORTED_TYPES = %w[plain table collection].freeze

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

def page_class_suffix(module_name, page_name)
  return page_name if page_name.start_with?(module_name)
  return module_name if page_name == module_name

  "#{module_name}#{page_name}"
end

def render_string(content, replacements)
  output = content.dup
  replacements.each do |key, value|
    output.gsub!(key, value)
  end
  output
end

def usage_banner
  <<~TEXT
    Usage:
      ruby Scripts/generate_page.rb ModuleName PageName [options]

    Examples:
      ruby Scripts/generate_page.rb Home Feed --type table
      ruby Scripts/generate_page.rb Account Profile --type collection --title "Profile Grid"
      ruby Scripts/generate_page.rb Demo Settings --prefix DEM --output Example/MyApp/MyApp/Demo
  TEXT
end

options = {
  type: 'plain',
  prefix: 'OCB',
  force: false
}

parser = OptionParser.new do |opts|
  opts.banner = usage_banner

  opts.on('--type TYPE', "Page type: #{SUPPORTED_TYPES.join(', ')}. Default: plain") do |value|
    options[:type] = value
  end

  opts.on('--title TITLE', 'Display title shown in the generated page') do |value|
    options[:title] = value
  end

  opts.on('--prefix PREFIX', 'Objective-C class prefix. Default: OCB') do |value|
    options[:prefix] = value
  end

  opts.on('--output PATH', 'Custom output directory. Default: Sources/OCAppBox/Module/<ModuleName>/UI') do |value|
    options[:output_root] = File.expand_path(value)
  end

  opts.on('--force', 'Overwrite an existing generated page files') do
    options[:force] = true
  end
end

parser.parse!

module_name = ARGV.shift
page_name = ARGV.shift

if module_name.nil? || module_name.strip.empty? || page_name.nil? || page_name.strip.empty?
  warn parser.banner
  exit 1
end

unless [module_name, page_name, options[:prefix]].all? { |value| value.match?(/\A[A-Za-z][A-Za-z0-9]*\z/) }
  warn 'ModuleName, PageName and Prefix must start with a letter and contain only letters or digits.'
  exit 1
end

unless SUPPORTED_TYPES.include?(options[:type])
  warn "Type must be one of: #{SUPPORTED_TYPES.join(', ')}."
  exit 1
end

template_dir = File.join(TEMPLATE_ROOT, options[:type])
output_root = options[:output_root] || File.join(DEFAULT_MODULE_ROOT, module_name, 'UI')
class_suffix = page_class_suffix(module_name, page_name)
page_class_name = "#{options[:prefix]}#{class_suffix}ViewController"
display_title = options[:title] || humanize(page_name)

header_path = File.join(output_root, "#{page_class_name}.h")
implementation_path = File.join(output_root, "#{page_class_name}.m")

if [header_path, implementation_path].any? { |path| File.exist?(path) }
  unless options[:force]
    warn "Target files already exist in: #{output_root}"
    warn 'Use --force if you want to overwrite them.'
    exit 1
  end

  FileUtils.rm_f([header_path, implementation_path])
end

replacements = {
  '__MODULE_NAME__' => module_name,
  '__PAGE_NAME__' => page_name,
  '__PAGE_CLASS_NAME__' => page_class_name,
  '__DISPLAY_TITLE__' => display_title
}

Dir.glob(File.join(template_dir, '**', '*'), File::FNM_DOTMATCH).sort.each do |source_path|
  basename = File.basename(source_path)
  next if ['.', '..'].include?(basename)

  relative_path = source_path.sub("#{template_dir}/", '')
  rendered_relative_path = render_string(relative_path, replacements).sub(/\.tpl$/, '')
  destination_path = File.join(output_root, rendered_relative_path)

  if File.directory?(source_path)
    FileUtils.mkdir_p(destination_path)
    next
  end

  FileUtils.mkdir_p(File.dirname(destination_path))
  rendered_content = render_string(File.read(source_path), replacements)
  File.write(destination_path, rendered_content)
end

puts "Generated #{options[:type]} page #{page_class_name}"
puts "  Module: #{module_name}"
puts "  Output: #{output_root}"
