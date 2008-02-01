require "rake"
require "rake/clean"
require "rake/gempackagetask"
require "rake/rdoctask"
require "fileutils" ; include FileUtils
require "yaml"
require "lib/rnginx"

##############################################################################
# Constants
##############################################################################
GemName  = "rNginx"
Version  = RNginx::Version
Title    = "Nginx configurator"
Summary  = "Used to parse and write Nginx configuration files."
Authors  = "Wayne E. Seguin"
Emails   = "wayneeseugin@gmail.com"
Homepage = "http://engineyard.com"

##############################################################################
# Gem Management
##############################################################################
GEM_NAME = "RNginx"
GEM_VERSION = RNginx::Version
RDocOptions = [
  "--quiet", "--title", "#{GEM_NAME}-#{GEM_VERSION} Reference", "--main", "README", "--inline-source"
]

@config_file = "~/.rubyforge/user-config.yml"
@config = nil

##############################################################################
# Gem packaging
##############################################################################
def rubyforge_username
  unless @config
    begin
      @config = YAML.load(File.read(File.expand_path(@config_file)))
    rescue
      puts <<-EOS
ERROR: No rubyforge config file found: #{@config_file}"
Run 'rubyforge setup' to prepare your env for access to Rubyforge
 - See http://newgem.rubyforge.org/rubyforge.html for more details
      EOS
      exit
    end
  end
  @rubyforge_username ||= @config["username"]
end

desc "Packages up #{GemName}."
task :package # => [:clean]

desc "Releases packages for #{GemName}."
task :release => [:package]

spec =
Gem::Specification.new do |specification|
  specification.name = GemName
  specification.version = Version
  specification.platform = Gem::Platform::RUBY
  specification.has_rdoc = true
  specification.extra_rdoc_files = ["README", "CHANGELOG", "COPYING"]
  specification.rdoc_options += RDocOptions
  specification.summary = Summary
  specification.description = Summary
  specification.author = Authors
  specification.email = Emails
  specification.homepage = Homepage
  
  
  specification.extra_rdoc_files = ["README", "CHANGELOG", "COPYING"]
  specification.summary = "a command line and ruby code Nginx config parser, configurator & writer."
  specification.description = specification.summary
  specification.author = "Wayne E. Seguin"
  specification.email = "wayneeseguin at gmail dot com"
  specification.homepage = "rnginx.rubyforge.org"
  
  specification.files = %w(COPYING README Rakefile) +
  Dir.glob("{bin,doc,test,lib,extras}/**/*")
  
  specification.require_path = "lib"

  specification.bindir = "bin"
  
  specification.dependency ""
end

Rake::GemPackageTask.new(spec) do |package|
  package.need_tar = true
  package.gem_spec = spec
end

task "lib" do
  directory "lib"
end

##############################################################################
# Installation & Uninstallation
##############################################################################
task :install do
  sh %{rake package}
  sh %{sudo gem install pkg/#{GEM_NAME}-#{GEM_VERSION}.gem}
end

task :uninstall do
  sh %{sudo gem uninstall #{GEM_NAME}.gem}
end

##############################################################################
# Website tasks (website generated using webgen)
##############################################################################
desc "Generate and upload website files"
task :website => [:generate_website, :upload_website, :generate_rdoc, :upload_rdoc]

task :generate_website do
  # ruby atom.rb > output/feed.atom
  sh %{pushd website; webgen; popd }
end

task :generate_rdoc do
  sh %{rake rdoc}
end

desc "Upload website files to rubyforge"
task :upload_website do
  sh %{rsync -avz website/output/ #{rubyforge_username}@rubyforge.org:/var/www/gforge-projects/#{GEM_NAME}/}
end

desc "Upload rdoc files to rubyforge"
task :upload_rdoc do
  sh %{rsync -avz doc/rdoc/ #{rubyforge_username}@rubyforge.org:/var/www/gforge-projects/#{GEM_NAME}/rdoc}
end

desc "Release the website and new gem version"
task :deploy => [:check_version, :website, :release] do
  puts "Remember to create SVN tag:"
  puts "svn copy svn+ssh://#{rubyforge_username}@rubyforge.org/var/svn/#{PATH}/trunk " +
  "svn+ssh://#{rubyforge_username}@rubyforge.org/var/svn/#{PATH}/tags/REL-#{GEM_VERSION} "
  puts "Suggested comment:"
  puts "Tagging release #{CHANGES}"
end

desc "Runs tasks website_generate and install_gem as a local deployment of the gem"
task :local_deploy => [:website_generate, :install_gem]

task :check_version do
  unless ENV["VERSION"]
    puts "Must pass a VERSION=x.y.z release version"
    exit
  end
  unless ENV["VERSION"] == GEM_VERSION
    puts "Please update your version.rb to match the release version, currently #{GEM_VERSION}"
    exit
  end
end

##############################################################################
# rSpec
##############################################################################

require "spec/rake/spectask"

desc "Run specs with coverage"
Spec::Rake::SpecTask.new("spec") do |spec_task|
  spec_task.spec_files = FileList["spec/*_spec.rb"].sort
  spec_task.rcov       = true
end

desc "Run a specific spec with TASK=xxxx, without rcov"
Spec::Rake::SpecTask.new("spec") do |spec_task|
  spec_task.spec_opts  = File.read("spec/spec.opts").split("\n")
  spec_task.libs       = ["lib" ]
  spec_task.spec_files = (ENV["TASK"] || '').split(',').map do |task|
    "spec/#{rnginx}/#{task}_spec.rb"
  end
end

desc "Run specs without coverage"
Spec::Rake::SpecTask.new("spec_no_cov") do |spec_task|
  spec_task.spec_opts  = File.read("spec/spec.opts").split("\n")
  spec_task.spec_files = FileList["spec/*_spec.rb"].sort
end

desc "Run all specs with coverage"
Spec::Rake::SpecTask.new("specs") do |spec_task|
  spec_task.spec_opts  = File.read("spec/spec.opts").split("\n")
  spec_task.spec_files = FileList["spec/**/*_spec.rb"].sort
  spec_task.rcov       = true
end

desc "Run all specs without coverage"
Spec::Rake::SpecTask.new("specs_no_cov") do |spec_task|
  spec_task.spec_opts  = File.read("spec/spec.opts").split("\n")
  spec_task.spec_files = FileList["spec/**/*_spec.rb"].sort
end

desc "Run all specs and output html"
Spec::Rake::SpecTask.new("specs_html") do |spec_task|
  spec_task.spec_opts  = ["--format", "html"]
  spec_task.spec_files = Dir["spec/**/*_spec.rb"].sort
end

##############################################################################
# Statistics
##############################################################################

STATS_DIRECTORIES = [
  %w(Code   lib/),
  %w(Spec   spec/)
].collect { |name, dir| [ name, "./#{dir}" ] }.select { |name, dir| File.directory?(dir) }

desc "Report code statistics (KLOCs, etc) from the application"
task :stats do
  require "extra/stats"
  verbose = true
  CodeStatistics.new(*STATS_DIRECTORIES).to_s
end
