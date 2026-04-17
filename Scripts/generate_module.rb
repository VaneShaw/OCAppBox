#!/usr/bin/env ruby

require 'fileutils'
require 'optparse'

ROOT = File.expand_path('..', __dir__)
TEMPLATE_ROOT = File.join(ROOT, 'Templates', 'ModuleTemplate')
DEFAULT_OUTPUT_ROOT = File.join(ROOT, 'App', 'Module')

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
      ruby Scripts/generate_module.rb ModuleName [options]

    Examples:
      ruby Scripts/generate_module.rb Home
      ruby Scripts/generate_module.rb AccountCenter --route ocb://account-center --title "Account Center"
  TEXT
end

def sync_project_if_needed(output_root)
  sync_root = File.join(ROOT, 'App')
  expanded_output_root = File.expand_path(output_root)
  return unless expanded_output_root.start_with?(sync_root)

  sync_script = File.join(ROOT, 'Scripts', 'generate_project.rb')
  return unless File.exist?(sync_script)

  success = system('ruby', sync_script)
  warn 'Warning: failed to refresh starter app project.' unless success
end

options = {
  output_root: DEFAULT_OUTPUT_ROOT,
  force: false
}

parser = OptionParser.new do |opts|
  opts.banner = usage_banner

  opts.on('--route ROUTE', 'Custom route path. Default: ocb://<module-name>') do |value|
    options[:route] = value
  end

  opts.on('--title TITLE', 'Display title shown in the generated view controller') do |value|
    options[:title] = value
  end

  opts.on('--output PATH', 'Custom output root. Module folder will be created under this path') do |value|
    options[:output_root] = File.expand_path(value)
  end

  opts.on('--force', 'Overwrite an existing generated module folder') do
    options[:force] = true
  end
end

parser.parse!

module_name = ARGV.shift
if module_name.nil? || module_name.strip.empty?
  warn parser.banner
  exit 1
end

unless module_name.match?(/\A[A-Za-z][A-Za-z0-9]*\z/)
  warn 'ModuleName must start with a letter and contain only letters or digits.'
  exit 1
end

module_identifier = underscore(module_name)
display_title = options[:title] || humanize(module_name)
route_path = options[:route] || "ocb://#{module_identifier.tr('_', '-')}"
output_dir = File.join(options[:output_root], module_name)

if File.exist?(output_dir)
  unless options[:force]
    warn "Target directory already exists: #{output_dir}"
    warn 'Use --force if you want to overwrite it.'
    exit 1
  end

  FileUtils.rm_rf(output_dir)
end

replacements = {
  '__MODULE_NAME__' => module_name,
  '__MODULE_IDENTIFIER__' => module_identifier,
  '__DISPLAY_TITLE__' => display_title,
  '__ROUTE_PATH__' => route_path
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

puts "Generated module #{module_name}"
puts "  Route: #{route_path}"
puts "  Output: #{output_dir}"

sync_project_if_needed(options[:output_root])
