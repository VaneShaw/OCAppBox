#!/usr/bin/env ruby

require 'fileutils'
require 'optparse'

ROOT = File.expand_path('..', __dir__)
TEMPLATE_ROOT = File.join(ROOT, 'Templates', 'ServiceTemplate')
DEFAULT_OUTPUT_ROOT = File.join(ROOT, 'Sources', 'OCAppBox', 'Service')

def underscore(camel_case_name)
  camel_case_name
    .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
    .gsub(/([a-z\d])([A-Z])/, '\1_\2')
    .tr('-', '_')
    .downcase
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
      ruby Scripts/generate_service.rb ServiceName [options]

    Examples:
      ruby Scripts/generate_service.rb FeatureFlag --domain Config
      ruby Scripts/generate_service.rb HomePreference --domain User
  TEXT
end

options = {
  output_root: DEFAULT_OUTPUT_ROOT,
  force: false
}

parser = OptionParser.new do |opts|
  opts.banner = usage_banner

  opts.on('--domain DOMAIN', 'Service domain folder. Default: <ServiceName>') do |value|
    options[:domain] = value
  end

  opts.on('--output PATH', 'Custom output root. Service files will be created under this path') do |value|
    options[:output_root] = File.expand_path(value)
  end

  opts.on('--force', 'Overwrite an existing generated service files') do
    options[:force] = true
  end
end

parser.parse!

service_name = ARGV.shift
if service_name.nil? || service_name.strip.empty?
  warn parser.banner
  exit 1
end

unless service_name.match?(/\A[A-Za-z][A-Za-z0-9]*\z/)
  warn 'ServiceName must start with a letter and contain only letters or digits.'
  exit 1
end

domain_name = options[:domain] || service_name
unless domain_name.match?(/\A[A-Za-z][A-Za-z0-9]*\z/)
  warn 'Domain must start with a letter and contain only letters or digits.'
  exit 1
end

service_identifier = underscore(service_name)
output_dir = File.join(options[:output_root], domain_name)
header_path = File.join(output_dir, "OCB#{service_name}Service.h")
implementation_path = File.join(output_dir, "OCB#{service_name}Service.m")

if [header_path, implementation_path].any? { |path| File.exist?(path) }
  unless options[:force]
    warn "Target files already exist under: #{output_dir}"
    warn 'Use --force if you want to overwrite them.'
    exit 1
  end

  FileUtils.rm_f([header_path, implementation_path])
end

replacements = {
  '__SERVICE_NAME__' => service_name,
  '__SERVICE_IDENTIFIER__' => service_identifier,
  '__DOMAIN_NAME__' => domain_name
}

Dir.glob(File.join(TEMPLATE_ROOT, '**', '*'), File::FNM_DOTMATCH).sort.each do |source_path|
  basename = File.basename(source_path)
  next if ['.', '..'].include?(basename)

  relative_path = source_path.sub("#{TEMPLATE_ROOT}/", '')
  next if relative_path == 'README.md'

  rendered_relative_path = render_string(relative_path, replacements).sub(/\.tpl$/, '')
  destination_path = File.join(options[:output_root], rendered_relative_path)

  if File.directory?(source_path)
    FileUtils.mkdir_p(destination_path)
    next
  end

  FileUtils.mkdir_p(File.dirname(destination_path))
  rendered_content = render_string(File.read(source_path), replacements)
  File.write(destination_path, rendered_content)
end

puts "Generated service #{service_name}"
puts "  Domain: #{domain_name}"
puts "  Output: #{output_dir}"
